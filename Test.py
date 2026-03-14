import serial
import time
import json
import re
import firebase_admin
from firebase_admin import credentials, db

# --- CONFIGURATION ---
# 1. Firebase Setup
# Place your 'serviceAccountKey.json' in the same folder as this script.
CRED_PATH = "serviceAccountKey.json" 
DATABASE_URL = "https://evokfb-default-rtdb.asia-southeast1.firebasedatabase.app/" # REPLACE with your actual Firebase URL

# 2. Serial Port Setup (Server ESP32)
# Windows: 'COM3', 'COM4', etc. (Check Device Manager)
# Mac/Linux: '/dev/ttyUSB0'
SERIAL_PORT = 'COM18'  # CHANGE THIS to your actual COM port
BAUD_RATE = 115200

# --- GLOBAL VARIABLES ---
ser = None

def init_serial():
    global ser
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
        print(f"[SERIAL] Connected to Server on {SERIAL_PORT}")
        time.sleep(2) # Wait for ESP32 to reset
    except Exception as e:
        print(f"[ERROR] Could not open Serial Port: {e}")
        exit()

def send_to_server(command):
    """Sends the command string to the Server ESP32 via USB."""
    if ser and ser.is_open:
        cmd_str = f"{command}\n"
        ser.write(cmd_str.encode('utf-8'))
        print(f"[TX] Sent to Field: {command}")
    else:
        print("[ERROR] Serial port not open.")

def on_alert_change(event):
    """
    Triggered whenever the 'alert_status' node changes in Firebase.
    """
    if event.data:
        status = str(event.data).upper() # e.g., "GAS_DETECTED"
        print(f"[FIREBASE] Status Changed: {status}")
        
        # Map Firebase status to LoRa Commands
        # The Leader code expects: GAS_DETECTED, EVACUATE, STOP_WORK, FIRE, ALERT, CLEAR
        
        valid_commands = ["GAS_DETECTED", "EVACUATE", "STOP_WORK", "FIRE", "ALERT", "CLEAR"]
        
        if any(cmd in status for cmd in valid_commands):
            send_to_server(status)
        else:
            print(f"[WARNING] Unknown status '{status}' - Not sending.")

# --- MAIN ---
if __name__ == "__main__":
    print("--- EVOK PYTHON BRIDGE STARTING ---")
    
    # 1. Connect to Serial
    init_serial()
    
    # 2. Connect to Firebase
    try:
        cred = credentials.Certificate(CRED_PATH)
        firebase_admin.initialize_app(cred, {'databaseURL': DATABASE_URL})
        print("[FIREBASE] Connected successfully.")
    except Exception as e:
        print(f"[ERROR] Firebase Init Failed: {e}")
        exit()

    # 3. Setup Listener
    # We assume your App updates a path called 'alert_status' or 'commands'
    # Change 'evok/alerts' to match where your App writes data!
    ref = db.reference('EVOK_System/Audio_Command') 
    
    # Listen for changes in real-time
    print("[LISTENER] Watching 'EVOK_System/Audio_Command' for changes...")
    ref.listen(on_alert_change)

    # 4. Keep Script Running & Read incoming Serial logs

    def write_serial_to_firebase(line):
        """Pushes a serial message to Firebase under `EVOK_System/Serial_Logs` for debugging."""
        try:
            db.reference('EVOK_System/Serial_Logs').push({
                'message': line,
                'timestamp': int(time.time() * 1000)
            })
            print("[FIREBASE] Pushed serial message to Serial_Logs.")
        except Exception as e:
            print(f"[ERROR] Firebase write failed: {e}")

    def parse_serial_message(line):
        """Try several common formats and return (target, data_dict).
        target is 'Leader' or 'Worker' (capitalized) or None.
        Supported formats:
          - JSON: {"target":"Leader", "temp": 25}
          - JSON with top-level 'Leader' or 'Worker' key
          - Prefixed: 'Leader: temp=25,hum=40' or 'Worker temp=25 hum=40'
          - key=value pairs: 'role=Leader,temp=25'
        """
        # try JSON first
        try:
            obj = json.loads(line)
            if isinstance(obj, dict):
                if 'Leader' in obj:
                    return 'Leader', obj['Leader'] if isinstance(obj['Leader'], dict) else {'value': obj['Leader']}
                if 'Worker' in obj:
                    return 'Worker', obj['Worker'] if isinstance(obj['Worker'], dict) else {'value': obj['Worker']}
                # explicit target field
                tgt = obj.get('target') or obj.get('role') or obj.get('type')
                if tgt:
                    tgt = str(tgt).capitalize()
                    data = {k: v for k, v in obj.items() if k not in ('target', 'role', 'type')}
                    return tgt, data
                # fallback: treat entire dict as data but unknown target
                return None, obj
        except Exception:
            pass

        # prefixed pattern like 'Leader: k=v,k2=v2' or 'Worker k=v k2=v2'
        m = re.match(r'^\s*(Leader|Worker)\b[:\s\-]*(.+)$', line, re.IGNORECASE)
        if m:
            target = m.group(1).capitalize()
            rest = m.group(2).strip()
            # split tokens by comma/semicolon/pipe
            tokens = re.split(r'[;,\|]', rest)
            data = {}
            for t in tokens:
                t = t.strip()
                if not t:
                    continue
                if '=' in t:
                    k, v = t.split('=', 1)
                elif ':' in t:
                    k, v = t.split(':', 1)
                else:
                    # single value -> store as message
                    data['message'] = t
                    continue
                k = k.strip()
                v = v.strip()
                # try to cast numbers
                if v.isdigit():
                    v = int(v)
                else:
                    try:
                        v = float(v)
                    except Exception:
                        v = v.strip('"\'')
                data[k] = v
            return target, data

        # key=value pairs without prefix
        tokens = re.split(r'[;,\| ]+', line)
        kv = {}
        for t in tokens:
            if '=' in t:
                k, v = t.split('=', 1)
                kv[k.strip()] = v.strip()
        if any(k.lower() in ('role', 'target', 'type') for k in kv):
            tgt = kv.get('role') or kv.get('target') or kv.get('type')
            if tgt:
                target = tgt.capitalize()
                data = {k: v for k, v in kv.items() if k.lower() not in ('role', 'target', 'type')}
                # try cast
                for kk, vv in list(data.items()):
                    if vv.isdigit():
                        data[kk] = int(vv)
                    else:
                        try:
                            data[kk] = float(vv)
                        except Exception:
                            data[kk] = vv
                return target, data

        # final fallback: no target, return raw message
        return None, {'message': line}

    def update_live_data(target, data):
        """Update EVOK_System/Live_Data/<target> with data dict and set Last_Updated."""
        try:
            ref = db.reference(f'EVOK_System/Live_Data/{target}')
            ref.update(data)
            # update top-level timestamp in milliseconds
            db.reference('EVOK_System/Live_Data').update({'Last_Updated': int(time.time() * 1000)})
            print(f"[FIREBASE] Updated Live_Data/{target}: {data}")
        except Exception as e:
            print(f"[ERROR] Could not update Live_Data/{target}: {e}")

    try:
        while True:
            if ser.in_waiting:
                line = ser.readline().decode('utf-8', errors='ignore').strip()
                if line:
                    print(f"[RX from Field] {line}")
                    # parse message and update the correct node
                    target, data = parse_serial_message(line)
                    if target and target.lower() in ('leader', 'worker'):
                        update_live_data(target.capitalize(), data)
                    else:
                        # fallback: push raw message to logs so nothing is lost
                        write_serial_to_firebase(line)
            time.sleep(0.1)
    except KeyboardInterrupt:
        print("\nStopping...")
        if ser: ser.close()
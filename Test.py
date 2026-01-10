import serial
import time
import os
import firebase_admin
from firebase_admin import credentials, db

# --- 1. Firebase Configuration ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
KEY_PATH = os.path.join(BASE_DIR, "serviceAccountKey.json")

try:
    cred = credentials.Certificate(KEY_PATH)
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://evokfb-default-rtdb.asia-southeast1.firebasedatabase.app'
    })
    # CHANGE THIS: Point to 'sensorData' instead of 'EVOK_System'
    ref = db.reference("sensorData") 
    print("Firebase connected successfully!")
except Exception as e:
    print(f"Firebase initialization failed: {e}")
    exit()

# --- 2. Serial Configuration ---
SERIAL_PORT = 'COM7' 
BAUD_RATE = 9600

# --- 3. Main Execution Loop ---
try:
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    print(f"Listening to Supervisor on {SERIAL_PORT}...")

    while True:
        raw_line = ser.readline().decode('utf-8', errors='ignore').strip()
        
        if raw_line.startswith("DATA:"):
            parts = raw_line.replace("DATA:", "").split(",")
            
            if len(parts) >= 8:
                # --- THIS CREATES THE FOLDER DIVISION IN YOUR SCREENSHOT ---
                structured_data = {
                    "environment": {
                        "alt": 920,
                        "temp": float(parts[3]) # Body Temp
                    },
                    "gases": {
                        "co2_ppm": 0.71,
                        "lpg_ppm": 134.33,
                        "mq135_raw": int(parts[5]),
                        "mq2_raw": 350,
                        "mq6_raw": 400
                    },
                    "gps": {
                        "lat": 12.9716,
                        "lon": 77.5946
                    },
                    "health": {
                        "bpm": float(parts[1]),
                        "spo2": float(parts[2])
                    },
                    "last_update": time.strftime("%Y-%m-%d %H:%M:%S"),
                    "nodeID": int(parts[0]),
                    "panicActive": bool(int(parts[7]))
                }

                # Update Firebase
                try:
                    ref.set(structured_data) 
                    print(f"✔ Successfully updated 'sensorData' folders for Node {parts[0]}")
                except Exception as e:
                    print(f"Firebase Sync Error: {e}")

except KeyboardInterrupt:
    print("\nStopping script...")
    if 'ser' in locals(): ser.close()
    
#include <SPI.h>
#include <LoRa.h>

// --- LORA PINS ---
#define SS      5
#define RST     14
#define DIO0    2

// --- STATE VARIABLES ---
String globalLat = "0.0";
String globalLng = "0.0";

// --- PROTOTYPES ---
void processLeaderData(String data);
void processWorkerData(String data);
void sendLoRaCommand(String cmd);
String getValue(String data, char separator, int index);

void setup() {
  Serial.begin(115200);
  Serial.println("\n--- EVOK SERIAL GATEWAY STARTED ---");

  // 1. Initialize LoRa
  LoRa.setPins(SS, RST, DIO0);
  if (!LoRa.begin(433E6)) {
    Serial.println("{\"error\": \"LoRa Init Failed\"}");
    while (1);
  }
  LoRa.setSpreadingFactor(7);
  LoRa.setSyncWord(0xF3); // Must match Leader
  Serial.println("{\"status\": \"LoRa Online & Listening\"}");
}

void loop() {
  // -------------------------------------------------
  // 1. LISTEN FOR COMMANDS FROM PC (Serial -> LoRa)
  // -------------------------------------------------
  // Python sends "GAS_DETECTED", we broadcast it.
  if (Serial.available()) {
    String commandFromPC = Serial.readStringUntil('\n');
    commandFromPC.trim();

    if (commandFromPC.length() > 0) {
      // Echo back for confirmation
      Serial.print("{\"log\": \"Sending Command: ");
      Serial.print(commandFromPC);
      Serial.println("\"}");

      sendLoRaCommand(commandFromPC);
    }
  }

  // -------------------------------------------------
  // 2. LISTEN FOR LORA PACKETS (Sensor Data -> Serial)
  // -------------------------------------------------
  int packetSize = LoRa.parsePacket();
  if (packetSize) {
    String incoming = "";
    while (LoRa.available()) {
      incoming += (char)LoRa.read();
    }

    // Check if it is Sensor Data
    if (incoming.startsWith("L:")) {
      processLeaderData(incoming);
    }
    else if (incoming.startsWith("W:")) {
      processWorkerData(incoming);
    }
  }
}

// --- HELPER FUNCTIONS ---

void sendLoRaCommand(String cmd) {
  LoRa.beginPacket();
  LoRa.print(cmd);
  LoRa.endPacket();
  LoRa.receive(); // Go back to receive mode
}

// --- DATA PARSING & JSON OUTPUT ---

void processLeaderData(String data) {
  data = data.substring(2); // Remove "L:"

  // Parse Raw Data
  int hr = getValue(data, ',', 0).toInt();
  int spo2 = getValue(data, ',', 1).toInt();
  float ax = getValue(data, ',', 2).toFloat();
  float ay = getValue(data, ',', 3).toFloat();
  float az = getValue(data, ',', 4).toFloat();
  float atmTemp = getValue(data, ',', 5).toFloat();
  float bodyTemp = getValue(data, ',', 6).toFloat();
  float press = getValue(data, ',', 7).toFloat();
  int oxy = getValue(data, ',', 8).toInt(); // Kept as int per your code

  String lat = getValue(data, ',', 9);
  String lng = getValue(data, ',', 10);

  // Store valid GPS for Worker fall-back
  if (lat != "0" && lat != "0.000000") {
    globalLat = lat;
    globalLng = lng;
  }

  int panic = getValue(data, ',', 11).toInt();

  // --- OUTPUT JSON TO SERIAL (For Python) ---
  Serial.print("{\"type\":\"leader\",");
  Serial.print("\"bpm\":"); Serial.print(hr); Serial.print(",");
  Serial.print("\"spo2\":"); Serial.print(spo2); Serial.print(",");
  Serial.print("\"ax\":"); Serial.print(ax); Serial.print(",");
  Serial.print("\"ay\":"); Serial.print(ay); Serial.print(",");
  Serial.print("\"az\":"); Serial.print(az); Serial.print(",");
  Serial.print("\"temp\":"); Serial.print(bodyTemp); Serial.print(",");
  Serial.print("\"oxy\":"); Serial.print(oxy); Serial.print(",");
  Serial.print("\"pres\":"); Serial.print(press); Serial.print(",");
  Serial.print("\"lat\":\""); Serial.print(globalLat); Serial.print("\",");
  Serial.print("\"lng\":\""); Serial.print(globalLng); Serial.print("\",");
  Serial.print("\"panic\":"); Serial.print(panic);
  Serial.println("}");
}

void processWorkerData(String data) {
  data = data.substring(2); // Remove "W:"

  int hr = getValue(data, ',', 0).toInt();
  int spo2 = getValue(data, ',', 1).toInt();
  float ax = getValue(data, ',', 2).toFloat();
  float ay = getValue(data, ',', 3).toFloat();
  float az = getValue(data, ',', 4).toFloat();
  float atmTemp = getValue(data, ',', 5).toFloat();
  float bodyTemp = getValue(data, ',', 6).toFloat();
  float press = getValue(data, ',', 7).toFloat();
  int panic = getValue(data, ',', 8).toInt();

// --- OUTPUT JSON TO SERIAL ---
  Serial.print("{\"type\":\"worker\",");
  Serial.print("\"bpm\":"); Serial.print(hr); Serial.print(",");
  Serial.print("\"spo2\":"); Serial.print(spo2); Serial.print(",");
  Serial.print("\"ax\":"); Serial.print(ax); Serial.print(",");
  Serial.print("\"ay\":"); Serial.print(ay); Serial.print(",");
  Serial.print("\"az\":"); Serial.print(az); Serial.print(",");
  Serial.print("\"bodyTemp\":"); Serial.print(bodyTemp); Serial.print(",");
  Serial.print("\"atmTemp\":"); Serial.print(atmTemp); Serial.print(","); 
  Serial.print("\"pres\":"); Serial.print(press); Serial.print(",");
  Serial.print("\"lat\":\""); Serial.print(globalLat); Serial.print("\",");
  Serial.print("\"lng\":\""); Serial.print(globalLng); Serial.print("\",");
  Serial.print("\"panic\":"); Serial.print(panic);
  Serial.println("}");

}

String getValue(String data, char separator, int index) {
  int found = 0;
  int strIndex[] = { 0, -1 };
  int maxIndex = data.length() - 1;
  for (int i = 0; i <= maxIndex && found <= index; i++) {
    if (data.charAt(i) == separator || i == maxIndex) {
      found++;
      strIndex[0] = strIndex[1] + 1;
      strIndex[1] = (i == maxIndex) ? i + 1 : i;
    }
  }
  return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}
#include <SPI.h>
#include <LoRa.h>
#include <Wire.h>
#include <TinyGPS++.h>
#include "DFRobotDFPlayerMini.h" 
#include "BluetoothSerial.h"

// --- PINS ---
#define SS          5
#define RST         14
#define DIO0        2
#define VIB_PIN     26
#define BUTTON_PIN  32

// --- AUDIO PINS ---
#define MP3_RX      27 
#define MP3_TX      13 

// --- GPS PINS ---
#define RXD2        16
#define TXD2        17
#define GPS_BAUD    9600

// --- OBJECTS ---
HardwareSerial mp3Serial(1);
HardwareSerial gpsSerial(2);
DFRobotDFPlayerMini myDFPlayer;
TinyGPSPlus gps;
BluetoothSerial SerialBT;

// --- STATE VARIABLES ---
unsigned long lastSendTime = 0;
const int interval = 2000; 
bool vibState = false;
unsigned long vibStartTime = 0;
int lastButtonState = HIGH; 
unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 50;
// --- UPDATE 1: Added latch variable ---
bool panicLatchedState = false; // Remembers if panic was pressed between sends
// --------------------------------------

// --- REALISTIC SIMULATION VARIABLES ---
float sim_HR = 72.0; float sim_SpO2 = 98.0; float sim_Temp = 36.6; float sim_Oxy = 20.9;
float sim_atmTemp = 30.0; float sim_Press = 1012.0;
float sim_ax = 0.02; float sim_ay = -0.01; float sim_az = 0.98;

void setup() {
  Serial.begin(115200);
  pinMode(VIB_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  digitalWrite(VIB_PIN, LOW);

  gpsSerial.begin(GPS_BAUD, SERIAL_8N1, RXD2, TXD2);
  mp3Serial.begin(9600, SERIAL_8N1, MP3_RX, MP3_TX);
  delay(1000);
  
  if (!myDFPlayer.begin(mp3Serial)) {
    Serial.println("❌ DFPlayer Failed");
  } else {
    Serial.println("✅ DFPlayer Online");
    myDFPlayer.volume(25); 
  }

  LoRa.setPins(SS, RST, DIO0);
  if (!LoRa.begin(433E6)) {
    Serial.println("❌ LoRa Failed");
    while (1);
  }
  
  // Init Bluetooth
  SerialBT.begin("EVOK_LEADER"); 
  Serial.println("✅ Bluetooth Listening");
  
  LoRa.setSyncWord(0xF3);
  Serial.println("✅ Leader Ready");
}

void loop() {
  while (gpsSerial.available() > 0) gps.encode(gpsSerial.read());

  // -------------------------------------------------
  // 1. LISTEN FOR BLUETOOTH (Worker Relay Logic)
  // -------------------------------------------------
  if (SerialBT.available()) {
    String btMsg = SerialBT.readStringUntil('\n');
    btMsg.trim();
    
    // Debug print
    Serial.print("Bluetooth Rx: "); Serial.println(btMsg);

    // CASE A: Sensor Data (Start with W:) -> RELAY TO SERVER
    if (btMsg.startsWith("W:")) {
       LoRa.beginPacket();
       LoRa.print(btMsg); // Forward the exact string to Server
       LoRa.endPacket();
       Serial.println("   └── Relayed to Server via LoRa");
    }
    // CASE B: Alert -> Play Sound
    else if (btMsg.indexOf("ALERT") > -1) {
       Serial.println("⚠️ WORKER TRIGGERED PANIC!");
       myDFPlayer.playMp3Folder(8); 
       triggerVibration();
    }
  }

  // -------------------------------------------------
  // 2. LISTEN FOR LORA COMMANDS (Audio)
  // -------------------------------------------------
  int packetSize = LoRa.parsePacket();
  if (packetSize) {
    String incoming = "";
    while (LoRa.available()) incoming += (char)LoRa.read();
    Serial.print("LoRa Rx: "); Serial.println(incoming);

    if (incoming.indexOf("GAS_DETECTED") > -1)      { myDFPlayer.playMp3Folder(1); triggerVibration(); }
    else if (incoming.indexOf("EVACUATE") > -1)     { myDFPlayer.playMp3Folder(2); triggerVibration(); }
    else if (incoming.indexOf("STOP_WORK") > -1)    { myDFPlayer.playMp3Folder(3); triggerVibration(); }
    else if (incoming.indexOf("FIRE_DETECTED") > -1){ myDFPlayer.playMp3Folder(4); triggerVibration(); }    
    else if (incoming.indexOf("ROCK_FALL") > -1)    { myDFPlayer.playMp3Folder(5); triggerVibration(); }
    else if (incoming.indexOf("RETURN") > -1)       { myDFPlayer.playMp3Folder(6); triggerVibration(); }
    else if (incoming.indexOf("EQUIPMENT") > -1)    { myDFPlayer.playMp3Folder(7); triggerVibration(); }
    else if (incoming.indexOf("ALERT") > -1)        { myDFPlayer.playMp3Folder(8); triggerVibration(); }
    else if (incoming.indexOf("ALL_CLEAR") > -1)    { myDFPlayer.stop(); }
  }

  // -------------------------------------------------
  // 3. LOCAL PANIC BUTTON
  // -------------------------------------------------
  int reading = digitalRead(BUTTON_PIN);
  if (reading != lastButtonState) lastDebounceTime = millis();

  if ((millis() - lastDebounceTime) > debounceDelay) {
    if (reading == LOW && !vibState) {
        Serial.println("⚠️ Local Panic!");
        
        // 1. Latch state for LoRa Server
        panicLatchedState = true; 
        
        // 2. Trigger Local Alerts (Leader)
        myDFPlayer.playMp3Folder(8); 
        triggerVibration();

        // --- NEW ADDITION: SEND TO WORKER VIA BLUETOOTH ---
        // Check if the worker is currently connected via Bluetooth
        if (SerialBT.hasClient()) {
            SerialBT.println("ALERT"); // Send the alert notification command
            Serial.println("   👉 Sent 'ALERT' to Worker via Bluetooth");
        } else {
             Serial.println("   ⚠️ Cannot send to Worker: No Bluetooth connection");
        }
        // --------------------------------------------------
    }
  }
  lastButtonState = reading;

  // -------------------------------------------------
  // 4. VIBRATION TIMER
  // -------------------------------------------------
  if (vibState) {
    if (millis() - vibStartTime > 3000) { 
      digitalWrite(VIB_PIN, LOW);
      vibState = false;
    }
  }

  // -------------------------------------------------
  // 5. SEND REALISTIC DATA (To Server)
  // -------------------------------------------------
  if (millis() - lastSendTime > interval) {
    sendRealisticData();
    lastSendTime = millis();
  }
}

void triggerVibration() {
  if (!vibState) { 
    digitalWrite(VIB_PIN, HIGH);
    vibStartTime = millis();
    vibState = true;
  }
}

void sendRealisticData() {
  sim_HR += random(-10, 11) / 10.0; if (sim_HR < 60) sim_HR = 60; if (sim_HR > 90) sim_HR = 90;
  sim_SpO2 += random(-5, 6) / 10.0; if (sim_SpO2 > 100) sim_SpO2 = 100; if (sim_SpO2 < 97) sim_SpO2 = 97;
  sim_Temp += random(-2, 3) / 100.0; if (sim_Temp < 36.2) sim_Temp = 36.2; if (sim_Temp > 37.0) sim_Temp = 37.0;
  sim_ax = random(-2, 3) / 100.0; sim_ay = random(-2, 3) / 100.0; sim_az = 0.98 + random(-1, 2)/100.0;
  sim_atmTemp += random(-1, 2) / 10.0; if (sim_atmTemp < 29.5) sim_atmTemp = 29.5; if (sim_atmTemp > 30.5) sim_atmTemp = 30.5;
  sim_Press += random(-10, 11) / 100.0; if (sim_Press < 1010) sim_Press = 1010; if (sim_Press > 1014) sim_Press = 1014;
  sim_Oxy += random(-1, 2) / 10.0; if (sim_Oxy < 20.8) sim_Oxy = 20.8; if (sim_Oxy > 21.0) sim_Oxy = 21.0;
  
  // --- UPDATE 3: Use and reset the latched state ---
  // Old line deleted: int panic = (digitalRead(BUTTON_PIN) == LOW) ? 1 : 0;
  int panic = panicLatchedState ? 1 : 0;
  panicLatchedState = false; // Reset for next cycle
  // ------------------------------------------------

  LoRa.beginPacket();
  LoRa.print("L:");
  LoRa.print((int)sim_HR); LoRa.print(","); LoRa.print((int)sim_SpO2); LoRa.print(",");
  LoRa.print(sim_ax); LoRa.print(","); LoRa.print(sim_ay); LoRa.print(","); LoRa.print(sim_az); LoRa.print(",");
  LoRa.print(sim_atmTemp); LoRa.print(","); LoRa.print(sim_Temp); LoRa.print(",");
  LoRa.print(sim_Press); LoRa.print(","); LoRa.print(sim_Oxy); LoRa.print(",");
  
  if (gps.location.isValid()) { 
      LoRa.print(gps.location.lat(), 6); LoRa.print(","); 
      LoRa.print(gps.location.lng(), 6); LoRa.print(","); 
  } else { 
      LoRa.print("0,0,"); 
  }
  LoRa.print(panic);
  LoRa.endPacket();
  
  Serial.print("Sent T:"); Serial.println(sim_atmTemp);
}
#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BMP280.h>
#include "MAX30105.h"
#include "BluetoothSerial.h"

// --- PINS ---
#define VIB_PIN     26
#define BUTTON_PIN  32
#define LED_PIN     2   
#define SDA_PIN     21
#define SCL_PIN     22

// --- OBJECTS ---
MAX30105 particleSensor;
Adafruit_MPU6050 mpu;
Adafruit_BMP280 bmp;
BluetoothSerial SerialBT;

// --- CONFIGURATION ---
// Ensure this MAC Address matches your LEADER exactly
uint8_t leaderAddress[6] = {0x78, 0x1C, 0x3C, 0xA4, 0xB4, 0xA6}; 
bool connected = false;

// --- STATE VARIABLES ---
unsigned long lastSendTime = 0;
unsigned long lastReconnectTime = 0; // Fixed Reconnect Timer

bool vibState = false;
unsigned long vibStartTime = 0;
int lastButtonState = HIGH; 
unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 50;

// --- UPDATE 1: Add Latch Variable ---
bool panicLatchedState = false; // Remembers press between data sends
// ------------------------------------

// Simulation Variables
float sim_HR = 75.0; float sim_atmTemp = 30.0; float sim_Press = 1012.0;

void setup() {
  Serial.begin(115200);
  
  // 1. Init Pins
  pinMode(VIB_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  digitalWrite(VIB_PIN, LOW);

  // 2. Init Sensors (Ignored if missing)
  Wire.begin(SDA_PIN, SCL_PIN);
  if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) Serial.println("MAX Ignored");
  if (!mpu.begin()) Serial.println("MPU Ignored");
  if (!bmp.begin(0x76)) Serial.println("BMP Ignored");

  // 3. Init Bluetooth
  SerialBT.begin("EVOK_WORKER", true); 
  Serial.println("Worker Connecting to Leader...");
  connected = SerialBT.connect(leaderAddress);
  
  if(connected) Serial.println("✅ Connected Success!");
  else Serial.println("❌ Connection Failed");
}

void loop() {
  // -------------------------------------------------
  // 1. SAFETY FIRST: PANIC BUTTON
  // -------------------------------------------------
  int reading = digitalRead(BUTTON_PIN);
  if (reading != lastButtonState) lastDebounceTime = millis();

  if ((millis() - lastDebounceTime) > debounceDelay) {
    // Logic: Pin is LOW when pressed (because INPUT_PULLUP)
    if (reading == LOW && !vibState) {
      Serial.println("⚠️ Local Panic!");
      
      // --- UPDATE 2: Latch the state ---
      panicLatchedState = true;
      // --------------------------------

      triggerVibration();
      // Send ALERT only if we have a connection, but VIBRATE regardless
      if (SerialBT.connected()) SerialBT.println("ALERT"); 
    }
  }
  lastButtonState = reading;

  // -------------------------------------------------
  // 2. SMART RECONNECT LOGIC (The Fix)
  // -------------------------------------------------
  // Only check connection status if we think we are disconnected
  if (!SerialBT.connected()) {
      connected = false;
      
      // Try to reconnect ONLY once every 5 seconds
      if (millis() - lastReconnectTime > 5000) {
        Serial.println("🔄 Trying to Reconnect...");
        connected = SerialBT.connect(leaderAddress);
        lastReconnectTime = millis();
        
        if (connected) Serial.println("✅ Reconnected!");
      }
  }

  // -------------------------------------------------
  // 3. LISTEN FOR COMMANDS (From Leader)
  // -------------------------------------------------
  if (SerialBT.available()) {
    String incoming = SerialBT.readStringUntil('\n');
    incoming.toUpperCase(); 
    Serial.print("Rx: "); Serial.println(incoming);
    
    if (incoming.indexOf("ALERT") != -1 || incoming.indexOf("GAS") != -1 || incoming.indexOf("EVAC") != -1) {
      triggerVibration();
    }
  }

  // -------------------------------------------------
  // 4. VIBRATION MANAGER
  // -------------------------------------------------
  if (vibState) {
    digitalWrite(LED_PIN, (millis() / 200) % 2); // Blink LED
    if (millis() - vibStartTime > 3000) { 
      digitalWrite(VIB_PIN, LOW);
      digitalWrite(LED_PIN, LOW);
      vibState = false;
    }
  }

  // -------------------------------------------------
  // 5. SEND DATA
  // -------------------------------------------------
  if (millis() - lastSendTime > 3000) {
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
  sim_HR += random(-10, 11) / 10.0; if (sim_HR < 60) sim_HR = 60; if (sim_HR > 95) sim_HR = 95;
  sim_atmTemp += random(-1, 2) / 10.0; if (sim_atmTemp < 29.5) sim_atmTemp = 29.5; if (sim_atmTemp > 30.5) sim_atmTemp = 30.5;
  sim_Press += random(-10, 11) / 100.0; if (sim_Press < 1010) sim_Press = 1010; if (sim_Press > 1014) sim_Press = 1014;
  
  // --- UPDATE 3: Use and reset the latched state ---
  // Old line deleted: int panic = (digitalRead(BUTTON_PIN) == LOW) ? 1 : 0;
  int panic = panicLatchedState ? 1 : 0;
  panicLatchedState = false; // Reset immediately for next cycle
  // -------------------------------------------------

  // Format: W:HR,SpO2,AX,AY,AZ,AtmTemp,BodyTemp,Press,Panic
  String packet = "W:" + String((int)sim_HR) + ",98,0.02,-0.01,0.98," + String(sim_atmTemp) + ",36.6," + String(sim_Press) + "," + String(panic);
  
  if (SerialBT.connected()) {
    SerialBT.println(packet); 
    Serial.print("TX: "); Serial.println(packet);
  }
}
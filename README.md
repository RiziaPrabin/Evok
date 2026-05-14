# 🦺 EVOK : Embedded Smart Shield for Subterranean Workers

An IoT-based smart wearable safety vest designed to enhance the safety of underground workers through real-time monitoring, hazard detection, and intelligent emergency communication.

---

# 📑 Table of Contents

✦ 📌 Overview  
✦ ✨ Key Features  
✦ 🏗️ System Architecture  
✦ ⚙️ Modules  
✦ 📱 User Interface  
✦ 🛠️ Tech Stack  
✦ 🚀 Installation & Setup  
✦ 📖 Usage Guide  
✦ 🔮 Future Enhancements  
✦ 🌍 Sustainable Development Goals  
✦ 👥 Contributors  

---

# 📌 Overview

EVOK is a smart safety vest developed for subterranean environments such as mines, tunnels, and construction sites.

The system integrates:

✦ Real-time health monitoring  
✦ Environmental hazard detection  
✦ Emergency alert mechanisms  
✦ Long-range communication technologies  
✦ Live supervisor monitoring dashboard  

By combining IoT, Embedded Systems, Flutter, BLE, LoRa, and Firebase, EVOK provides a scalable and practical worker safety solution.

---

# ✨ Key Features

✦ Real-time worker monitoring <br>
✦ Heart Rate & SpO₂ tracking <br>
✦ Gas level detection <br>
✦ Oxygen level monitoring <br>
✦ Fall detection using MPU6050 <br>
✦ Panic emergency button <br>
✦ Bluetooth + LoRa communication <br>
✦ GPS-based location tracking <br>
✦ Firebase real-time synchronization <br>
✦ Supervisor monitoring dashboard <br>
✦ Emergency alerts & notifications <br>

---

# 🏗️ System Architecture

<p align="center">
  <img width="958" height="544" alt="System Architecture" src="https://github.com/user-attachments/assets/99053e94-c8f6-48d1-a75d-19124c8f7975" />
</p>

---

# ⚙️ Modules

## 👷 Worker Module

✦ Collects worker health and environmental data  
✦ Uses ESP32 integrated with sensors  

## 📡 Leader Module

✦ Aggregates BLE data from worker nodes  
✦ Sends long-range LoRa communication  
✦ Provides multilingual voice alerts  

## 🖥️ Server Module

✦ Receives and processes LoRa data  
✦ Uploads structured data to Firebase  

## 📱 App Dashboard

✦ Displays real-time worker status  
✦ Generates safety alerts  
✦ Tracks worker location  

---

# 📱 User Interface

The Flutter dashboard provides:

✦ 📍 Live worker tracking  
✦ ❤️ Health parameter visualization  
✦ 🚨 Emergency alerts  
✦ 📊 Real-time monitoring  
✦ 🛰️ Worker location display  
✦ ⚠️ Hazard notifications  

<br>

<p align="center">
  <img src="https://github.com/user-attachments/assets/2492fadf-a4f1-49f2-8ab9-321a6229b1e0" width="30%" />
  <img src="https://github.com/user-attachments/assets/76093694-26a1-4d97-8dcf-a4ec893362d6" width="30%" />
  <img src="https://github.com/user-attachments/assets/1925abaf-4369-4def-92c2-a84ceb8271ab" width="30%" />
</p>

---

# 🛠️ Tech Stack

## 🔌 Hardware

✦ ESP32  
✦ MAX30102  
✦ MPU6050  
✦ MQ-135  
✦ AO-03 Oxygen Sensor  
✦ LoRa RA-02 Module  
✦ PAM8403 Amplifier  
✦ Speaker  
✦ Panic Button  

## 💻 Software

✦ Flutter  
✦ Dart  
✦ Python  
✦ Arduino Framework  
✦ Firebase Realtime Database  

## 📶 Communication

✦ BLE  
✦ LoRa  

---

# 🚀 Installation & Setup

## Clone Repository

```bash
git clone https://github.com/your-username/your-repository-name.git
```

## Flutter Setup

```bash
flutter pub get
flutter run
```

## Hardware Setup

1. Connect sensors to ESP32  
2. Upload firmware to the microcontroller  
3. Configure LoRa communication  
4. Connect Firebase database  
5. Launch Flutter monitoring app  

---

# 📖 Usage Guide

1️⃣ Power ON the worker and leader modules <br>
2️⃣ Sensors begin collecting worker data <br>
3️⃣ Data is transmitted via BLE and LoRa <br>
4️⃣ Dashboard displays real-time monitoring <br>
5️⃣ Alerts are triggered during emergencies <br>

---

# 🔮 Future Enhancements

✦ 🤖 AI-based predictive safety analysis  
✦ 🔋 Improved battery optimization  
✦ 🧠 Smart hazard prediction models  
✦ 🌐 Large-scale worker deployment  

---

# 🌍 Sustainable Development Goals

EVOK aligns with the following United Nations Sustainable Development Goals:

### 🩺 SDG 3 — Good Health and Well-being
Promotes worker health and safety through continuous physiological monitoring and emergency alert systems.

### 🏭 SDG 8 — Decent Work and Economic Growth
Enhances workplace safety for underground and industrial workers using smart wearable technology.

### 🏗️ SDG 9 — Industry, Innovation and Infrastructure
Implements innovative IoT, Embedded Systems, BLE, and LoRa technologies for smart industrial safety solutions.

### 🌆 SDG 11 — Sustainable Cities and Communities
Supports safer infrastructure and construction environments through real-time hazard detection and monitoring.

---

# 👥 Contributors

✦ Kessiya Thomas  
✦ Rinitha Babu  
✦ Rizia Sara Prabin  
✦ Runa Susan Roy  

---

<br><br>

<p align="center">
  <b>🔥 Found this project helpful?</b>
</p>

<p align="center">
  Please consider giving this project a ⭐ <b>Star</b> on GitHub!
</p>

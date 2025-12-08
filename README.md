# PhishProof 2.0 🎮🔒

**Live Demo:** [phishproof-c6037.web.app](https://phishproof-c6037.web.app)

A culturally-adaptive, web-gamified phishing awareness training platform featuring immersive 2D top-down simulations of real-world phishing scenarios tailored for Malaysian users.

---

## 🎯 Project Overview

PhishProof 2.0 is a Final Year Project (FYP) at University of Wollongong Malaysia that educates users about phishing threats through interactive gameplay. Players navigate authentic digital environments, make critical decisions, and learn to identify Malaysian-specific phishing attempts including:

- Fake Bank Negara Malaysia emails
- EPF/KWSP SMS scams  
- Touch 'n Go verification requests
- Job offer scams
- Government impersonation attacks

---

## 🚀 Key Features

- **Progressive Difficulty System**: Three levels (Beginner, Intermediate, Professional) with role-based scenarios
- **Real-Time Leaderboard**: Global rankings with Firebase Firestore integration
- **Anonymous Authentication**: Firebase-powered sign-in with display name customization
- **Auto-Save System**: Real-time progress saving to Firestore with local browser backup
- **Desktop OS Simulation**: Gmail-style email interface, browser, SMS, and WhatsApp applications
- **Multi-Language Support**: English, Bahasa Melayu, and Chinese (中文)
- **Quest Tracking System**: Clear objectives and progress indicators

---

## 🛠️ Tech Stack

- **Game Engine**: Godot 4  
- **Backend**: Firebase (Authentication, Firestore, Hosting)
- **Deployment**: Firebase Hosting with CLI
- **Languages**: GDScript, JavaScript (Firebase SDK)

---

## 📦 Current Implementation

### ✅ Completed Features
- Firebase anonymous authentication with display name prompts
- Real-time Firestore progress saving and leaderboard
- Beginner level with complete gameplay loop
- NPC dialogue system with educational debrief
- Desktop OS with email, browser, SMS, WhatsApp apps
- Mobile-optimized UI with proper scaling
- Level selection screen
- Quest tracker with objective management

### 🚧 In Progress
- Intermediate level (Office Staff/HR scenarios)
- Professional level (IT Admin/SOC scenarios)
- Additional phishing scenario types
- Achievement badge system expansion

---

## 📁 Project Structure

```
PhishProof/
├── gameplay/
│   ├── components/      # Reusable game components
│   ├── menu/            # UI screens (main menu, role selection)
│   └── main/            # Core gameplay logic
├── player/              # Player character and controls
├── assets/              # Sprites, fonts, icons
├── environments/        # Scene maps (living room, office, etc.)
└── firebase_manager.gd  # Firebase integration
```

---

## 🎨 Asset Credits

### Fonts
- **Minecraft Font** - Main UI font
- **Noto Sans SC** - Chinese character support

### Graphics & Icons
- **Modern Office & Interior Tiles** - [LimeZu on itch.io](https://limezu.itch.io/moderninteriors)
- **Pixel Art Phone Sprite** - Custom design

### Game Assets
- **Character Sprites** - [Markvelyx on itch.io](https://markvelyx.itch.io/random-npcs)
- **UI Elements** - Custom Godot StyleBoxFlat designs

---

## 🔐 Firebase Configuration

Project uses secure Firestore rules with proper authentication:
- User profiles: Owner-only create/update
- Leaderboard scores: Authenticated append-only
- Progress tracking: User-specific access control

---

## 🎓 Academic Context

**Institution**: University of Wollongong Malaysia  
**Course**: Final Year Project (FYP)  
**Methodology**: Design Science Research  
**Learning Frameworks**: Flow Theory, Experiential Learning  
**Target Audience**: Malaysian users across beginner to professional cybersecurity knowledge levels

---

## 📝 License

This project is an academic work for educational purposes.

---

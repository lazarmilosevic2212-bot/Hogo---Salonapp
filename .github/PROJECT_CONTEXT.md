# SALONAPP - Project Context & Progress

## 📋 Project Overview

**SALONAPP** je kompletan salon management sistem sa dve aplikacije:

### 🏢 Admin App
- **1 jedinstvena aplikacija** - svi vlasnici salona koriste istu
- Multi-tenant sistem - svaki salon vidi samo svoje podatke
- Vlasnici salona prate:
  - ✅ Statistiku
  - ✅ Termine klijentata
  - ✅ Barberske/frizerske usluge
  - ✅ Zaposlene

### 📱 User App (Customer App)
- **1 kodno baza** - ali se deploy-a posebno za svaki salon
- Svaki salon ima svoju verziju sa:
  - ✅ Svojim logoom
  - ✅ Svojom bojom/CSS themom
  - ✅ Svojom iOS aplikacijom (App Store)
  - ✅ Svojom Android aplikacijom (Google Play)
- Klijenti salona zakazuju termine preko ove aplikacije
- Salon vidi sve termine u Admin Appu

---

## 🎯 Razvoj Fokus

### Prioriteti:
1. **UI/UX Dizajn** - Prilik izgled je prioritet
2. **Bezprekorni Kod** - Bez grešaka, čista arhitektura
3. **AI Pomoć** - Za nove feature-e, bug fixing, dizajn izmene

### Tehnologije:
- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Auth)
- **State Management**: Provider (ChangeNotifier)
- **Theme**: Dark mode (`0xFF121212`)

---

## 🔧 Arhitektura

### Multi-Tenant Data Isolation
- Session Context: `SalonSession.currentSalon` (persisted u SharedPreferences)
- Firestore struktura: `salons/{salonId}/appointments`, `services`, `barbers`
- Svaki service prima `salonId` kao obavezni parametar

### Struktura Projekta
```
lib/
├── main.dart (App root, MultiProvider setup)
├── models/ (toJson/fromJson serialization)
├── provider/ (ChangeNotifier, state logic)
├── services/ (Firebase business logic)
├── session_manager/ (SalonSession singleton)
├── pages/ (UI screens)
├── widgets/ (Reusable components)
└── style/ (Theme, colors, constants)
```

---

## 📅 Progress Log

### 1. Decembar 2025
- **01.12.2025 13:50** - Implementirane sigurnosne izmene: `AuthService.loginAdmin()` sada koristi FirebaseAuth UID i proverava `admins/{uid}` mapping; `SalonSession` sačuvaje `admin` i `uid` (tenant-safe session)
- **01.12.2025 14:15** - Kreirano `USER_APP_DEPLOYMENT_GUIDE.md` sa detaljnim procedurama za dodavanje novog User App-a (8 faza: priprema, Firebase, config, iOS, Android, submission, post-launch)

---

## 🔒 Security Priority - Admin App Multi-Tenant

### 🚨 Identifikovani Rizici:

1. **Email-Based Login Risk** - Trenutno se admin loguje sa `ownerEmail`
   - ❌ Problem: Admin A može da se loguje sa emailom Admin B salona
   - ⚠️ Nema verifikacije da je ulogovani korisnik zaista vlasnik tog salona

2. **No Tenant Isolation Check** - Nema verifikacije Firebase Auth → SalonMapping
   - ❌ Admin A može teoretski pristupiti Admin B podacima kroz API

3. **No Role-Based Access Control** - Bez RBAC, nema distinkcije između razlika dozvola

4. **Service Design Configuration** - Salon design može biti izmenjena bez tenant verification

---

### ✅ Implementacioni Plan:

#### Phase 1: Authentication & Verification
- [x] **FirebaseAuth UID Linking** - Mapiranje `uid` → `salonId` u `admins` kolekciji
  - Svaki admin mora imati: `uid`, `salonId`, `role`, `permissions` ✅ DONE
- [x] **Login Validation** - Verifikovati da ulogovani `uid` pripada traženom salonu ✅ DONE
- [x] **Session Security** - `SalonSession` mora pamtiti i `uid` i `salonId` ✅ DONE

#### Phase 2: Firestore Rules
- [ ] **Collection-Level Rules** - `admins/{uid}` može čitati samo svoj salon
- [ ] **Salon Document Rules** - Admin može pisati samo `salons/{salonId}` gde je `salonId` u svom dokumentu
- [ ] **Service Design Rules** - Zaštita `salons/{salonId}/design` dokumenta

#### Phase 3: Backend Validation
- [ ] **Service Layer Guards** - Svaki service provera da li je korisnik vlasnik salona
- [ ] **Design Update Guards** - Bezbednost pri ažuriranju `homeBg`, `serviceBg`, itd.

#### Phase 4: UI/UX Bezbednost
- [ ] **Visibility Controls** - Prikazati samo sopstvene podatke u UI-ju
- [ ] **Action Restrictions** - Onemogućiti dugmadi za tuđe saloane

---

## 🚀 Sledeći Koraci (TODO)

- [x] Analizirati security rizike Admin App-a
- [ ] Implementirati Firebase UID → SalonID mapiranje
- [ ] Pisati Firestore security rules
- [ ] Ažurirati AuthService sa tenant verification
- [ ] Proveriti User App UI/UX design
- [ ] Identifikovati bug-ove ili nedovršene feature-e

---

## 📞 Napomene za AI Agente

- Uvek koristi `salonId` u service pozivima - NIKADA ne izostavi tenant isolation
- Uvek null-check `SalonSession.currentSalon` pre nego što ga koristiš
- Koristi `print()` za error logging (app uses print, ne logger)
- Pozovi `notifyListeners()` nakon svake state promene u Provider-ima
- Za Firestore timestamp koristi `FieldValue.serverTimestamp()`

---

## 📚 Dokumentacija

- **`.github/copilot-instructions.md`** - AI developer guide za arhitekturu
- **`.github/SECURITY_IMPLEMENTATION.md`** - Detaljni security plan sa fazama implementacije
- **`.github/USER_APP_DEPLOYMENT_GUIDE.md`** - Korak po korak: dodavanje novog User App-a, Firebase, iOS/Android submission

---

*Last updated: 1 December 2025*

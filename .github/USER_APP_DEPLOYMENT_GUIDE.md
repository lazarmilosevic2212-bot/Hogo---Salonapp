# User App Deployment Guide - Novi Salon Onboarding

**Document Version**: 1.0  
**Last Updated**: 1 December 2025  
**Namena**: Korak po korak procedura za dodavanje nove User App instance (za novi salon)

---

## 📋 Pregled Procesa

Svaki salon ima svoju User App instancu sa:
- Vlastitim logoom i bojama
- Vlastitim paket ID-om (iOS Bundle ID, Android Package Name)
- Vlastitim Firebase projekta (ili shared Firestore ali sa tenant isolation)
- Vlastitelj iOS aplikacije na App Store-u
- Vlastitelj Android aplikacije na Google Play Store-u

Proces traje ~2-3 nedelje (zbog App Store/Play Store review-a).

---

## ✅ Phase 1: Priprema - Šta Klijent Treba Da Uradi

### 1.1 Informatika & Branding

Klijent (vlasnik salona) trebam da obezbedi:

| Stavka | Opis | Format |
|--------|------|--------|
| **Salon Logo** | Logotip salona (transparentno | PNG / SVG, min 1024x1024px |
| **App Icon** | Ikona aplikacije (za App Store / Play Store) | PNG / SVG, 1024x1024px |
| **Brand Colors** | Primarnu boju, sekundarnu boju | HEX (npr. `#FF5733`) |
| **Brand Typography** | (Opcionalno) Font preferences | Font family name |
| **Screenshots** | Za App Store / Play Store (5-7) | PNG, 1440x2960px (Android) / 1080x1920px (iOS) |
| **App Description** | Opis aplikacije za store-ove (150-300 karaktera) | Text |
| **Keywords** | Za pretragu (npr. "frizerski salon") | CSV ili lista |
| **Privacy Policy URL** | Link na privacy policy salona | URL |
| **Terms of Service URL** | Link na uslove korišćenja | URL |
| **Support Email** | Kontakt za korisničku podršku | Email |
| **Apple Developer Account** | Za iOS deployment | Apple ID email |
| **Google Play Account** | Za Android deployment | Google account email |

**Deadline**: Sve do početka Phase 2 (3-5 dana).

### 1.2 Salon Metadata

Prikupiti u Firestore bazu (ako nije već):

```json
{
  "salonId": "salon_unique_id",
  "name": "Salon Name",
  "address": "Adresa salona",
  "phone": "061 1234567",
  "email": "salon@example.com",
  "ownerEmail": "owner@example.com",
  "currency": "RSD",
  "timezone": "Europe/Belgrade",
  "about": "O nama tekst...",
  "logo_url": "https://storage.firebase.com/...",
  "home_bg_image": "https://...",
  "services_bg_image": "https://...",
  "term_bg_image": "https://..."
}
```

---

## 🔧 Phase 2: Firebase & Backend Postavke

### 2.1 Firestore Struktura Za Novi Salon

Kreirajte novi dokument u `salons` kolekciji:

```bash
Firestore Path: salons/{salonId}
├── salonId: "salon_xyz"
├── name: "Salon Ime"
├── ownerEmail: "owner@example.com"
├── address: "Adresa"
├── phone: "061 1234567"
├── currency: "RSD"
├── home_bg_image: "URL sa Cloud Storage"
├── services_bg_image: "URL"
├── term_bg_image: "URL"
├── settingBg: "URL"
└── subcollections:
    ├── appointments/ (prazno na početku)
    ├── services/ (prazno na početku)
    ├── barbers/ (prazno na početku)
    ├── users/ (prazno na početku)
    └── design/ (opciono za customization)
```

**Kako**: Ručno u Firebase Console ili Firebase CLI:
```bash
firebase firestore:set salons/salon_xyz --data '{
  "salonId": "salon_xyz",
  "name": "New Salon",
  "ownerEmail": "owner@example.com",
  "address": "Adresa",
  "phone": "061...",
  "currency": "RSD"
}'
```

### 2.2 Cloud Storage - Branding Assets

1. Kreirajte folder u Cloud Storage-u za novi salon:
   ```
   gs://YOUR_BUCKET/salons/salon_xyz/
   ├── logo.png
   ├── home_bg.jpg
   ├── services_bg.jpg
   └── term_bg.jpg
   ```

2. Uploadujte branding slike (klijent ili vi):
   ```bash
   gsutil cp logo.png gs://YOUR_BUCKET/salons/salon_xyz/
   gsutil cp home_bg.jpg gs://YOUR_BUCKET/salons/salon_xyz/
   ```

3. Generirajte public URLs:
   - U Firebase Console → Storage → Desni klik na fajl → "Copy gsutil URI"
   - Konvertujte u public URL ili koristite signed URLs
   - Ažurirajte Firestore `home_bg_image`, `services_bg_image` itd. sa tim URLs

---

## 🎨 Phase 3: App Configuration & Branding

### 3.1 Klonirajte / Preparite User App Kod

```bash
# Klonirajte repo (ili kopirajte User App fajlove)
git clone https://github.com/YOUR_ORG/salon_app_user.git salon_app_SALON_XYZ
cd salon_app_SALON_XYZ

# Ili prepares existing codebase za novi salon:
# - kopira se `lib/config/app_config.dart`
# - pravi se `lib/style/theme_salon_xyz.dart` (sa novim bojama)
```

### 3.2 Ažurirajte `AppConfig`

Kreirajte / ažurirajte `lib/config/app_config.dart`:

```dart
class AppConfig {
  // Salon-specific configuration
  static const String salonId = "salon_xyz";
  static const String salonName = "Salon Ime";
  static const String appName = "Salon Ime - Booking"; // za App Store/Play Store
  
  // Branding
  static const String primaryColor = "#FF5733"; // klijentova primarna boja
  static const String secondaryColor = "#FFC300";
  static const String logoUrl = "https://storage.firebase.com/.../logo.png";
  
  // Firebase
  static const String firebaseProjectId = "YOUR_PROJECT";
  static const String firebaseStorageBucket = "YOUR_BUCKET.appspot.com";
  
  // Store URLs
  static const String appStoreUrl = "https://apps.apple.com/us/app/...";
  static const String playStoreUrl = "https://play.google.com/store/apps/details?id=...";
}
```

### 3.3 Ažurirajte Theme/Boje

Ažurirajte `lib/style/app_color.dart` da koristi `AppConfig.primaryColor` i `AppConfig.secondaryColor`:

```dart
class AppColor {
  static const Color kprimary = Color(0xFFFF5733); // iz AppConfig.primaryColor
  static const Color ksecondary = Color(0xFFFFC300);
  // ... ostale boje
}
```

### 3.4 Ažurirajte pubspec.yaml

```yaml
name: salon_app_xyz
description: "Booking aplikacija za Salon Ime"
version: 1.0.0+1

# iOS
ios:
  # Ažurirajte Bundle ID u ios/Runner.xcodeproj settings

# Android
android:
  # Ažurirajte Package Name u android/app/build.gradle
```

---

## 📱 Phase 4: iOS Konfiguracija

### 4.1 iOS Build Postavke

1. **Ažurirajte Bundle ID** (jedinstveno za svaki salon):
   ```bash
   # Otvorite Xcode:
   open ios/Runner.xcworkspace
   
   # Ili preko command line:
   # U ios/Runner.xcodeproj/project.pbxproj:
   # PRODUCT_BUNDLE_IDENTIFIER = com.salonname.booking
   ```

   Primer za salon XYZ:
   ```
   com.salonxyz.booking
   ```

2. **Ažurirajte App Info**:
   - iOS/Runner/Info.plist:
     ```xml
     <key>CFBundleDisplayName</key>
     <string>Salon Ime</string>
     <key>CFBundleIdentifier</key>
     <string>com.salonxyz.booking</string>
     ```

3. **Ažurirajte App Icon**:
   - Postavite logo u `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Ili koristite `flutter_launcher_icons` package (već je u pubspec.yaml)
   - Ažurirajte `pubspec.yaml`:
     ```yaml
     flutter_launcher_icons:
       ios: true
       image_path: "assets/logo_salon_xyz.png"
     ```
   - Pokrenite:
     ```bash
     flutter pub get
     flutter pub run flutter_launcher_icons:main
     ```

4. **Generišite Build**:
   ```bash
   flutter clean
   flutter pub get
   flutter build ios --release
   ```

### 4.2 Apple Developer Account & Certificates

1. **Klijent** (vlasnik salona) treba da ima:
   - Apple Developer Account ($99/god)
   - Team ID (pronađi u Apple Developer Portal)

2. **Vas** trebam da dodate kao "Development Team" u Xcode:
   - Xcode → Preferences → Accounts → Add Apple ID
   - Ili u `ios/Runner.xcodeproj` → Signing & Capabilities → Team

3. **Generiši Certificates i Provisioning Profiles**:
   - Za development: Automatic signing (Xcode će generisati)
   - Za App Store: Manual ili Automatic (preporuka: klijent to radi via Apple Developer Portal)

### 4.3 Keychain / Credential Management

Ako koristiš fastlane (preporučeno za CI/CD):

```bash
# Instaliraj fastlane
sudo gem install fastlane

# Inicijaliziraj fastlane za iOS
cd ios
fastlane init

# Fastlane će pitati za Apple ID i password
# Čuva kredencijale sigurno u Keychain-u
```

---

## 🤖 Phase 5: Android Konfiguracija

### 5.1 Android Build Postavke

1. **Ažurirajte Package Name** (jedinstveno):
   ```bash
   # android/app/build.gradle
   android {
     defaultConfig {
       applicationId "com.salonxyz.booking" # Promeniti za svaki salon
       minSdkVersion 21
       targetSdkVersion 34
       versionCode 1
       versionName "1.0.0"
     }
   }
   ```

2. **Ažurirajte App Label**:
   ```xml
   <!-- android/app/src/main/AndroidManifest.xml -->
   <application
     android:label="Salon Ime"
     android:icon="@mipmap/ic_launcher"
     ...
   ```

3. **Ažurirajte App Icon**:
   ```bash
   # Postavite PNG ikone u:
   android/app/src/main/res/mipmap-*/ic_launcher.png
   # (xhdpi, xxhdpi, xxxhdpi, itd.)
   
   # Ili koristite flutter_launcher_icons:
   flutter pub run flutter_launcher_icons:main
   ```

4. **Generišite Build**:
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release  # Za Play Store
   # ili
   flutter build apk --release  # Za APK (testing)
   ```

### 5.2 Google Play Account & Signing Key

1. **Klijent** (vlasnik salona) treba da ima:
   - Google Play Developer Account ($25 one-time)
   - Prihvati uslove korišćenja

2. **Kreirajte Signing Key**:
   ```bash
   keytool -genkey -v -keystore ~/salon_xyz_key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias salon_xyz_key \
     -storepass YOUR_STORE_PASSWORD \
     -keypass YOUR_KEY_PASSWORD \
     -dname "CN=Salon XYZ,O=Salon Ime,L=Beograd,C=RS"
   ```

3. **Konfiguruj Gradle sa Signing Key-om**:
   ```gradle
   // android/key.properties (kreirajte ovaj fajl)
   storePassword=YOUR_STORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=salon_xyz_key
   storeFile=/path/to/salon_xyz_key.jks
   
   // android/app/build.gradle
   signingConfigs {
     release {
       keyAlias keyProperties['keyAlias']
       keyPassword keyProperties['keyPassword']
       storeFile file(keyProperties['storeFile'])
       storePassword keyProperties['storePassword']
     }
   }
   buildTypes {
     release {
       signingConfig signingConfigs.release
     }
   }
   ```

4. **Čuvaj Signing Key sigurno**:
   - Čuvan kopiju `salon_xyz_key.jks` u sigurnoj lokaciji (npr. encrypted backup ili KMS)
   - Nikada ne deli sa klijentom direktno (čuvan ga vi ili klijent preko sefnog kanala)

---

## 🚀 Phase 6: Submission na App Store & Play Store

### 6.1 iOS App Store Submission

1. **Priprema**:
   - Generiši IPA build:
     ```bash
     flutter build ios --release
     open build/ios/ipa
     ```
   - Ili koristite Xcode Archive:
     ```bash
     open ios/Runner.xcworkspace
     # Product → Archive
     ```

2. **TestFlight (Beta Testing)** — preporuka pre finalne objave:
   - Xcode → Product → Archive → Distribute App → TestFlight
   - Dodaj klijenta kao tester
   - Čekaj Apple review (obično 2-24 časa)
   - Testiraj App Store build

3. **App Store Submit**:
   - Xcode → Product → Archive → Distribute App → App Store Connect
   - Popuni app metadata (već si preo privremao):
     - App Name
     - Subtitle (npr. "Booking za frizerski salon")
     - Category: "Lifestyle"
     - Keywords: "salon, booking, frizerski"
     - Description
     - Screenshots
     - Privacy Policy URL
     - Support URL
   - Popuni Content Rating (IARC questionnaire)
   - Izaberi pricing (Free ili sa In-App Purchases)
   - Submit za review

4. **App Review Timeline**:
   - 24-48 sati: Apple čita tvoj submission
   - Pozitivno: Live na App Store
   - Negativno: Feedback sa issues (obično design/content)
   - Rezolvi issues i re-submit

### 6.2 Google Play Store Submission

1. **Priprema**:
   - Generiši App Bundle:
     ```bash
     flutter build appbundle --release
     # build/app/outputs/bundle/release/app-release.aab
     ```

2. **Play Store Konfiguracija**:
   - Kreiraj novu aplikaciju u Google Play Console
   - Postavi Package Name: `com.salonxyz.booking` (mora da se slaže sa build.gradle)
   - Dodaj Screenshots, ikone, opis (prethodno spreman od klijenta)

3. **Submission sa App Bundle**:
   - Upload: `app-release.aab`
   - Popuni metadata (sličan iOS):
     - App Title
     - Short Description
     - Full Description
     - Screenshots (do 8 slika)
     - Feature Graphic (1024x500)
     - Category
     - Content Rating
     - Privacy Policy URL
   - Izaberi cene (Free ili In-App Purchase)
   - Izaberi geografske regije gde će biti dostupna
   - Submit za review

4. **Play Store Review Timeline**:
   - 2-4 časa: Automatska sigurnosna provera
   - 24-48 sati: Manuelna review (ako je potrebna)
   - Pozitivno: Live na Play Store
   - Negativno: Policy violations — reši i re-submit

---

## 📋 Phase 7: Checklist - Pre Publikovanja

- [ ] **Firebase**:
  - [ ] `salons/{salonId}` dokument kreiraj sa svim poljima
  - [ ] Cloud Storage assets uploadovani i URLs ažurirani
  - [ ] Firestore Rules primenjeni (tenant isolation za novi salon)

- [ ] **App Configuration**:
  - [ ] `AppConfig` ažuriran sa `salonId`, `salonName`, `primaryColor`, `logoUrl`
  - [ ] `pubspec.yaml` — verzija `1.0.0+1`
  - [ ] Logo fajlovi dostupni (`assets/logo_*.png`)

- [ ] **iOS**:
  - [ ] Bundle ID: `com.salonxyz.booking` (jedinstveno za svaki salon)
  - [ ] App Icons generiše i postavljen
  - [ ] Build test: `flutter build ios --release` ✅
  - [ ] Certificates & Provisioning Profiles kreirani
  - [ ] App Store metadata spreman (opis, screenshots, privacy policy)

- [ ] **Android**:
  - [ ] Package Name: `com.salonxyz.booking` (jedinstveno)
  - [ ] App Icons postavljeni
  - [ ] Signing Key kreiraj i sigurno čuvan
  - [ ] Build test: `flutter build appbundle --release` ✅
  - [ ] Play Store metadata spreman

- [ ] **Testing**:
  - [ ] iOS TestFlight beta testing — 1 nedelja
  - [ ] Android Google Play internal testing — 3-5 dana
  - [ ] Klijent testira: login, booking, logout ✅

- [ ] **Submission**:
  - [ ] iOS App Store — submit za review
  - [ ] Android Play Store — submit za review
  - [ ] Monitor reviews tokom 48-72 sata

---

## 🔄 Phase 8: Post-Launch & Maintenance

### 8.1 Monitoring

- [ ] Posmatraj crash reports u Firebase Crashlytics
- [ ] Čitaj user reviews na App Store / Play Store
- [ ] Prati analytics: daily active users, sessions, retention

### 8.2 Ažuriranja

Ako trebam da napraviš update (nove feature, bug fix):

```bash
# Ažuriraj kod
git commit -am "Fix: booking bug"

# Bumpiraj verziju
# pubspec.yaml: version: 1.0.1+2

# Rebuildaj
flutter build ios --release
flutter build appbundle --release

# Resubmit na App Store / Play Store (kraće review - 24h)
```

### 8.3 Salon Branding Updates

Ako klijent želi da promeni logo ili boju:
1. Upload nove assets u Cloud Storage: `gs://bucket/salons/salon_xyz/`
2. Ažuriraj URLs u Firestore `home_bg_image`, itd.
3. App će automatski učitati nove slike (ako koristiš CachedNetworkImage)
4. **Ne trebam da rebuildaj i resubmituj** — samo Firestore update je dovoljan

---

## ⚠️ Česti Problemi & Rešenja

| Problem | Rešenje |
|---------|--------|
| **Bundle ID / Package Name nisu jedinstveni** | Svaki salon mora da ima SVE svoj Bundle ID i Package Name. Proverite AppStore/PlayStore da li je već zauzeta. |
| **App Store reject: Missing Privacy Policy** | Privacy Policy MORA biti dostupna na HTTPS URLs (što je već u Firestore postavka). |
| **Play Store reject: App crashes pri loginu** | Proverite Firestore Rules i da li `salons/{salonId}` dokument postoji. |
| **iOS build error: Code signing** | Proverite Bundle ID i Team ID u Xcode. Klijent mora da ima developer account. |
| **Android build error: Signing Key** | Proverite `key.properties` path-eve i permissions. |
| **App loades sa stare konfiguracije** | Clear app cache: Settings → App → Clear Data (Android), ili Reinstall. |

---

## 📞 Support Kontakt

Ako klijent ima pitanja tokom onboardinga:
- Email: `support@salonapp.com`
- Slack / Chat: Link do support kanala
- Dokumentacija: Link na ove guide-ove

---

## 📋 Summary - Quick Checklist

**Klijent treba da obezbedi**:
- [ ] Logo, boje, app name
- [ ] Privacy Policy i Terms URLs
- [ ] Apple Developer Account (za iOS)
- [ ] Google Play Account (za Android)

**Vi trebate da uradite**:
- [ ] Kreirajte `salons/{salonId}` u Firestore
- [ ] Uploadujte assets u Cloud Storage
- [ ] Konfigurujte AppConfig, Bundle ID, Package Name
- [ ] Build & test iOS i Android
- [ ] Submit na App Store i Play Store
- [ ] Monitor reviews i feedback

**Vremenski okvir**: 2-3 nedelje (zbog App Store/Play Store review-a)

---

*User App Deployment Guide v1.0 - 1 December 2025*

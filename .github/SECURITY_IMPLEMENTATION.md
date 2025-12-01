# SALONAPP Security Implementation Guide

## 🔐 Admin App Multi-Tenant Security Architecture

---

## PROBLEM: Trenutno Stanje

### ❌ Security Rizici

#### 1. Email-Based Login (KRITIČNO)
```dart
// PROBLEM: loginAdmin() koristi samo email
var salonSnap = await _firestore
    .collection("salons")
    .where("ownerEmail", isEqualTo: email.trim())
    .limit(1)
    .get();
```
**Rizik**: Admin A sa emailom `salon_a@test.com` može imati pristup Salon B ako koristi `salon_a@test.com` kao owner email.

#### 2. No UID → SalonID Mapping (KRITIČNO)
**Problem**: Nema kolekcije koja mapira `FirebaseAuth.uid` → `salonId`

```
// Nedostaje struktura:
admins/
├── {uid}/
│   ├── salonId: "salon_123"
│   ├── role: "owner"
│   ├── email: "owner@salon.com"
│   └── permissions: [...]
```

#### 3. No Tenant Verification (KRITIČNO)
Kada admin A pristupa `salons/{salonId}/design`, nema provere da li je taj `salonId` njegov:
```dart
// PROBLEM: Nema provere
await _firestore
    .collection('salons')
    .doc(salonId)  // ← Može biti bilo koji salon!
    .update(designData);
```

---

## ✅ REŠENJE: Implementacioni Plan

### Phase 1: Database Schema Updates

#### Step 1: Kreiraj `admins` kolekciju
```firestore
admins/
├── {uid}/
│   ├── salonId: "salon_456"        // Foreign key
│   ├── email: "owner@salon.com"
│   ├── name: "Salon Owner Name"
│   ├── role: "owner"               // "owner", "manager", "staff"
│   ├── permissions: [
│   │   "view_appointments",
│   │   "manage_services",
│   │   "edit_design",
│   │   "view_reports"
│   │ ]
│   ├── createdAt: timestamp
│   └── status: "active"            // "active", "suspended"
```

#### Step 2: Ažuriraj `SalonModel` sa admin reference-om
```dart
class SalonModel {
  final String salonId;
  final String ownerUid;              // ← Reference na Firebase Auth
  final String ownerEmail;
  // ... ostalo
}
```

#### Step 3: Kreiraj `AdminModel` sa tenant info
```dart
class AdminModel {
  final String uid;
  final String salonId;
  final String email;
  final String name;
  final String role;                  // "owner", "manager", "staff"
  final List<String> permissions;
  final DateTime createdAt;
  final String status;                // "active", "suspended"

  AdminModel({
    required this.uid,
    required this.salonId,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.createdAt,
    required this.status,
  });

  factory AdminModel.fromJson(String uid, Map<String, dynamic> json) {
    return AdminModel(
      uid: uid,
      salonId: json['salonId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'staff',
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
    'salonId': salonId,
    'email': email,
    'name': name,
    'role': role,
    'permissions': permissions,
    'createdAt': createdAt,
    'status': status,
  };
}
```

---

### Phase 2: Firestore Security Rules

```javascript
// firestore.rules

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ✅ Admin Authentication
    match /admins/{uid} {
      allow read, write: if request.auth.uid == uid;
    }

    // ✅ Salon Collection - Tenant Isolation
    match /salons/{salonId} {
      // Admin može čitati/pisati samo svoj salon
      allow read, write: if request.auth.uid != null &&
        exists(/databases/$(database)/documents/admins/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.salonId == salonId;

      // Subcollections
      match /appointments/{appointmentId} {
        allow read, write: if request.auth.uid != null &&
          get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.salonId == salonId;
      }

      match /services/{serviceId} {
        allow read, write: if request.auth.uid != null &&
          get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.salonId == salonId;
      }

      match /barbers/{barberId} {
        allow read, write: if request.auth.uid != null &&
          get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.salonId == salonId;
      }

      match /design/{doc=**} {
        // ✅ Samo admin sa salonId može menjati design
        allow read: if request.auth.uid != null;
        allow write: if request.auth.uid != null &&
          get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.salonId == salonId &&
          "edit_design" in get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.permissions;
      }
    }

    // ✅ User data - moze pristupiti samo kroz svoj salon
    match /salons/{salonId}/users/{userId} {
      allow read, write: if request.auth.uid != null &&
        (request.auth.uid == userId ||  // User sam
         (exists(/databases/$(database)/documents/admins/$(request.auth.uid)) &&
          get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.salonId == salonId));
    }
  }
}
```

---

### Phase 3: Ažuriranje AuthService

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Poboljšana Login sa tenant verification
  Future<(AdminModel?, SalonModel?)> loginAdmin(
    String email,
    String password,
  ) async {
    try {
      // Step 1: Firebase Auth
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCred.user!.uid;

      // Step 2: Pronađi admin iz `admins` kolekcije
      final adminDoc = await _firestore
          .collection('admins')
          .doc(uid)
          .get();

      if (!adminDoc.exists) {
        print("❌ Admin record not found");
        return (null, null);
      }

      final admin = AdminModel.fromJson(uid, adminDoc.data()!);

      // Step 3: Verifikuj da je status "active"
      if (admin.status != 'active') {
        print("❌ Admin account is suspended");
        return (null, null);
      }

      // Step 4: Pronađi salon
      final salonDoc = await _firestore
          .collection('salons')
          .doc(admin.salonId)
          .get();

      if (!salonDoc.exists) {
        print("❌ Salon not found");
        return (null, null);
      }

      final salon = SalonModel.fromJson(salonDoc.data()!);

      // Step 5: Sačuvan session
      await SalonSession.setSalon(salon);
      
      return (admin, salon);
    } on FirebaseAuthException catch (e) {
      print("Auth Error: ${e.message}");
      return (null, null);
    } catch (e) {
      print("Login Error: $e");
      return (null, null);
    }
  }

  /// ✅ Tenant-safe salon update
  Future<bool> updateSalonDesign({
    required String salonId,
    required Map<String, dynamic> designData,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        print("❌ User not authenticated");
        return false;
      }

      // ✅ Verifikuj da je admin vlasnik salona
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (!adminDoc.exists) {
        print("❌ Admin record not found");
        return false;
      }

      final adminData = adminDoc.data()!;
      if (adminData['salonId'] != salonId) {
        print("❌ SECURITY: Admin trying to access wrong salon!");
        return false;
      }

      // ✅ Verifikuj permission
      if (!List<String>.from(adminData['permissions']).contains('edit_design')) {
        print("❌ Admin doesn't have edit_design permission");
        return false;
      }

      // ✅ Sada je sigurno update
      await _firestore
          .collection('salons')
          .doc(salonId)
          .update({
            'home_bg_image': designData['homeBg'] ?? '',
            'services_bg_image': designData['serviceBg'] ?? '',
            'term_bg_image': designData['termBg'] ?? '',
            'settings_bg_image': designData['settingBg'] ?? '',
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      print("Update design error: $e");
      return false;
    }
  }
}
```

---

### Phase 4: SalonSession Update

```dart
class SalonSession {
  static SalonModel? currentSalon;
  static AdminModel? currentAdmin;
  static String? currentUid;

  /// ✅ Sačuvan admin info pri login-u
  static Future<void> setSalonAndAdmin(
    SalonModel salon,
    AdminModel admin,
  ) async {
    currentSalon = salon;
    currentAdmin = admin;
    currentUid = admin.uid;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("salon", jsonEncode(salon.toJson()));
    await prefs.setString("admin", jsonEncode(admin.toJson()));
  }

  /// ✅ Verifikuj tenant pre nego što se pristupi
  static bool verifyTenant(String salonId) {
    if (currentSalon == null || currentAdmin == null) {
      print("❌ Session not initialized");
      return false;
    }
    
    if (currentSalon!.salonId != salonId) {
      print("❌ SECURITY BREACH: Tenant mismatch!");
      return false;
    }
    
    return true;
  }
}
```

---

### Phase 5: Service Layer Guards

```dart
class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Tenant-verified appointments fetch
  Future<List<AppointmentModel>> getAllAppointments({
    DateTime? selectedDate,
    required String salonId,
  }) async {
    // ✅ Verifikuj tenant
    if (!SalonSession.verifyTenant(salonId)) {
      throw SecurityException("Unauthorized salon access");
    }

    Query query = _firestore
        .collection('salons')
        .doc(salonId)
        .collection('appointments')
        .where("status", isEqualTo: "pending");

    if (selectedDate != null) {
      final startOfDay = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final endOfDay = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        23, 59, 59,
      );

      query = query
          .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where("timestamp", isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AppointmentModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}

// Custom exception
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  
  @override
  String toString() => "🔒 Security Error: $message";
}
```

---

## 📋 Checklist - Security Implementation

### Phase 1: Database
- [ ] Kreiraj `admins` kolekciju sa shem
- [ ] Ažuriraj `SalonModel` sa `ownerUid`
- [ ] Kreiraj `AdminModel` sa svim poljima
- [ ] Migriraj postojeće admins u novu strukturu

### Phase 2: Firebase Rules
- [ ] Napiši firestore.rules sa tenant isolation
- [ ] Deploy rules u Firebase Console
- [ ] Testiraj rules sa različitim admin nalozima

### Phase 3: Code Updates
- [ ] Ažuriraj `AuthService.loginAdmin()`
- [ ] Dodaj `verifyTenant()` u SalonSession
- [ ] Ažuriraj sve services sa tenant verification
- [ ] Kreiraj `SecurityException` custom exception

### Phase 4: Testing
- [ ] Test: Admin A ne može pristupiti Salon B
- [ ] Test: Admin može menjati samo svoj design
- [ ] Test: Logout + login sa drugim salonom radi
- [ ] Test: Security rules blokiraju neautorizovane pristupe

### Phase 5: UI/UX Security
- [ ] Prikaži samo svoj salon u UI-ju
- [ ] Onemogući dugmali za tuđe saloane
- [ ] Dodaj indikator "You're logged in as: Salon Name"

---

## 🔗 Reference

- **Firestore Security Rules Docs**: https://firebase.google.com/docs/firestore/security/start
- **Firebase Auth Best Practices**: https://firebase.google.com/docs/auth/where-to-start
- **Multi-Tenancy Patterns**: https://cloud.google.com/architecture/saas-tenant-isolation

---

*Security Implementation Guide v1.0 - 1 December 2025*

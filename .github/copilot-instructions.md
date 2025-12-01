# Copilot Instructions for Salon Application (Flutter)

## Project Overview
**Glow & Go** is a multi-tenant salon management Flutter app with Firebase backend. Each salon has isolated data using Firestore's subcollection pattern. The app uses Provider for state management.

## Architecture Patterns

### Multi-Tenant Data Isolation
- **Session Context**: `SalonSession.currentSalon` holds the active salon globally (persisted in SharedPreferences)
- **Firestore Structure**: `salons/{salonId}/appointments`, `salons/{salonId}/services`, etc.
- **Service Layer Pattern**: Every service method requires `salonId` parameter to enforce tenant isolation
  ```dart
  // ✅ CORRECT: Services always accept salonId
  await SalonServices().getAllSalonServices(salonId: salon.salonId)
  
  // ❌ WRONG: Services without salonId parameter
  await SalonServices().getAllSalonServices() // Missing isolation
  ```

### Provider + Session Manager Pattern
1. Provider manages UI state (`List<AppointmentModel>`, loading flags)
2. `SalonSession.currentSalon` provides the context (which salon to operate on)
3. Services read salon context and query/mutate tenant-specific collections
4. Providers access `SalonSession.currentSalon` before calling services

**Example from `appointment_provider.dart`**:
```dart
Future<void> fetchAppointments({DateTime? selectedDate}) async {
  _isLoading = true;
  final salon = SalonSession.currentSalon; // Get context
  if (salon != null) {
    _appointments = await _appointmentService.getAllAppointments(
      salonId: salon.salonId, // Pass isolation key
    );
  }
}
```

## Key Components

### Services (`lib/services/`)
- **appointments_service.dart**: Query/update appointments under `salons/{id}/appointments`
- **salon_services.dart**: Manage services (haircuts, etc.) under `salons/{id}/services`
- **barber_service.dart**: Manage barbers under `salons/{id}/barbers`
- **salon_service.dart**: Get salon document and update salon metadata
- **auth_service.dart**: Firebase authentication (user-agnostic)

### Providers (`lib/provider/`)
- Extend `ChangeNotifier` with `with` syntax
- Must call `SalonSession.currentSalon` before making service calls
- Always null-check salon context before operations
- Patterns: `_isLoading` flag, `notifyListeners()` after state change

### Models (`lib/models/`)
- **salon_model.dart**: Has `copyWith()` and `toJson()/fromJson()` methods
- All models implement `toJson()/fromJson()` for Firestore serialization
- Use `FieldValue.serverTimestamp()` for timestamp fields in services

## Firestore Structure Reference
```
salons/
├── {salonId}/
│   ├── appointments/
│   │   └── {appointmentId}: {status, timestamp, barberId, serviceId, ...}
│   ├── services/
│   │   └── {serviceId}: {name, price, duration, ...}
│   ├── barbers/
│   │   └── {barberId}: {name, experience, ...}
│   └── salon metadata fields
```

## Critical Developer Workflows

### Adding a New Feature in a Provider
1. Check if salon context is needed: `final salon = SalonSession.currentSalon;`
2. Create service method with explicit `salonId` parameter
3. Call service in provider with `salon.salonId` argument
4. Implement error handling with `print()` (app uses print, not logger)
5. Emit state changes with `_isLoading` + `notifyListeners()`

### Creating a New Service
- Always accept `salonId` as first parameter
- Query from `salons/{salonId}/` subcollection path
- Use Firebase methods: `collection().doc().get()`, `.update()`, `.delete()`
- Add try-catch and `print()` errors

### Debugging Data Issues
- Check `SalonSession.currentSalon` is set (examine SharedPreferences in dev tools)
- Verify Firestore rule allows tenant access
- Inspect collection path: missing salonId → wrong collection queried

## Project-Specific Conventions

### Imports
- Package: `package:salon_application/`
- Relative: `../models/`, `../services/`

### Firebase Setup
- Uses `firebase_core` and Firebase Auth with email/password
- `firebase_options.dart` auto-generated (do not modify)
- `devtools_options.yaml` configured (avoid modifying)

### UI Patterns
- Dark theme (scaffoldBackgroundColor: `0xFF121212`)
- Using `CustomButtomBar` for main navigation
- StreamBuilder for auth state (LoginPage vs CustomButtomBar)

### State Management
- MultiProvider at app root with 3 providers: AppointmentProvider, BarberProvider, SalonServicesProvider
- No bloc, only Provider + ChangeNotifier

## Common Pitfalls & Fixes

| Issue | Fix |
|-------|-----|
| Service methods don't accept salonId | Add `required String salonId` param, update callers |
| Queries return empty or wrong data | Check Firestore path uses salonId subcollections |
| Multi-tenant data leaks | Always isolate queries to `salons/{salonId}/` |
| UI doesn't update | Call `notifyListeners()` after state change |
| Salon context is null | Check `SalonSession.loadSalon()` called in main() |

## File Organization
```
lib/
├── main.dart (App root, MultiProvider setup)
├── models/ (Serializable, toJson/fromJson)
├── provider/ (ChangeNotifier, state logic)
├── services/ (Firebase business logic)
├── session_manager/ (SalonSession singleton)
├── pages/ (UI screens)
├── widgets/ (Reusable components)
└── style/ (Theme, colors, constants)
```

## Testing Considerations
- Services are isolated; mock `SalonSession.currentSalon` in tests
- Providers need `SalonSession.currentSalon` mocked to `SalonModel(salonId: 'test')`
- Firebase methods should be mocked or use Firestore emulator

---
*Last updated: 2025-12-01*

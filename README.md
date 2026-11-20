# beadaries-app

Beadaries is a cross-platform Flutter reservation and catalogue system for handmade bead accessories.

## Features

- Firebase email authentication with customer and admin entry paths
- Customer AI bead styling recommendations
- Reservation submission, reference tracking, and atomic in-memory stock locking
- Admin reservation approval/rejection and stock release
- Admin product search, create/edit, stock status, and archive workflows
- Mock and Firebase-backed repository boundaries for inventory development

## Architecture

- `lib/screens`: customer, admin, authentication, reservation, and AI UI
- `lib/providers`: change-notification state for admin inventory
- `lib/services`: product, reservation, and AI service abstractions
- `lib/models`: shared product and recommendation data
- `lib/theme`: shared brand palette and Material theme
- `test`: unit and widget verification

## Requirements

| Area | Requirement | Implementation |
|---|---|---|
| Authentication | FR-01 | Firebase Authentication and role-aware navigation |
| Reservation | FR-04, FR-05, FR-06 | Reservation form, stock lock, reference tracking |
| Admin approval | FR-07 | Approve/reject reservation workflow |
| Inventory | FR-06/FR-09 | Mock/Firestore product repository and admin inventory UI |
| AI stylist | FR-AI-01 to FR-AI-04 | Preference generation, fallback, feedback, reservation handoff |

## Run

```powershell
flutter pub get
flutter run
```

Firebase configuration is provided by `lib/firebase_options.dart`. The project uses mock inventory data by default for development.

## Validate

```powershell
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed lib test
```

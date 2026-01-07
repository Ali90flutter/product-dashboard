# Product Dashboard (Flutter Web + Cubit) — Source Bundle

This zip contains the **app source code** (lib/ + assets/ + pubspec).  
Because this environment cannot ship the full generated platform folders (android/, web/, etc.),
you will generate them locally with Flutter.

## Prerequisites
- Flutter SDK installed
- Android Studio + Flutter/Dart plugins

## Setup (recommended)
1) Create a new Flutter project **with Android + Web**:
   ```bash
   flutter create product_dashboard --org com.example --platforms=android,web
   ```

2) Copy this bundle's contents **into** the created project (overwrite):
   - Replace `lib/` with this bundle's `lib/`
   - Copy `assets/` folder
   - Replace `pubspec.yaml` with this bundle's `pubspec.yaml`
   - Copy `analysis_options.yaml` (optional)

3) From the project root:
   ```bash
   flutter pub get
   ```

4) Run:
   - Android:
     ```bash
     flutter run -d android
     ```
   - Web:
     ```bash
     flutter run -d chrome
     ```

## Features Implemented
- Responsive dashboard shell (NavigationRail on wide screens, Drawer on narrow)
- Product list page (DataTable) with search + filters + sorting
- Add/Edit product modal with validation (reused in details page)
- Product details page
- Data: loads from DummyJSON + in-memory persistence for CRUD during session

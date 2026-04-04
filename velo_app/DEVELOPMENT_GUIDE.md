# Velo App Development Guide

Welcome to the Velo Application! This guide outlines the overall architecture, file structure, and the standard workflow for adding new features or pages to the application to maintain consistency.

## Overview

The Velo app uses a **Feature-First Architecture** combined with **Riverpod 3.0** (`riverpod_annotation`, `riverpod_generator`) for robust, scalable state management, and **GoRouter** for declarative routing. 
`Dio` is utilized as the networking client, employing an Interceptor pattern to abstract token generation via `FlutterSecureStorage`.

---

## 1. Directory Structure

Inside `lib/`, the directory is strictly organized by application functionality:

```text
lib/
 ┣ core/                # Core networking, configuration, and shared tools (e.g. Dio config, Storage layer)
 ┣ features/            # Feature modules (Domain-driven logic)
 ┃ ┣ auth/              # Handles sign-in, sign-up flows
 ┃ ┣ cars/              # Cars dashboard, metadata structures
 ┃ ┣ fuel/              # Fuel consumption history
 ┃ ┣ odometer/          # Odometer history
 ┃ ┣ profile/           # User configuration / customization
 ┃ ┣ settings/          # Application customizations (Themes, Currency config)
 ┃ ┗ supply/            # Purchases and accessories logging
 ┣ router/              # AppRouter configurations
 ┗ main.dart            # Standard startup entrypoint
```

Each feature folder is typically broken down into:
- `/domain/`: Data models (often featuring `.fromJson` factories mapping backend API fields natively).
- `/service/`: Dio API call handlers fetching endpoints. 
- `/providers/`: Riverpod generated data states controlling complex API fetching states securely.
- `/presentation/`: Flutter Widgets outlining Screens and BottomSheets.

---

## 2. Adding a New Feature or Page

When creating new features (e.g., `Maintenance Tracking`), follow this process exactly:

### Step 1: Create the Domain Model
Inside `lib/features/maintenance/domain/maintenance_record.dart`:
Create a strict object mapping mapping your backend Python responses containing its properties and a `fromJson` factory. Be especially diligent handling `_id` decoding:
```dart
factory Record.fromJson(Map<String, dynamic> json) {
  return Record(
    id: json['id']?.toString() ?? (json['_id'] is Map ? json['_id']['\$oid'] : json['_id']?.toString()) ?? '',
    ...
  );
}
```

### Step 2: Create the API Service
Inside `lib/features/maintenance/service/maintenance_service.dart`:
Declare the `Dio` execution parameters.
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_client.dart';

part 'maintenance_service.g.dart'; // REQUIRED line

class MaintenanceService {
  final Dio _dio;
  MaintenanceService(this._dio);

  Future<List<Record>> getRecords(String carId) async {
    final response = await _dio.get('/api/private/car/$carId/maintenance/');
    // Cast and return JSON maps to Domain objects
  }
}

// Generate the Provider effortlessly
@riverpod
MaintenanceService maintenanceService(Ref ref) {
  return MaintenanceService(ref.watch(dioProvider));
}
```

### Step 3: Create the Provider
Inside `lib/features/maintenance/providers/maintenance_provider.dart`:
Expose your Service call into an asynchronous UI builder.
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'maintenance_provider.g.dart'; // REQUIRED line

@riverpod
class MaintenanceRecords extends _$MaintenanceRecords {
  @override
  FutureOr<List<Record>> build(String carId) async {
    return ref.watch(maintenanceServiceProvider).getRecords(carId);
  }

  // Refresh implementation bridging user 'pull-to-refresh' inputs seamlessly 
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(maintenanceServiceProvider).getRecords(carId));
  }
}
```

### Step 4: Run the Code Generator
Whenever you modify files featuring a `@riverpod` annotation or a `part 'file.g.dart';` inclusion, open your terminal (inside `velo_app/`) and launch build runner:
```bash
dart run build_runner build --delete-conflicting-outputs
```
This writes all the complex state dependencies transparently so you never manage manual provider injections.

### Step 5: Construct the Presentation Layer
Inside `lib/features/maintenance/presentation/maintenance_page.dart`:
Construct a `ConsumerWidget` and use Riverpod's automatic `.when` mapping to trace Loaders, Data returns, or Errors natively:
```dart
class MaintenancePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks the UI component straight into the backend provider
    final asyncData = ref.watch(maintenanceRecordsProvider(carId));
    
    return asyncData.when(
      data: (records) => ListView(...),
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text(e.toString()),
    );
  }
}
```

### Step 6: Hook it into the Router 
Go to `lib/router/app_router.dart`.
Pass the newly established Screen widget through standard `GoRoute` configuration setups logic allowing the user to seamlessly navigate.

```dart
GoRoute(
  path: '/maintenance',
  builder: (context, state) => const MaintenancePage(),
),
```

Then invoke `context.push('/maintenance')` through any button widget.

---

## Important Rules to Know

1. **Tokens Setup Automatically**: Never manually send `Bearer` tokens inside your API implementations. The custom `dioProvider` automatically grabs the active token from `FlutterSecureStorage` and handles 401 exceptions gracefully routing the instance outside of the scope back to sign-in.
2. **Handle Loading Statuses Native**: Every UI submission form (like `setState(() => _isLoading = true)`) should utilize loaders effectively allowing backend databases full async time mitigating input spamming.
3. **Environment Config**: The `lib/core/config.dart` stores `API_BASE_URL` - currently `http://127.0.0.1:8000`. Adjust it there when developing locally or deploying onto a robust staging environment smoothly.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cars/providers/cars_provider.dart';
import '../../cars/presentation/create_edit_car_sheet.dart';
import '../../fuel/presentation/fuel_tab.dart';
import '../../odometer/presentation/odometer_tab.dart';
import '../../supply/presentation/supply_tab.dart';
import '../../../core/settings/haptics_provider.dart';
import '../../../core/settings/default_tab_provider.dart';

class CarDashboardPage extends ConsumerStatefulWidget {
  final String carId;

  const CarDashboardPage({super.key, required this.carId});

  @override
  ConsumerState<CarDashboardPage> createState() => _CarDashboardPageState();
}

class _CarDashboardPageState extends ConsumerState<CarDashboardPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final defaultTabAsync = ref.watch(defaultTabProvider);

    return defaultTabAsync.when(
      data: (defaultTab) {
        _tabController ??= TabController(length: 4, vsync: this, initialIndex: defaultTab);
        final carAsync = ref.watch(currentCarProvider(widget.carId));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Car Details'),
            bottom: TabBar(
              controller: _tabController,
          onTap: (index) => ref.read(hapticsConfigProvider.notifier).light(),
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Fuel'),
            Tab(text: 'Odometer'),
            Tab(text: 'Supply'),
          ],
        ),
      ),
      body: carAsync.when(
        data: (car) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Details Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (car.photoUrl != null)
                      Image.network(car.photoUrl!, height: 200, fit: BoxFit.cover),
                    const SizedBox(height: 16),
                    Text('Plate: ${car.licensePlate}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    if (car.make != null) Text('Make: ${car.make}', style: const TextStyle(fontSize: 18)),
                    if (car.model != null) Text('Model: ${car.model}', style: const TextStyle(fontSize: 18)),
                    if (car.year != null) Text('Year: ${car.year}', style: const TextStyle(fontSize: 18)),
                    if (car.color != null) Text('Color: ${car.color}', style: const TextStyle(fontSize: 18)),
                    if (car.vin != null) Text('VIN: ${car.vin}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Current Odometer: ${car.currentOdometer ?? 0} ${car.odometerUnit ?? ''}'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(hapticsConfigProvider.notifier).light();
                        CreateEditCarSheet.show(context, car: car).then((_) {
                          ref.invalidate(currentCarProvider(car.id));
                        });
                      },
                      child: const Text('Edit Details'),
                    )
                  ],
                ),
              ),
              // Fuel Tab
              FuelTab(carId: car.id),
              // Odometer Tab
              OdometerTab(carId: car.id),
              // Supply Tab
              const SupplyTab(),
            ],
          );
        },
        error: (e, st) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
      },
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'widgets/sidebar.dart';
import '../../cars/providers/cars_provider.dart';
import '../../cars/presentation/create_edit_car_sheet.dart';
import '../../../core/settings/haptics_provider.dart';
import '../../../core/settings/currency_provider.dart';
import '../../cars/domain/garage_stats.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Velo Garage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(hapticsConfigProvider.notifier).light();
              ref.read(carsProvider.notifier).refreshCars();
            },
          )
        ],
      ),
      drawer: const Sidebar(),
      body: carsAsync.when(
        data: (cars) {
          if (cars.isEmpty) {
            return const Center(child: Text('No cars found. Add one!'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(carsProvider.notifier).refreshCars();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cars.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final statsAsync = ref.watch(garageStatsProvider);
                  return statsAsync.when(
                    data: (stats) {
                      if (stats.totalSpent == 0) return const SizedBox.shrink();
                      return _buildStatsCard(context, stats, ref);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                }
                final car = cars[index - 1];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      ref.read(hapticsConfigProvider.notifier).light();
                      context.push('/car/${car.id}');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (car.photoUrl != null)
                          Image.network(
                            car.photoUrl!,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              color: Colors.grey,
                              child: const Icon(Icons.error),
                            ),
                          )
                        else
                          Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                car.licensePlate,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ).animate(delay: (index * 100).ms)
                 .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                 .slideX(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuart);
              },
            ),
          );
        },
        error: (e, st) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(hapticsConfigProvider.notifier).heavy();
          CreateEditCarSheet.show(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, GarageStats stats, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = ref.watch(currencyProvider);

    String distanceStr = stats.distanceByUnit.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.value.toStringAsFixed(0)}${e.key}')
        .join(' / ');
    if (distanceStr.isEmpty) distanceStr = '0';

    String fuelStr = stats.fuelAmountByUnit.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.value.toStringAsFixed(0)}${e.key}')
        .join(' / ');
    if (fuelStr.isEmpty) fuelStr = '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('GARAGE TOTALS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 16),
          Text('$currency${stats.totalSpent.toStringAsFixed(0)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildDetailItem('FUEL', '$currency${stats.totalFuelCost.toStringAsFixed(0)}'),
              _buildDetailItem('SERVICES', '$currency${stats.totalServices.toStringAsFixed(0)}'),
              _buildDetailItem('FEES', '$currency${stats.totalExpenses.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem('DISTANCE', distanceStr),
              _buildDetailItem('FUEL USED', fuelStr),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

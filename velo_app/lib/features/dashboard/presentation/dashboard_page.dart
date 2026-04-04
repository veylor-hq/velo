import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'widgets/sidebar.dart';
import '../../cars/providers/cars_provider.dart';
import '../../cars/presentation/create_edit_car_sheet.dart';

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
            onPressed: () => ref.read(carsProvider.notifier).refreshCars(),
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
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
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
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // The list item only has basic info. We could fetch full info 
                                  // before showing edit, but for simplicity we'll pass what we have.
                                  CreateEditCarSheet.show(context, car: car);
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        error: (e, st) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          CreateEditCarSheet.show(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

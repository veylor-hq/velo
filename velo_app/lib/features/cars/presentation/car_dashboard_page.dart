import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cars/providers/cars_provider.dart';

import '../../cars/presentation/create_edit_car_sheet.dart';
import '../../fuel/presentation/fuel_tab.dart';
import '../../odometer/presentation/odometer_tab.dart';
import '../../service/presentation/service_tab.dart';
import '../../expense/presentation/expense_tab.dart';
import '../../../core/settings/haptics_provider.dart';
import '../../../core/settings/default_tab_provider.dart';
import '../../../core/settings/currency_provider.dart';
import '../../fuel/providers/fuel_provider.dart';
import '../../service/providers/service_provider.dart';
import '../../expense/providers/expense_provider.dart';
import '../domain/car.dart';

class CarDashboardPage extends ConsumerStatefulWidget {
  final String carId;
  final String? initialAction;

  const CarDashboardPage({super.key, required this.carId, this.initialAction});

  @override
  ConsumerState<CarDashboardPage> createState() => _CarDashboardPageState();
}

class _CarDashboardPageState extends ConsumerState<CarDashboardPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _showRunningTotalOnly = false;
  bool _hasOpenedInitialAction = false;

  @override
  void initState() {
    super.initState();
  }

  String _calculateOwnershipDuration(CarSalesMeta? meta) {
    if (meta == null || meta.dateBought == null) return 'N/A';
    final bought = DateTime.tryParse(meta.dateBought!)?.toLocal();
    if (bought == null) return 'N/A';
    final end = meta.dateSold != null ? DateTime.tryParse(meta.dateSold!)?.toLocal() ?? DateTime.now() : DateTime.now();
    final difference = end.difference(bought);
    final days = difference.inDays;
    
    if (days < 0) return 'Not yet bought';
    if (days == 0) return 'Bought today';

    int years = (days / 365).floor();
    int remainingDays = days % 365;
    int months = (remainingDays / 30).floor();
    int rDays = remainingDays % 30;

    List<String> parts = [];
    if (years > 0) parts.add('$years year${years == 1 ? '' : 's'}');
    if (months > 0) parts.add('$months month${months == 1 ? '' : 's'}');

    if (rDays > 0) {
      if (years == 0) {
        parts.add('$rDays day${rDays == 1 ? '' : 's'}');
      } else if (months == 0) {
        parts.add('$rDays day${rDays == 1 ? '' : 's'}');
      }
    }

    if (parts.isEmpty) return '0 days';
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final defaultTabAsync = ref.watch(defaultTabProvider);

    return defaultTabAsync.when(
      data: (defaultTab) {
        final safeIndex = defaultTab >= 5 ? 1 : defaultTab;
        _tabController ??= TabController(length: 5, vsync: this, initialIndex: safeIndex);
        final carAsync = ref.watch(currentCarProvider(widget.carId));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Car Details'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              onTap: (index) => ref.read(hapticsConfigProvider.notifier).light(),
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Fuel'),
            Tab(text: 'Odometer'),
            Tab(text: 'Service'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: carAsync.when(
        data: (car) {
          if (widget.initialAction == 'add_fuel' && !_hasOpenedInitialAction) {
            _hasOpenedInitialAction = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _tabController?.animateTo(1);
              showAddFuelSheet(context, ref, car.id);
            });
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Details Tab
              RefreshIndicator(
                onRefresh: () async {
                  ref.read(hapticsConfigProvider.notifier).light();
                  ref.invalidate(currentCarProvider(car.id));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (car.photoUrl != null)
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26),
                            ),
                            child: Image.network(car.photoUrl!, height: 240, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(4, 4),
                                    blurRadius: 0,
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: 32,
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                    child: Center(
                                      child: Text('UK', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Center(
                                      child: Text(
                                        car.licensePlate.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    const SizedBox(height: 24),
                    _buildCompactDetails(context, car),
                    const SizedBox(height: 24),
                    _buildTotalSpentCard(context, car),
                    const SizedBox(height: 24),
                    _buildCharts(context, car),
                    const SizedBox(height: 24),
                    _buildOwnershipCard(context, car),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(hapticsConfigProvider.notifier).light();
                        CreateEditCarSheet.show(context, car: car).then((_) {
                          ref.invalidate(currentCarProvider(car.id));
                        });
                      },
                      child: const Text('EDIT DETAILS'),
                    )
                  ],
                ),
              ),
              ),
              // Fuel Tab
              FuelTab(carId: car.id),
              // Odometer Tab
              OdometerTab(carId: car.id),
              // Service Tab
              ServiceTab(carId: car.id),
              // Expenses Tab
              ExpenseTab(carId: car.id),
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

  Widget _buildCompactDetails(BuildContext context, Car car) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('MAKE', car.make != null && car.make!.isNotEmpty ? car.make! : 'N/A'),
              _buildDetailItem('MODEL', car.model != null && car.model!.isNotEmpty ? car.model! : 'N/A'),
              _buildDetailItem('YEAR', car.year?.toString() ?? 'N/A'),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('COLOR', car.color != null && car.color!.isNotEmpty ? car.color! : 'N/A'),
              _buildDetailItem('VIN', car.vin != null && car.vin!.isNotEmpty ? car.vin! : 'N/A'),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('ODOMETER', '${car.currentOdometer ?? 0} ${car.odometerUnit ?? ''}'),
              _buildDetailItem('FUEL', car.fuelUnit ?? 'l'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSpentCard(BuildContext context, Car car) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = ref.watch(currencyProvider);
    
    double fuelTotal = 0;
    final fuelAsync = ref.watch(fuelRecordsProvider(car.id));
    if (fuelAsync.hasValue) {
      for (var r in fuelAsync.value!) {
        fuelTotal += r.totalCost;
      }
    }

    double serviceLaborTotal = 0;
    double servicePartsTotal = 0;
    final serviceAsync = ref.watch(serviceRecordsProvider(car.id));
    if (serviceAsync.hasValue) {
      for (var r in serviceAsync.value!) {
        serviceLaborTotal += r.totalCost;
        for (var s in r.suppliesUsed) {
          servicePartsTotal += s.quantity * s.pricePerUnit;
        }
      }
    }

    double expenseTotal = 0;
    final expenseAsync = ref.watch(expenseRecordsProvider(car.id));
    if (expenseAsync.hasValue) {
      for (var r in expenseAsync.value!) {
        expenseTotal += r.amount;
      }
    }

    final carCost = car.salesMeta?.priceBought ?? 0.0;
    final runningCosts = fuelTotal + serviceLaborTotal + servicePartsTotal + expenseTotal;
    final grandTotal = carCost + runningCosts;

    return GestureDetector(
      onTap: () {
        ref.read(hapticsConfigProvider.notifier).light();
        setState(() {
          _showRunningTotalOnly = !_showRunningTotalOnly;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
        ),
        child: Column(
          children: [
            Text(_showRunningTotalOnly ? 'RUNNING COSTS ONLY' : 'TOTAL SPENT', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 16),
            Text('$currency${(_showRunningTotalOnly ? runningCosts : grandTotal).toStringAsFixed(0)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildDetailItem('CAR', '$currency${carCost.toStringAsFixed(0)}'),
                _buildDetailItem('FUEL', '$currency${fuelTotal.toStringAsFixed(0)}'),
                _buildDetailItem('SERVICES', '$currency${(serviceLaborTotal + servicePartsTotal).toStringAsFixed(0)}'),
                _buildDetailItem('FEES', '$currency${expenseTotal.toStringAsFixed(0)}'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(BuildContext context, Car car) {
    final fuelAsync = ref.watch(fuelRecordsProvider(car.id));
    if (!fuelAsync.hasValue || fuelAsync.value!.isEmpty) return const SizedBox.shrink();

    final records = fuelAsync.value!.take(10).toList().reversed.toList();
    final fuelAmounts = records.map((r) => r.fuelAmount).toList();
    final mileages = records.map((r) => (r.deltaMileage ?? 0).toDouble()).toList();
    final dates = records.map((r) {
      try {
        final d = DateTime.parse(r.date).toLocal();
        return '${d.day}/${d.month}';
      } catch (e) {
        return '';
      }
    }).toList();

    return Column(
      children: [
        _buildBrutalistBarChart(context, 'FUEL INTAKE (LATEST)', fuelAmounts, dates, car.fuelUnit ?? 'l'),
        const SizedBox(height: 24),
        _buildBrutalistBarChart(context, 'DISTANCE PER TANK', mileages, dates, car.odometerUnit ?? 'km'),
      ],
    );
  }

  Widget _buildBrutalistBarChart(BuildContext context, String title, List<double> values, List<String> xLabels, String unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (values.isEmpty) return const SizedBox.shrink();

    final maxVal = values.reduce((a, b) => a > b ? a : b);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Text('MAX ${maxVal.toStringAsFixed(1)}$unit', style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(values.length, (i) {
                final val = values[i];
                final height = maxVal == 0 ? 0.0 : (val / maxVal) * 80.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(val.toStringAsFixed(0), style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      width: 14,
                      height: height,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(height: 4),
                    Text(xLabels[i], style: const TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnershipCard(BuildContext context, Car car) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = ref.watch(currencyProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
      ),
      child: Column(
        children: [
          const Text('OWNERSHIP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 16),
          Text(_calculateOwnershipDuration(car.salesMeta), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if (car.salesMeta?.priceSold != null) ...[
            const SizedBox(height: 24),
            _buildDetailItem('SOLD FOR', '$currency${car.salesMeta!.priceSold!.toStringAsFixed(0)}', alignment: CrossAxisAlignment.center),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {CrossAxisAlignment alignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/fuel_provider.dart';
import '../service/fuel_service.dart';
import '../domain/fuel_record.dart';

import '../../../core/settings/currency_provider.dart';
import '../../../core/settings/haptics_provider.dart';

class FuelTab extends ConsumerWidget {
  final String carId;

  const FuelTab({super.key, required this.carId});

  void _showAddEditSheet(BuildContext context, WidgetRef ref, [FuelRecord? record]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FuelSheet(carId: carId, record: record),
    ).then((_) => ref.read(fuelRecordsProvider(carId).notifier).refresh());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecords = ref.watch(fuelRecordsProvider(carId));
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      body: asyncRecords.when(
        data: (records) {
          if (records.isEmpty) return const Center(child: Text('No fuel records.'));
          return RefreshIndicator(
            onRefresh: () => ref.read(fuelRecordsProvider(carId).notifier).refresh(),
            child: ListView.builder(
              itemCount: records.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  if (records.isEmpty) return const SizedBox.shrink();
                  double totalSpend = 0;
                  double totalFuel = 0;
                  double validDistance = 0;
                  double validFuel = 0;

                  for (var r in records) {
                    totalSpend += r.totalCost;
                    totalFuel += r.fuelAmount;
                    if (!r.skipMpgCalculation && r.deltaMileage != null && r.fuelAmount > 0) {
                      validDistance += r.deltaMileage!;
                      validFuel += r.fuelAmount;
                    }
                  }

                  final avgMpg = validFuel > 0 ? (validDistance / validFuel) : 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24, right: 16, left: 16, top: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26),
                    ),
                    child: Column(
                      children: [
                        const Text('LIFETIME SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('SPEND', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text('$currency${totalSpend.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('CONSUMED', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text(totalFuel.toStringAsFixed(1), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('AVG MPG', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text(avgMpg.toStringAsFixed(1), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                }

                final recordIndex = index - 1;
                final r = records[recordIndex];
                final isFirst = recordIndex == 0;
                final isLast = recordIndex == records.length - 1;
                final isDark = Theme.of(context).brightness == Brightness.dark;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 40,
                        child: Column(
                          children: [
                            Container(width: 2, height: 20, color: isFirst ? Colors.transparent : (isDark ? Colors.white24 : Colors.black26)),
                            Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? Colors.white : Colors.black),
                            ),
                            Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : (isDark ? Colors.white24 : Colors.black26))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 24, right: 16, top: recordIndex == 0 ? 16 : 0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26, width: 1)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('LOG // ${r.date.split("T").first}', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                    Text('ODO: ${r.odometer} ${r.deltaMileage != null ? '(+${r.deltaMileage})' : ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('FUEL', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                        const SizedBox(height: 4),
                                        Text('${r.fuelAmount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('COST', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                        const SizedBox(height: 4),
                                        Text('$currency${r.totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('UNIT', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                        const SizedBox(height: 4),
                                        Text('$currency${r.pricePerUnit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('TYPE', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                        const SizedBox(height: 4),
                                        Text(r.isFullTank ? 'FULL' : 'PART', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (r.notes != null && r.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Text('NOTES: ${r.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      ref.read(hapticsConfigProvider.notifier).light();
                                      _showAddEditSheet(context, ref, r);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
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
          ref.read(hapticsConfigProvider.notifier).heavy();
          _showAddEditSheet(context, ref);
        },
        child: const Icon(Icons.local_gas_station),
      ),
    );
  }
}

class _FuelSheet extends ConsumerStatefulWidget {
  final String carId;
  final FuelRecord? record;

  const _FuelSheet({required this.carId, this.record});

  @override
  ConsumerState<_FuelSheet> createState() => _FuelSheetState();
}

class _FuelSheetState extends ConsumerState<_FuelSheet> {
  final _odometerController = TextEditingController();
  final _amountController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  bool _isFullTank = true;
  bool _skipMpg = false;
  bool _insertOdometer = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _odometerController.text = widget.record!.odometer.toString();
      _amountController.text = widget.record!.fuelAmount.toString();
      _costController.text = widget.record!.totalCost.toString();
      _notesController.text = widget.record!.notes ?? '';
      _isFullTank = widget.record!.isFullTank;
      _skipMpg = widget.record!.skipMpgCalculation;
    }
  }

  Future<void> _save() async {
    if (_odometerController.text.isEmpty || _amountController.text.isEmpty || _costController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'date': _selectedDate != null ? _selectedDate!.toUtc().toIso8601String() : widget.record?.date ?? DateTime.now().toUtc().toIso8601String(),
        'odometer': int.tryParse(_odometerController.text) ?? 0,
        'fuel_amount': double.tryParse(_amountController.text) ?? 0.0,
        'total_cost': double.tryParse(_costController.text) ?? 0.0,
        'is_full_tank': _isFullTank,
        'skip_mpg_calculation': _skipMpg,
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text.trim(),
        if (widget.record == null) 'insert_odometer_record': _insertOdometer,
      };

      if (widget.record == null) {
        await ref.read(fuelServiceProvider).createFuelRecord(carId: widget.carId, data: data);
      } else {
        await ref.read(fuelServiceProvider).updateFuelRecord(carId: widget.carId, recordId: widget.record!.id, data: data);
      }
      ref.read(hapticsConfigProvider.notifier).success();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.record == null ? 'Add Fuel Record' : 'Edit Fuel Record', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(_selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : (widget.record?.date?.split('T').first ?? 'Today')),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? (widget.record != null ? DateTime.tryParse(widget.record!.date) ?? DateTime.now() : DateTime.now()),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
          const SizedBox(height: 24),
          TextField(controller: _odometerController, decoration: const InputDecoration(labelText: 'Odometer *'), keyboardType: TextInputType.number),
          Row(
            children: [
              Expanded(child: TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount *'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: 24),
              Expanded(child: TextField(controller: _costController, decoration: const InputDecoration(labelText: 'Total Cost *'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ],
          ),
          TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes')),
          SwitchListTile(
            title: const Text('Is Full Tank?'),
            value: _isFullTank,
            onChanged: (v) => setState(() => _isFullTank = v),
          ),
          SwitchListTile(
            title: const Text('Skip MPG Calculation?'),
            value: _skipMpg,
            onChanged: (v) => setState(() => _skipMpg = v),
          ),
          if (widget.record == null)
            SwitchListTile(
              title: const Text('Add Odometer Record?'),
              value: _insertOdometer,
              onChanged: (v) => setState(() => _insertOdometer = v),
            ),
          const SizedBox(height: 24),
          if (_isLoading) const Center(child: CircularProgressIndicator())
          else ElevatedButton(onPressed: _save, child: const Text('Save Record')),
          if (widget.record != null && !_isLoading) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1), foregroundColor: Colors.redAccent),
              onPressed: () async {
                ref.read(hapticsConfigProvider.notifier).heavy();
                setState(() => _isLoading = true);
                try {
                  await ref.read(fuelServiceProvider).deleteFuelRecord(widget.carId, widget.record!.id);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  setState(() => _isLoading = false);
                }
              },
              child: const Text('Delete Record'),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/fuel_provider.dart';
import '../service/fuel_service.dart';
import '../domain/fuel_record.dart';

import '../../../core/settings/currency_provider.dart';

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
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return ListTile(
                  title: Text('${r.odometer} (Δ: ${r.deltaMileage ?? 0}) - $currency${r.totalCost}'),
                  subtitle: Text('${r.date}\nAmount: ${r.fuelAmount} @ $currency${r.pricePerUnit}/unit\n${r.isFullTank ? "Full fill" : "Partial fill"}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showAddEditSheet(context, ref, r)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await ref.read(fuelServiceProvider).deleteFuelRecord(carId, r.id);
                          ref.invalidate(fuelRecordsProvider(carId));
                        },
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
        onPressed: () => _showAddEditSheet(context, ref),
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
        'date': widget.record?.date ?? DateTime.now().toUtc().toIso8601String(),
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
          const SizedBox(height: 16),
          TextField(controller: _odometerController, decoration: const InputDecoration(labelText: 'Odometer *'), keyboardType: TextInputType.number),
          Row(
            children: [
              Expanded(child: TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount *'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: 16),
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
          const SizedBox(height: 16),
          if (_isLoading) const Center(child: CircularProgressIndicator())
          else ElevatedButton(onPressed: _save, child: const Text('Save Record')),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

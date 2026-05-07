import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/service_provider.dart';
import '../service/service_service.dart';
import '../domain/service_record.dart';

import '../../supply/providers/supply_provider.dart';
import '../../supply/domain/supply_record.dart';

import '../../../core/settings/currency_provider.dart';
import '../../../core/settings/haptics_provider.dart';

class ServiceTab extends ConsumerStatefulWidget {
  final String carId;

  const ServiceTab({super.key, required this.carId});

  @override
  ConsumerState<ServiceTab> createState() => _ServiceTabState();
}

class _ServiceTabState extends ConsumerState<ServiceTab> {
  String _selectedFilter = 'all';

  void _showAddEditSheet(BuildContext context, WidgetRef ref, [ServiceRecord? record]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _ServiceSheet(carId: widget.carId, record: record),
    ).then((_) => ref.read(serviceRecordsProvider(widget.carId).notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final asyncRecords = ref.watch(serviceRecordsProvider(widget.carId));
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      body: asyncRecords.when(
        data: (allRecords) {
          final records = _selectedFilter == 'all' 
              ? allRecords 
              : allRecords.where((r) => r.type == _selectedFilter).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(serviceRecordsProvider(widget.carId).notifier).refresh(),
            child: ListView.builder(
              itemCount: records.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: SegmentedButton<String>(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                      ),
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: 'all', label: Text('All')),
                        ButtonSegment(value: 'service', label: Text('Service')),
                        ButtonSegment(value: 'repair', label: Text('Repair')),
                        ButtonSegment(value: 'upgrade', label: Text('Upgrade')),
                      ],
                      selected: {_selectedFilter},
                      onSelectionChanged: (selection) {
                        setState(() => _selectedFilter = selection.first);
                      },
                    ),
                  );
                }

                if (index == 1) {
                  if (records.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No records found.')));
                  double totalSpend = 0;
                  int totalServices = records.length;
                  
                  for (var r in records) {
                    double partsTotal = 0;
                    for (var s in r.suppliesUsed) {
                      partsTotal += s.quantity * s.pricePerUnit;
                    }
                    totalSpend += r.totalCost + partsTotal;
                  }

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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('TOTAL SPEND', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text('$currency${totalSpend.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('SERVICES', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text('$totalServices', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                }

                final recordIndex = index - 2;
                final r = records[recordIndex];
                final isFirst = recordIndex == 0;
                final isLast = recordIndex == records.length - 1;
                final isDark = Theme.of(context).brightness == Brightness.dark;

                double partsTotal = 0;
                for (var s in r.suppliesUsed) {
                  partsTotal += s.quantity * s.pricePerUnit;
                }
                final grandTotal = r.totalCost + partsTotal;

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
                            border: Border.all(color: isDark ? Colors.white24 : Colors.black26, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: isDark ? Colors.white24 : Colors.black26, width: 1)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${r.type.toUpperCase()} // ${r.date.split("T").first}', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                    Text('ODO: ${r.odometer}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('TOTAL COST', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                        Text('$currency${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    if (r.suppliesUsed.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      const Text('PARTS USED:', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                      const SizedBox(height: 8),
                                      ...r.suppliesUsed.map((s) => Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(s.name),
                                          Text('x${s.quantity} ($currency${(s.quantity * s.pricePerUnit).toStringAsFixed(2)})'),
                                        ],
                                      ))
                                    ],
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
        child: const Icon(Icons.build),
      ),
    );
  }
}

class _ServiceSheet extends ConsumerStatefulWidget {
  final String carId;
  final ServiceRecord? record;

  const _ServiceSheet({required this.carId, this.record});

  @override
  ConsumerState<_ServiceSheet> createState() => _ServiceSheetState();
}

class _ServiceSheetState extends ConsumerState<_ServiceSheet> {
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String _type = 'service';
  bool _insertOdometer = true;
  bool _isLoading = false;

  List<ServiceSupplyItem> _selectedSupplies = [];

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _odometerController.text = widget.record!.odometer.toString();
      _costController.text = widget.record!.totalCost.toString();
      _type = widget.record!.type;
      _notesController.text = widget.record!.notes ?? '';
      _selectedSupplies = List.from(widget.record!.suppliesUsed);
    }
  }

  void _addSupply(List<SupplyRecord> globalSupplies) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Supply'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: globalSupplies.length,
              itemBuilder: (c, i) {
                final s = globalSupplies[i];
                final alreadySelected = _selectedSupplies.where((e) => e.supplyId == s.id).fold(0, (sum, e) => sum + e.quantity);
                final originallyUsed = widget.record?.suppliesUsed.where((e) => e.supplyId == s.id).fold(0, (sum, e) => sum + e.quantity) ?? 0;
                final available = s.quantity + originallyUsed - alreadySelected;

                return ListTile(
                  title: Text(s.name),
                  subtitle: Text('Available: $available'),
                  onTap: available > 0 ? () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedSupplies.add(ServiceSupplyItem(supplyId: s.id, name: s.name, quantity: 1, pricePerUnit: s.pricePerUnit));
                    });
                  } : null,
                );
              },
            ),
          ),
        );
      }
    );
  }

  Future<void> _save() async {
    if (_odometerController.text.isEmpty || _costController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'date': _selectedDate != null ? _selectedDate!.toUtc().toIso8601String() : widget.record?.date ?? DateTime.now().toUtc().toIso8601String(),
        'odometer': int.tryParse(_odometerController.text) ?? 0,
        'total_cost': double.tryParse(_costController.text) ?? 0.0,
        'type': _type,
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text.trim(),
        'supplies_used': _selectedSupplies.map((e) => e.toJson()).toList(),
        if (widget.record == null) 'insert_odometer_record': _insertOdometer,
      };

      if (widget.record == null) {
        await ref.read(serviceServiceProvider).createServiceRecord(carId: widget.carId, data: data);
      } else {
        await ref.read(serviceServiceProvider).updateServiceRecord(carId: widget.carId, recordId: widget.record!.id, data: data);
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
    final asyncSupplies = ref.watch(supplyRecordsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: ListView(
          controller: scrollController,
          children: [
            Text(widget.record == null ? 'Add Service Record' : 'Edit Service Record', style: const TextStyle(fontSize: 20)),
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
            const SizedBox(height: 16),
            SegmentedButton<String>(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'service', label: Text('Service')),
                ButtonSegment(value: 'repair', label: Text('Repair')),
                ButtonSegment(value: 'upgrade', label: Text('Upgrade')),
              ],
              selected: {_type},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _type = newSelection.first);
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: TextField(controller: _odometerController, decoration: const InputDecoration(labelText: 'Odometer *'), keyboardType: TextInputType.number)),
                const SizedBox(width: 24),
                Expanded(child: TextField(controller: _costController, decoration: const InputDecoration(labelText: 'Total Cost *'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              ],
            ),
            const SizedBox(height: 16),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 24),
            const Text('PARTS USED:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._selectedSupplies.asMap().entries.map((entry) {
              final idx = entry.key;
              final s = entry.value;
              return Row(
                children: [
                  Expanded(child: Text(s.name)),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      setState(() {
                        if (s.quantity > 1) {
                          _selectedSupplies[idx] = ServiceSupplyItem(supplyId: s.supplyId, name: s.name, quantity: s.quantity - 1, pricePerUnit: s.pricePerUnit);
                        } else {
                          _selectedSupplies.removeAt(idx);
                        }
                      });
                    },
                  ),
                  Text('${s.quantity}'),
                  asyncSupplies.when(
                    data: (globalSupplies) {
                      final gs = globalSupplies.firstWhere((x) => x.id == s.supplyId, orElse: () => SupplyRecord(id: '', name: '', quantity: 0, isTool: false, pricePerUnit: 0));
                      final originallyUsed = widget.record?.suppliesUsed.where((e) => e.supplyId == s.supplyId).fold(0, (sum, e) => sum + e.quantity) ?? 0;
                      final available = gs.quantity + originallyUsed - s.quantity;
                      return IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: available > 0 ? () {
                          setState(() {
                            _selectedSupplies[idx] = ServiceSupplyItem(supplyId: s.supplyId, name: s.name, quantity: s.quantity + 1, pricePerUnit: s.pricePerUnit);
                          });
                        } : null,
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              );
            }),
            asyncSupplies.when(
              data: (globalSupplies) => TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Part'),
                onPressed: () => _addSupply(globalSupplies),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading supplies: $e'),
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
                    await ref.read(serviceServiceProvider).deleteServiceRecord(widget.carId, widget.record!.id);
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text('Delete Record'),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

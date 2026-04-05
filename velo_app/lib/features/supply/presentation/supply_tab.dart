import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/supply_provider.dart';
import '../service/supply_service.dart';
import '../domain/supply_record.dart';

import '../../../core/settings/currency_provider.dart';
import '../../../core/settings/haptics_provider.dart';

class SupplyTab extends ConsumerWidget {
  const SupplyTab({super.key});

  void _showAddEditSheet(BuildContext context, WidgetRef ref, [SupplyRecord? record]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SupplySheet(record: record),
    ).then((_) => ref.read(supplyRecordsProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecords = ref.watch(supplyRecordsProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      body: asyncRecords.when(
        data: (records) {
          if (records.isEmpty) return const Center(child: Text('No supply records.'));
          return RefreshIndicator(
            onRefresh: () => ref.read(supplyRecordsProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 24, right: 16, left: 16, top: index == 0 ? 16 : 0),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: Text(r.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5))),
                              if (r.isTool) const Icon(Icons.build, size: 20, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('QUANTITY', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text('${r.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PRICE', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text('$currency${r.pricePerUnit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('VENDOR', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text(r.vendor?.toUpperCase() ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          if (r.partNumber != null) ...[
                            const SizedBox(height: 24),
                            Text('PART#: ${r.partNumber}'),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
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
                  ],
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
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SupplySheet extends ConsumerStatefulWidget {
  final SupplyRecord? record;

  const _SupplySheet({this.record});

  @override
  ConsumerState<_SupplySheet> createState() => _SupplySheetState();
}

class _SupplySheetState extends ConsumerState<_SupplySheet> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _vendorController = TextEditingController();
  final _partController = TextEditingController();
  bool _isTool = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _nameController.text = widget.record!.name;
      _qtyController.text = widget.record!.quantity.toString();
      _priceController.text = widget.record!.pricePerUnit.toString();
      _vendorController.text = widget.record!.vendor ?? '';
      _partController.text = widget.record!.partNumber ?? '';
      _isTool = widget.record!.isTool;
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text.trim(),
        'quantity': int.tryParse(_qtyController.text) ?? 1,
        'price_per_unit': double.tryParse(_priceController.text) ?? 0.0,
        if (_vendorController.text.isNotEmpty) 'vendor': _vendorController.text.trim(),
        if (_partController.text.isNotEmpty) 'part_number': _partController.text.trim(),
        'is_tool': _isTool,
      };

      if (widget.record == null) {
        await ref.read(supplyServiceProvider).createRecord(data);
      } else {
        await ref.read(supplyServiceProvider).updateRecord(widget.record!.id, data);
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
        left: 24, right: 24, top: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.record == null ? 'Add Supply' : 'Edit Supply', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 24),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name *')),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: TextField(controller: _qtyController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number)),
              const SizedBox(width: 24),
              Expanded(child: TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price/Unit'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: TextField(controller: _vendorController, decoration: const InputDecoration(labelText: 'Vendor'))),
              const SizedBox(width: 24),
              Expanded(child: TextField(controller: _partController, decoration: const InputDecoration(labelText: 'Part #'))),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Is Tool?'),
            value: _isTool,
            onChanged: (v) => setState(() => _isTool = v),
          ),
          const SizedBox(height: 32),
          if (_isLoading) const Center(child: CircularProgressIndicator())
          else ElevatedButton(onPressed: _save, child: const Text('Save')),
          if (widget.record != null && !_isLoading) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1), foregroundColor: Colors.redAccent),
              onPressed: () async {
                ref.read(hapticsConfigProvider.notifier).heavy();
                setState(() => _isLoading = true);
                try {
                  await ref.read(supplyServiceProvider).deleteRecord(widget.record!.id);
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
    );
  }
}

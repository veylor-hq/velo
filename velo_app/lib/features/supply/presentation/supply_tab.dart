import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/supply_provider.dart';
import '../service/supply_service.dart';
import '../domain/supply_record.dart';

import '../../../core/settings/currency_provider.dart';

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
                return ListTile(
                  title: Text(r.name),
                  subtitle: Text('Qty: ${r.quantity} @ $currency${r.pricePerUnit}\nVendor: ${r.vendor ?? "N/A"}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showAddEditSheet(context, ref, r)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await ref.read(supplyServiceProvider).deleteRecord(r.id);
                          ref.invalidate(supplyRecordsProvider);
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
        'is_tool': _isTool,
      };

      if (widget.record == null) {
        await ref.read(supplyServiceProvider).createRecord(data);
      } else {
        await ref.read(supplyServiceProvider).updateRecord(widget.record!.id, data);
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
          Text(widget.record == null ? 'Add Supply' : 'Edit Supply', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name *')),
          Row(
            children: [
              Expanded(child: TextField(controller: _qtyController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price/Unit'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ],
          ),
          TextField(controller: _vendorController, decoration: const InputDecoration(labelText: 'Vendor')),
          SwitchListTile(
            title: const Text('Is Tool?'),
            value: _isTool,
            onChanged: (v) => setState(() => _isTool = v),
          ),
          const SizedBox(height: 24),
          if (_isLoading) const Center(child: CircularProgressIndicator())
          else ElevatedButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

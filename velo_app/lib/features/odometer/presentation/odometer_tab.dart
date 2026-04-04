import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/odometer_provider.dart';
import '../service/odometer_service.dart';
import '../domain/odometer_record.dart';

class OdometerTab extends ConsumerWidget {
  final String carId;

  const OdometerTab({super.key, required this.carId});

  void _showAddEditSheet(BuildContext context, WidgetRef ref, [OdometerRecord? record]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _OdometerSheet(carId: carId, record: record),
    ).then((_) => ref.read(odometerRecordsProvider(carId).notifier).refresh());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecords = ref.watch(odometerRecordsProvider(carId));

    return Scaffold(
      body: asyncRecords.when(
        data: (records) {
          if (records.isEmpty) return const Center(child: Text('No odometer records.'));
          return RefreshIndicator(
            onRefresh: () => ref.read(odometerRecordsProvider(carId).notifier).refresh(),
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return ListTile(
                  title: Text('${r.odometer}'),
                  subtitle: Text('${r.date}\n${r.notes ?? ""}'),
                  isThreeLine: r.notes != null && r.notes!.isNotEmpty,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showAddEditSheet(context, ref, r)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await ref.read(odometerServiceProvider).deleteRecord(carId, r.id);
                          ref.invalidate(odometerRecordsProvider(carId));
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

class _OdometerSheet extends ConsumerStatefulWidget {
  final String carId;
  final OdometerRecord? record;

  const _OdometerSheet({required this.carId, this.record});

  @override
  ConsumerState<_OdometerSheet> createState() => _OdometerSheetState();
}

class _OdometerSheetState extends ConsumerState<_OdometerSheet> {
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _odometerController.text = widget.record!.odometer.toString();
      _notesController.text = widget.record!.notes ?? '';
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final data = {
        'date': widget.record?.date ?? DateTime.now().toUtc().toIso8601String(),
        'odometer': int.tryParse(_odometerController.text) ?? 0,
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
      };

      if (widget.record == null) {
        await ref.read(odometerServiceProvider).createRecord(widget.carId, data);
      } else {
        await ref.read(odometerServiceProvider).updateRecord(widget.carId, widget.record!.id, data);
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
          Text(widget.record == null ? 'Add Record' : 'Edit Record', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          TextField(controller: _odometerController, decoration: const InputDecoration(labelText: 'Odometer'), keyboardType: TextInputType.number),
          TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes')),
          const SizedBox(height: 24),
          if (_isLoading) const Center(child: CircularProgressIndicator())
          else ElevatedButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

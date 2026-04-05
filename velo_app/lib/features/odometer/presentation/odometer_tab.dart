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
                final isFirst = index == 0;
                final isLast = index == records.length - 1;
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
                          margin: const EdgeInsets.only(bottom: 24, right: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(r.date.split("T").first, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                  Text('${r.odometer}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              if (r.notes != null && r.notes!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(r.notes!),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _showAddEditSheet(context, ref, r)),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () async {
                                      await ref.read(odometerServiceProvider).deleteRecord(carId, r.id);
                                      ref.invalidate(odometerRecordsProvider(carId));
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

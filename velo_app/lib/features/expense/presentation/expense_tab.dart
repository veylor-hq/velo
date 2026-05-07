import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/expense_provider.dart';
import '../service/expense_service.dart';
import '../domain/expense_record.dart';

import '../../../core/settings/currency_provider.dart';
import '../../../core/settings/haptics_provider.dart';

class ExpenseTab extends ConsumerStatefulWidget {
  final String carId;

  const ExpenseTab({super.key, required this.carId});

  @override
  ConsumerState<ExpenseTab> createState() => _ExpenseTabState();
}

class _ExpenseTabState extends ConsumerState<ExpenseTab> {
  String _selectedFilter = 'all';

  void _showAddEditSheet(BuildContext context, WidgetRef ref, [ExpenseRecord? record]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _ExpenseSheet(carId: widget.carId, record: record),
    ).then((_) => ref.read(expenseRecordsProvider(widget.carId).notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final asyncRecords = ref.watch(expenseRecordsProvider(widget.carId));
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      body: asyncRecords.when(
        data: (allRecords) {
          final records = _selectedFilter == 'all'
              ? allRecords
              : allRecords.where((r) => r.type == _selectedFilter).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(expenseRecordsProvider(widget.carId).notifier).refresh(),
            child: ListView.builder(
              itemCount: records.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<String>(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                        ),
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: 'all', label: Text('All')),
                          ButtonSegment(value: 'insurance', label: Text('Insurance')),
                          ButtonSegment(value: 'tax', label: Text('Tax')),
                          ButtonSegment(value: 'parking', label: Text('Parking')),
                          ButtonSegment(value: 'fine', label: Text('Fine')),
                          ButtonSegment(value: 'toll', label: Text('Toll')),
                          ButtonSegment(value: 'other', label: Text('Other')),
                        ],
                        selected: {_selectedFilter},
                        onSelectionChanged: (selection) {
                          setState(() => _selectedFilter = selection.first);
                        },
                      ),
                    ),
                  );
                }

                if (index == 1) {
                  if (records.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No records found.')));
                  double totalSpend = 0;
                  int totalRecords = records.length;
                  for (var r in records) {
                    totalSpend += r.amount;
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
                                const Text('EXPENSES', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text('$totalRecords', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                                        const Text('AMOUNT', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                                        Text('$currency${r.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    if (r.photoUrl != null) ...[
                                      const SizedBox(height: 16),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => Dialog(
                                              backgroundColor: Colors.transparent,
                                              insetPadding: EdgeInsets.zero,
                                              child: Stack(
                                                children: [
                                                  InteractiveViewer(
                                                    panEnabled: true,
                                                    minScale: 0.5,
                                                    maxScale: 4,
                                                    child: Center(child: Image.network(r.photoUrl!, fit: BoxFit.contain)),
                                                  ),
                                                  Positioned(
                                                    top: 40,
                                                    right: 20,
                                                    child: IconButton(
                                                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                                      onPressed: () => Navigator.pop(ctx),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: 120,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
                                            image: DecorationImage(
                                              image: NetworkImage(r.photoUrl!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExpenseSheet extends ConsumerStatefulWidget {
  final String carId;
  final ExpenseRecord? record;

  const _ExpenseSheet({required this.carId, this.record});

  @override
  ConsumerState<_ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends ConsumerState<_ExpenseSheet> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String _type = 'other';
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _amountController.text = widget.record!.amount.toString();
      _type = widget.record!.type;
      _notesController.text = widget.record!.notes ?? '';
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _save() async {
    if (_amountController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'date': _selectedDate != null ? _selectedDate!.toUtc().toIso8601String() : widget.record?.date ?? DateTime.now().toUtc().toIso8601String(),
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'type': _type,
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text.trim(),
      };

      if (widget.record == null) {
        await ref.read(expenseServiceProvider).createExpenseRecord(carId: widget.carId, data: data, photoPath: _selectedImage?.path);
      } else {
        await ref.read(expenseServiceProvider).updateExpenseRecord(carId: widget.carId, recordId: widget.record!.id, data: data, photoPath: _selectedImage?.path);
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
            Text(widget.record == null ? 'Add Expense' : 'Edit Expense', style: const TextStyle(fontSize: 20)),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'insurance', label: Text('Insurance')),
                  ButtonSegment(value: 'tax', label: Text('Tax')),
                  ButtonSegment(value: 'parking', label: Text('Parking')),
                  ButtonSegment(value: 'fine', label: Text('Fine')),
                  ButtonSegment(value: 'toll', label: Text('Toll')),
                  ButtonSegment(value: 'other', label: Text('Other')),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _type = newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 24),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount *'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey[200],
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : widget.record?.photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(widget.record!.photoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: (_selectedImage == null && widget.record?.photoUrl == null)
                    ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading) const Center(child: CircularProgressIndicator())
            else ElevatedButton(onPressed: _save, child: const Text('Save Expense')),
            if (widget.record != null && !_isLoading) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1), foregroundColor: Colors.redAccent),
                onPressed: () async {
                  ref.read(hapticsConfigProvider.notifier).heavy();
                  setState(() => _isLoading = true);
                  try {
                    await ref.read(expenseServiceProvider).deleteExpenseRecord(widget.carId, widget.record!.id);
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text('Delete Expense'),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

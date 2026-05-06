import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/car.dart';
import '../providers/cars_provider.dart';
import '../service/car_service.dart';

class CreateEditCarSheet extends ConsumerStatefulWidget {
  final Car? carToEdit;

  const CreateEditCarSheet({super.key, this.carToEdit});

  static Future<void> show(BuildContext context, {Car? car}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateEditCarSheet(carToEdit: car),
      ),
    );
  }

  @override
  ConsumerState<CreateEditCarSheet> createState() => _CreateEditCarSheetState();
}

class _CreateEditCarSheetState extends ConsumerState<CreateEditCarSheet> {
  final _plateController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _vinController = TextEditingController();
  final _odometerController = TextEditingController();
  String _odometerUnit = 'km';
  String _fuelUnit = 'l';

  final _priceBoughtController = TextEditingController();
  final _priceSoldController = TextEditingController();
  DateTime? _dateBought;
  DateTime? _dateSold;

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.carToEdit != null) {
      final c = widget.carToEdit!;
      _plateController.text = c.licensePlate;
      _makeController.text = c.make ?? '';
      _modelController.text = c.model ?? '';
      _yearController.text = c.year?.toString() ?? '';
      _colorController.text = c.color ?? '';
      _vinController.text = c.vin ?? '';
      _odometerController.text = c.currentOdometer?.toString() ?? '0';
      _odometerUnit = c.odometerUnit ?? 'km';
      _fuelUnit = c.fuelUnit ?? 'l';
      if (c.salesMeta != null) {
        _priceBoughtController.text = c.salesMeta!.priceBought?.toString() ?? '';
        _priceSoldController.text = c.salesMeta!.priceSold?.toString() ?? '';
        _dateBought = c.salesMeta!.dateBought != null ? DateTime.tryParse(c.salesMeta!.dateBought!) : null;
        _dateSold = c.salesMeta!.dateSold != null ? DateTime.tryParse(c.salesMeta!.dateSold!) : null;
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (_plateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('License plate is required')),
      );
      return;
    }

    if (widget.carToEdit == null && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo is required for a new car')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'license_plate': _plateController.text.trim(),
        if (_makeController.text.isNotEmpty) 'make': _makeController.text.trim(),
        if (_modelController.text.isNotEmpty) 'model': _modelController.text.trim(),
        if (_yearController.text.isNotEmpty) 'year': int.tryParse(_yearController.text),
        if (_colorController.text.isNotEmpty) 'color': _colorController.text.trim(),
        if (_vinController.text.isNotEmpty) 'vin': _vinController.text.trim(),
        'odometer_unit': _odometerUnit,
        'fuel_unit': _fuelUnit,
        'initial_odometer': int.tryParse(_odometerController.text) ?? 0,
      };

      final salesMeta = {
        if (_priceBoughtController.text.isNotEmpty) 'price_bought': double.tryParse(_priceBoughtController.text),
        if (_priceSoldController.text.isNotEmpty) 'price_sold': double.tryParse(_priceSoldController.text),
        if (_dateBought != null) 'date_bought': _dateBought!.toUtc().toIso8601String(),
        if (_dateSold != null) 'date_sold': _dateSold!.toUtc().toIso8601String(),
      };
      
      if (salesMeta.isNotEmpty) {
        data['sales_meta'] = salesMeta;
      }

      if (widget.carToEdit == null) {
        await ref.read(carServiceProvider).createCar(
              data: data,
              photoPath: _selectedImage!.path,
            );
      } else {
        await ref.read(carServiceProvider).updateCar(
              id: widget.carToEdit!.id,
              data: data,
              photoPath: _selectedImage?.path,
            );
      }

      await ref.read(carsProvider.notifier).refreshCars();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.carToEdit == null ? 'Car added' : 'Car updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.carToEdit == null ? 'Add Car' : 'Edit Car',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : widget.carToEdit?.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(widget.carToEdit!.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
              child: (_selectedImage == null && widget.carToEdit?.photoUrl == null)
                  ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _plateController,
            decoration: const InputDecoration(labelText: 'License Plate *'),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: _makeController, decoration: const InputDecoration(labelText: 'Make'))),
              const SizedBox(width: 24),
              Expanded(child: TextField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model'))),
            ],
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: _yearController, decoration: const InputDecoration(labelText: 'Year'), keyboardType: TextInputType.number)),
              const SizedBox(width: 24),
              Expanded(child: TextField(controller: _colorController, decoration: const InputDecoration(labelText: 'Color'))),
            ],
          ),
          TextField(
            controller: _vinController,
            decoration: const InputDecoration(labelText: 'VIN'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _odometerController,
                  decoration: InputDecoration(labelText: widget.carToEdit == null ? 'Initial Odometer' : 'Current Odometer'),
                  keyboardType: TextInputType.number,
                  enabled: widget.carToEdit == null,
                ),
              ),
              const SizedBox(width: 24),
              DropdownButton<String>(
                value: _odometerUnit,
                items: const [
                  DropdownMenuItem(value: 'km', child: Text('KM')),
                  DropdownMenuItem(value: 'mi', child: Text('Miles')),
                ],
                onChanged: (v) => setState(() => _odometerUnit = v ?? 'km'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Fuel Unit: '),
              const SizedBox(width: 24),
              DropdownButton<String>(
                value: _fuelUnit,
                items: const [
                  DropdownMenuItem(value: 'l', child: Text('Liters')),
                  DropdownMenuItem(value: 'gal', child: Text('Gallons')),
                ],
                onChanged: (v) => setState(() => _fuelUnit = v ?? 'l'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('SALES META', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date Bought', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(_dateBought != null ? _dateBought!.toLocal().toString().split(' ')[0] : 'Not set'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dateBought ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _dateBought = picked);
                  },
                ),
              ),
              Expanded(child: TextField(controller: _priceBoughtController, decoration: const InputDecoration(labelText: 'Price Bought'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date Sold', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(_dateSold != null ? _dateSold!.toLocal().toString().split(' ')[0] : 'Not set'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dateSold ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _dateSold = picked);
                  },
                ),
              ),
              Expanded(child: TextField(controller: _priceSoldController, decoration: const InputDecoration(labelText: 'Price Sold'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ],
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Car'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _vinController.dispose();
    _odometerController.dispose();
    _priceBoughtController.dispose();
    _priceSoldController.dispose();
    super.dispose();
  }
}

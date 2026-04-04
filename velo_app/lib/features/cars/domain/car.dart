class CarSalesMeta {
  final double? priceBought;
  final double? priceSold;
  final String? dateBought;
  final String? dateSold;

  CarSalesMeta({
    this.priceBought,
    this.priceSold,
    this.dateBought,
    this.dateSold,
  });

  factory CarSalesMeta.fromJson(Map<String, dynamic> json) {
    return CarSalesMeta(
      priceBought: json['price_bought'] != null ? (json['price_bought'] as num).toDouble() : null,
      priceSold: json['price_sold'] != null ? (json['price_sold'] as num).toDouble() : null,
      dateBought: json['date_bought'] as String?,
      dateSold: json['date_sold'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (priceBought != null) 'price_bought': priceBought,
      if (priceSold != null) 'price_sold': priceSold,
      if (dateBought != null) 'date_bought': dateBought,
      if (dateSold != null) 'date_sold': dateSold,
    };
  }
}

class Car {
  final String id;
  final String licensePlate;
  final String? photoUrl; // From get individual car
  final String? photoFilename; // From list cars
  
  final String? make;
  final String? model;
  final int? year;
  final String? color;
  final String? vin;
  final String? odometerUnit;
  final String? fuelUnit;
  final int? currentOdometer;
  final CarSalesMeta? salesMeta;

  Car({
    required this.id,
    required this.licensePlate,
    this.photoUrl,
    this.photoFilename,
    this.make,
    this.model,
    this.year,
    this.color,
    this.vin,
    this.odometerUnit,
    this.fuelUnit,
    this.currentOdometer,
    this.salesMeta,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as String,
      licensePlate: json['license_plate'] as String,
      photoUrl: json['photo_url'] as String?,
      photoFilename: json['photo_filename'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      color: json['color'] as String?,
      vin: json['vin'] as String?,
      odometerUnit: json['odometer_unit'] as String?,
      fuelUnit: json['fuel_unit'] as String?,
      currentOdometer: json['current_odometer'] as int?,
      salesMeta: json['sales_meta'] != null ? CarSalesMeta.fromJson(json['sales_meta'] as Map<String, dynamic>) : null,
    );
  }
}

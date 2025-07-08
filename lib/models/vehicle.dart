class Vehicle {
  final String id;
  final String name;
  final int year;
  final int km;
  final String fuelType;
  final String transmission;
  final double price;
  final String location;
  final List<String> images;
  final double emi;
  final bool assured;
  final bool testDriveAvailable;

  Vehicle({
    required this.id,
    required this.name,
    required this.year,
    required this.km,
    required this.fuelType,
    required this.transmission,
    required this.price,
    required this.location,
    required this.images,
    required this.emi,
    required this.assured,
    required this.testDriveAvailable,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      name: json['name'],
      year: json['year'],
      km: json['km'],
      fuelType: json['fuelType'],
      transmission: json['transmission'],
      price: (json['price'] as num).toDouble(),
      location: json['location'],
      images: List<String>.from(json['images'] ?? []),
      emi: (json['emi'] as num).toDouble(),
      assured: json['assured'] ?? false,
      testDriveAvailable: json['testDriveAvailable'] ?? false,
    );
  }
}

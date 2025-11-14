class Vehicle {
  final String id;
  final String name;
  final String model;
  final double price;
  final String description;
  final List<String> imageUrls;
  final List<String> tags;
  final String location;
  final String? fuelType;
  final String? transmission;
  final int? registrationYear;
  final int? kmDriven;
  final String? owner;
  final String? rto;
  final String? color;
  final String? mileage;
  final int? seatingCapacity;
  final String? bodyType;
  final int? airbags;
  final bool? abs;
  final bool? infotainmentSystem;
  final String? ac;
  final bool? rearParkingCamera;
  final bool? sunroof;
  final bool? alloyWheels;
  final String? batteryHealth;
  final String? tireCondition;
  final String? brakeCondition;
  final String? engineCondition;
  final String? steering;
  final String? suspension;
  final bool? insurance;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.name,
    required this.model,
    required this.price,
    required this.description,
    required this.imageUrls,
    required this.tags,
    required this.location,
    this.fuelType,
    this.transmission,
    this.registrationYear,
    this.kmDriven,
    this.owner,
    this.rto,
    this.color,
    this.mileage,
    this.seatingCapacity,
    this.bodyType,
    this.airbags,
    this.abs,
    this.infotainmentSystem,
    this.ac,
    this.rearParkingCamera,
    this.sunroof,
    this.alloyWheels,
    this.batteryHealth,
    this.tireCondition,
    this.brakeCondition,
    this.engineCondition,
    this.steering,
    this.suspension,
    this.insurance,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      location: json['location'] ?? '',
      fuelType: json['fuelType'],
      transmission: json['transmission'],
      registrationYear: json['registrationYear'],
      kmDriven: json['kmDriven'],
      owner: json['owner'],
      rto: json['rto'],
      color: json['color'],
      mileage: json['mileage'],
      seatingCapacity: json['seatingCapacity'],
      bodyType: json['bodyType'],
      airbags: json['airbags'],
      abs: json['abs'],
      infotainmentSystem: json['infotainmentSystem'],
      ac: json['ac'],
      rearParkingCamera: json['rearParkingCamera'],
      sunroof: json['sunroof'],
      alloyWheels: json['alloyWheels'],
      batteryHealth: json['batteryHealth'],
      tireCondition: json['tireCondition'],
      brakeCondition: json['brakeCondition'],
      engineCondition: json['engineCondition'],
      steering: json['steering'],
      suspension: json['suspension'],
      insurance: json['insurance'],
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'model': model,
      'price': price,
      'description': description,
      'imageUrls': imageUrls,
      'tags': tags,
      'location': location,
      'fuelType': fuelType,
      'transmission': transmission,
      'registrationYear': registrationYear,
      'kmDriven': kmDriven,
      'owner': owner,
      'rto': rto,
      'color': color,
      'mileage': mileage,
      'seatingCapacity': seatingCapacity,
      'bodyType': bodyType,
      'airbags': airbags,
      'abs': abs,
      'infotainmentSystem': infotainmentSystem,
      'ac': ac,
      'rearParkingCamera': rearParkingCamera,
      'sunroof': sunroof,
      'alloyWheels': alloyWheels,
      'batteryHealth': batteryHealth,
      'tireCondition': tireCondition,
      'brakeCondition': brakeCondition,
      'engineCondition': engineCondition,
      'steering': steering,
      'suspension': suspension,
      'insurance': insurance,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';
  String get yearAndKm => '${registrationYear ?? 'N/A'} • ${kmDriven ?? 0} km';
}
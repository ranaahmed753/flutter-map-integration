import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String item;
  final int quantity;
  final int price;
  final LatLng pickupLocation;
  final LatLng deliveryLocation;
  final String pickupAddress;
  final String deliveryAddress;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.item,
    required this.quantity,
    required this.price,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupAddress,
    required this.deliveryAddress,
  });

  // Factory constructor to create OrderModel from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      item: json['item'] as String,
      quantity: json['quantity'] as int,
      price: json['price'] as int,
      pickupLocation: LatLng(
        json['pickupLocation']['latitude'] as double,
        json['pickupLocation']['longitude'] as double,
      ),
      deliveryLocation: LatLng(
        json['deliveryLocation']['latitude'] as double,
        json['deliveryLocation']['longitude'] as double,
      ),
      pickupAddress: json['pickupAddress'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
    );
  }

  // Method to convert OrderModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'item': item,
      'quantity': quantity,
      'price': price,
      'pickupLocation': {
        'latitude': pickupLocation.latitude,
        'longitude': pickupLocation.longitude,
      },
      'deliveryLocation': {
        'latitude': deliveryLocation.latitude,
        'longitude': deliveryLocation.longitude,
      },
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
    };
  }

  // CopyWith method for creating modified copies
  OrderModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? item,
    int? quantity,
    int? price,
    LatLng? pickupLocation,
    LatLng? deliveryLocation,
    String? pickupAddress,
    String? deliveryAddress,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    );
  }
}

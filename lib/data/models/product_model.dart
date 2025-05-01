import 'package:equatable/equatable.dart';

/// A model class representing a product with its details
class ProductModel extends Equatable {
  final String id;
  final String name;
  final String image;
  final String price;
  final String rate;
  final String rateCount;
  final String? description;

  ProductModel({
    String? id,
    required this.name,
    required this.image,
    required this.price,
    required this.rate,
    required this.rateCount,
    this.description,
  }) : id = id ?? name.toLowerCase().replaceAll(' ', '_'),
       assert(name.isNotEmpty, 'Product name cannot be empty'),
       assert(image.isNotEmpty, 'Product image path cannot be empty'),
       assert(double.tryParse(price) != null, 'Invalid price format'),
       assert(
         double.tryParse(rate) != null &&
             double.parse(rate) <= 5 &&
             double.parse(rate) >= 0,
         'Rate must be a number between 0 and 5',
       ),
       assert(int.tryParse(rateCount) != null, 'Rate count must be a number');

  /// Convert price string to double
  double get priceAsDouble => double.parse(price);

  /// Convert rate string to double
  double get rateAsDouble => double.parse(rate);

  /// Convert rate count string to integer
  int get rateCountAsInt => int.parse(rateCount);

  /// Calculate discounted price (20% off)
  double get discountedPrice => priceAsDouble * 0.8;

  /// Format discounted price as string with 2 decimal places
  String get discountedPriceString => discountedPrice.toStringAsFixed(2);

  /// Check if product is on sale
  bool get isOnSale => true; // All products are on sale for now

  @override
  List<Object> get props => [id, name, image, price, rate, rateCount];

  // Create a copy of this ProductModel with the given fields replaced
  ProductModel copyWith({
    String? id,
    String? name,
    String? image,
    String? price,
    String? rate,
    String? rateCount,
    String? description,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      rate: rate ?? this.rate,
      rateCount: rateCount ?? this.rateCount,
      description: description ?? this.description,
    );
  }
}

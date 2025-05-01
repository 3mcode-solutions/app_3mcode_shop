/// A model class representing a product category
class CategoryModel {
  final String name;
  final String image;

  CategoryModel({required this.name, required this.image}) {
    if (name.isEmpty) throw ArgumentError('Category name cannot be empty');
    if (image.isEmpty)
      throw ArgumentError('Category image path cannot be empty');
  }
}

/// A model class representing a product with its details
class ProductModel {
  final String name;
  final String image;
  final String price;
  final String rate;
  final String rateCount;

  ProductModel({
    required this.name,
    required this.image,
    required this.price,
    required this.rate,
    required this.rateCount,
  }) {
    if (name.isEmpty) throw ArgumentError('Product name cannot be empty');
    if (image.isEmpty)
      throw ArgumentError('Product image path cannot be empty');
    if (double.tryParse(price) == null)
      throw ArgumentError('Invalid price format');
    if (double.tryParse(rate) == null ||
        double.parse(rate) > 5 ||
        double.parse(rate) < 0) {
      throw ArgumentError('Rate must be a number between 0 and 5');
    }
    if (int.tryParse(rateCount) == null)
      throw ArgumentError('Rate count must be a number');
  }

  /// Convert price string to double
  double get priceAsDouble => double.parse(price);

  /// Convert rate string to double
  double get rateAsDouble => double.parse(rate);

  /// Convert rate count string to integer
  int get rateCountAsInt => int.parse(rateCount);
}

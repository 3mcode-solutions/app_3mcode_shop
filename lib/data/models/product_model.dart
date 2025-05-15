import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/woo_models/woo_product_model.dart';

/// A model class representing a product with its details
class ProductModel extends Equatable {
  final String id;
  final String name;
  final String image;
  final String price;
  final String rate;
  final String rateCount;
  final String? description;
  final String category;
  final bool isOnSaleFlag;
  final String discountPercentage;
  final List<String> images;
  final List<Map<String, dynamic>> attributes;
  final List<Map<String, dynamic>> variations;

  ProductModel({
    String? id,
    required this.name,
    required this.image,
    required this.price,
    required this.rate,
    required this.rateCount,
    this.description,
    this.category = '',
    this.isOnSaleFlag = false,
    this.discountPercentage = '0',
    this.images = const [],
    this.attributes = const [],
    this.variations = const [],
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

  /// Create a ProductModel from a WooProduct
  factory ProductModel.fromWooProduct(WooProduct product) {
    print('🏭 Creating ProductModel from WooProduct: ${product.name}');
    print('🖼️ Images count: ${product.images.length}');

    String imageUrl = '';
    if (product.images.isNotEmpty) {
      imageUrl = product.images.first.src;
      print('🖼️ Using image URL: $imageUrl');
    } else {
      print('⚠️ No images found for product');
      // Use a default image from assets
      imageUrl = 'assets/fruits/apple.png';
    }

    // تأكد من أن عنوان URL للصورة صحيح
    if (imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http') &&
        !imageUrl.startsWith('assets/')) {
      // إذا كان العنوان نسبيًا، أضف عنوان الموقع الأساسي
      imageUrl = 'https://shop.3mcode-solutions.com$imageUrl';
      print('🔄 Converted relative URL to absolute: $imageUrl');
    }

    return ProductModel(
      id: product.id.toString(),
      name: product.name,
      description: product.description,
      price: product.price,
      image: imageUrl,
      category:
          product.categories.isNotEmpty ? product.categories.first.name : '',
      isOnSaleFlag: product.onSale ?? false,
      discountPercentage: _calculateDiscountPercentage(
        product.regularPrice,
        product.salePrice,
      ),
      rate: product.averageRating ?? '0',
      rateCount: product.ratingCount?.toString() ?? '0',
      images: product.images.map((image) => image.src).toList(),
      attributes:
          product.attributes
              ?.map((attr) => {'name': attr.name, 'options': attr.options})
              .toList() ??
          [],
      variations:
          product.variations?.map((variation) => {'id': variation}).toList() ??
          [],
    );
  }

  /// Calculate discount percentage from regular and sale prices
  static String _calculateDiscountPercentage(
    String? regularPrice,
    String? salePrice,
  ) {
    if (regularPrice == null ||
        salePrice == null ||
        regularPrice.isEmpty ||
        salePrice.isEmpty) {
      return '0';
    }

    final regular = double.tryParse(regularPrice) ?? 0;
    final sale = double.tryParse(salePrice) ?? 0;

    if (regular <= 0 || sale <= 0 || sale >= regular) {
      return '0';
    }

    final discount = ((regular - sale) / regular) * 100;
    return discount.toStringAsFixed(0);
  }

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
  bool get isOnSale => isOnSaleFlag;

  @override
  List<Object> get props => [
    id,
    name,
    image,
    price,
    rate,
    rateCount,
    category,
    isOnSaleFlag,
    discountPercentage,
    images,
    attributes,
    variations,
  ];

  // Create a copy of this ProductModel with the given fields replaced
  ProductModel copyWith({
    String? id,
    String? name,
    String? image,
    String? price,
    String? rate,
    String? rateCount,
    String? description,
    String? category,
    bool? isOnSaleFlag,
    String? discountPercentage,
    List<String>? images,
    List<Map<String, dynamic>>? attributes,
    List<Map<String, dynamic>>? variations,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      rate: rate ?? this.rate,
      rateCount: rateCount ?? this.rateCount,
      description: description ?? this.description,
      category: category ?? this.category,
      isOnSaleFlag: isOnSaleFlag ?? this.isOnSaleFlag,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      images: images ?? this.images,
      attributes: attributes ?? this.attributes,
      variations: variations ?? this.variations,
    );
  }

  // Convert ProductModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'rate': rate,
      'rateCount': rateCount,
      'description': description,
      'category': category,
      'isOnSale': isOnSaleFlag,
      'discountPercentage': discountPercentage,
      'images': images,
      'attributes': attributes,
      'variations': variations,
    };
  }

  // Create ProductModel from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      price: json['price'] as String,
      rate: json['rate'] as String,
      rateCount: json['rateCount'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? '',
      isOnSaleFlag: json['isOnSale'] as bool? ?? false,
      discountPercentage: json['discountPercentage'] as String? ?? '0',
      images: List<String>.from(json['images'] ?? []),
      attributes: List<Map<String, dynamic>>.from(json['attributes'] ?? []),
      variations: List<Map<String, dynamic>>.from(json['variations'] ?? []),
    );
  }
}

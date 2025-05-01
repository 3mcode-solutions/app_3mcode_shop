import 'package:app_3mcode_shop/core/constants/assets_paths.dart';
import 'package:app_3mcode_shop/data/models/models.dart';

/// Class that provides local data for the app
/// This simulates a local database or API responses
class LocalData {
  // Private constructor to prevent instantiation
  LocalData._();

  /// Get list of banner images
  static List<String> getBanners() {
    return [AssetPaths.slider1, AssetPaths.slider2, AssetPaths.slider3];
  }

  /// Get list of categories
  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(name: 'Fruits', image: AssetPaths.fruits),
      CategoryModel(name: 'Milk & Egg', image: AssetPaths.egg),
      CategoryModel(name: 'Beverages', image: AssetPaths.beverages),
      CategoryModel(name: 'Laundry', image: AssetPaths.laundry),
      CategoryModel(name: 'Vegetables', image: AssetPaths.vegetables),
      CategoryModel(name: 'Fresh Fruits', image: AssetPaths.fruits),
      CategoryModel(name: 'Fresh Eggs', image: AssetPaths.egg),
      CategoryModel(name: 'Soft Drinks', image: AssetPaths.beverages),
      CategoryModel(name: 'Cleaning', image: AssetPaths.laundry),
      CategoryModel(name: 'Green Veggies', image: AssetPaths.vegetables),
      CategoryModel(name: 'Organic Fruits', image: AssetPaths.fruits),
      CategoryModel(name: 'Farm Eggs', image: AssetPaths.egg),
      CategoryModel(name: 'Cold Drinks', image: AssetPaths.beverages),
      CategoryModel(name: 'Home Care', image: AssetPaths.laundry),
    ];
  }

  /// Get list of discounted products
  static List<ProductModel> getDiscountedProducts() {
    return [
      ProductModel(
        name: "Premium Banana",
        image: AssetPaths.banana,
        price: "5.99",
        rate: "4.8",
        rateCount: "523",
      ),
      ProductModel(
        name: "Fresh Orange",
        image: AssetPaths.orange,
        price: "4.99",
        rate: "4.7",
        rateCount: "412",
      ),
      ProductModel(
        name: "Organic Egg",
        image: AssetPaths.egg,
        price: "6.99",
        rate: "4.9",
        rateCount: "345",
      ),
      ProductModel(
        name: "Green Papper",
        image: AssetPaths.papper,
        price: "3.99",
        rate: "4.5",
        rateCount: "278",
      ),
      ProductModel(
        name: "Mixed Fruits",
        image: AssetPaths.fruits,
        price: "8.99",
        rate: "4.6",
        rateCount: "189",
      ),
      ProductModel(
        name: "Fresh Vegetables",
        image: AssetPaths.vegetables,
        price: "7.99",
        rate: "4.4",
        rateCount: "234",
      ),
    ];
  }

  /// Get list of best selling products
  static List<ProductModel> getBestSellingProducts() {
    return [
      ProductModel(
        name: "Red Papper",
        image: AssetPaths.papper,
        price: "3.49",
        rate: "4.2",
        rateCount: "645",
      ),
      ProductModel(
        name: "Fresh Banana",
        image: AssetPaths.banana,
        price: "4.99",
        rate: "4.5",
        rateCount: "720",
      ),
      ProductModel(
        name: "Sweet Orange",
        image: AssetPaths.orange,
        price: "2.49",
        rate: "4.7",
        rateCount: "812",
      ),
      ProductModel(
        name: "Farm Egg",
        image: AssetPaths.egg,
        price: "2.99",
        rate: "4.3",
        rateCount: "578",
      ),
      ProductModel(
        name: "Fresh Vegetables",
        image: AssetPaths.vegetables,
        price: "3.99",
        rate: "4.6",
        rateCount: "489",
      ),
      ProductModel(
        name: "Beverages Pack",
        image: AssetPaths.beverages,
        price: "12.99",
        rate: "4.8",
        rateCount: "623",
      ),
    ];
  }

  /// Get list of seasonal products
  static List<ProductModel> getSeasonalProducts() {
    return [
      ProductModel(
        name: "Summer Orange",
        image: AssetPaths.orange,
        price: "3.99",
        rate: "4.6",
        rateCount: "387",
      ),
      ProductModel(
        name: "Seasonal Fruits",
        image: AssetPaths.fruits,
        price: "9.99",
        rate: "4.8",
        rateCount: "287",
      ),
      ProductModel(
        name: "Fresh Vegetables",
        image: AssetPaths.vegetables,
        price: "7.99",
        rate: "4.7",
        rateCount: "347",
      ),
      ProductModel(
        name: "Special Egg Pack",
        image: AssetPaths.egg,
        price: "5.99",
        rate: "4.5",
        rateCount: "267",
      ),
      ProductModel(
        name: "Summer Drinks",
        image: AssetPaths.beverages,
        price: "8.99",
        rate: "4.9",
        rateCount: "427",
      ),
      ProductModel(
        name: "Fresh Banana",
        image: AssetPaths.banana,
        price: "4.99",
        rate: "4.4",
        rateCount: "317",
      ),
    ];
  }

  /// Get list of discover more products
  static List<ProductModel> getDiscoverMoreProducts() {
    return [
      ProductModel(
        name: "Cleaning Kit",
        image: AssetPaths.laundry,
        price: "15.99",
        rate: "4.7",
        rateCount: "187",
      ),
      ProductModel(
        name: "Fruit Basket",
        image: AssetPaths.fruits,
        price: "12.99",
        rate: "4.8",
        rateCount: "237",
      ),
      ProductModel(
        name: "Vegetable Mix",
        image: AssetPaths.vegetables,
        price: "9.99",
        rate: "4.6",
        rateCount: "197",
      ),
      ProductModel(
        name: "Beverage Pack",
        image: AssetPaths.beverages,
        price: "18.99",
        rate: "4.9",
        rateCount: "327",
      ),
      ProductModel(
        name: "Premium Eggs",
        image: AssetPaths.egg,
        price: "7.99",
        rate: "4.5",
        rateCount: "217",
      ),
      ProductModel(
        name: "Organic Banana",
        image: AssetPaths.banana,
        price: "6.99",
        rate: "4.7",
        rateCount: "247",
      ),
    ];
  }

  /// Get list of products
  static List<ProductModel> getProducts() {
    return [
      ProductModel(
        name: "Banana",
        image: AssetPaths.banana,
        price: "3.99",
        rate: "4",
        rateCount: "287",
      ),
      ProductModel(
        name: "Papper",
        image: AssetPaths.papper,
        price: "2.99",
        rate: "4",
        rateCount: "287",
      ),
      ProductModel(
        name: "Orange",
        image: AssetPaths.orange,
        price: "1.99",
        rate: "4",
        rateCount: "287",
      ),
      ProductModel(
        name: "Egg",
        image: AssetPaths.egg,
        price: "1.99",
        rate: "4",
        rateCount: "287",
      ),
      ProductModel(
        name: "Fresh Banana",
        image: AssetPaths.banana,
        price: "4.99",
        rate: "4.5",
        rateCount: "320",
      ),
      ProductModel(
        name: "Red Papper",
        image: AssetPaths.papper,
        price: "3.49",
        rate: "4.2",
        rateCount: "245",
      ),
      ProductModel(
        name: "Sweet Orange",
        image: AssetPaths.orange,
        price: "2.49",
        rate: "4.7",
        rateCount: "412",
      ),
      ProductModel(
        name: "Organic Egg",
        image: AssetPaths.egg,
        price: "2.99",
        rate: "4.3",
        rateCount: "178",
      ),
      ProductModel(
        name: "Premium Banana",
        image: AssetPaths.banana,
        price: "5.99",
        rate: "4.8",
        rateCount: "523",
      ),
      ProductModel(
        name: "Green Papper",
        image: AssetPaths.papper,
        price: "3.29",
        rate: "4.1",
        rateCount: "156",
      ),
      ProductModel(
        name: "Mandarin Orange",
        image: AssetPaths.orange,
        price: "2.79",
        rate: "4.6",
        rateCount: "289",
      ),
      ProductModel(
        name: "Farm Egg",
        image: AssetPaths.egg,
        price: "2.49",
        rate: "4.4",
        rateCount: "198",
      ),
      ProductModel(
        name: "Yellow Banana",
        image: AssetPaths.banana,
        price: "4.49",
        rate: "4.3",
        rateCount: "267",
      ),
      ProductModel(
        name: "Mixed Papper",
        image: AssetPaths.papper,
        price: "3.99",
        rate: "4.5",
        rateCount: "345",
      ),
    ];
  }

  /// Get initial cart items (for demo purposes)
  static List<CartItemModel> getInitialCartItems() {
    final products = getProducts();
    return [
      CartItemModel(product: products[0], quantity: 2),
      CartItemModel(product: products[2], quantity: 1),
      CartItemModel(product: products[4], quantity: 3),
    ];
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/model.dart';
import 'package:app_3mcode_shop/product_item.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> items = [
    "assets/banners/Slider 1.png",
    "assets/banners/Slider 2.png",
    "assets/banners/Slider 3.png",
  ];

  final List<CategoryModel> category = [
    CategoryModel(name: 'Fruits', image: "assets/category/fruits.png"),
    CategoryModel(name: 'Milk & Egg', image: "assets/category/egg.png"),
    CategoryModel(name: 'Beverages', image: "assets/category/beverages.png"),
    CategoryModel(name: 'Laundry', image: "assets/category/laundry.png"),
    // إضافة 10 تصنيفات جديدة
    CategoryModel(name: 'Vegetables', image: "assets/category/vegatbels.png"),
    CategoryModel(name: 'Fresh Fruits', image: "assets/category/fruits.png"),
    CategoryModel(name: 'Fresh Eggs', image: "assets/category/egg.png"),
    CategoryModel(name: 'Soft Drinks', image: "assets/category/beverages.png"),
    CategoryModel(name: 'Cleaning', image: "assets/category/laundry.png"),
    CategoryModel(
      name: 'Green Veggies',
      image: "assets/category/vegatbels.png",
    ),
    CategoryModel(name: 'Organic Fruits', image: "assets/category/fruits.png"),
    CategoryModel(name: 'Farm Eggs', image: "assets/category/egg.png"),
    CategoryModel(name: 'Cold Drinks', image: "assets/category/beverages.png"),
    CategoryModel(name: 'Home Care', image: "assets/category/laundry.png"),
  ];

  final List<ProductModel> product = [
    ProductModel(
      name: "Banana",
      image: "assets/fruits/banana.png",
      price: "3.99",
      rate: "4",
      rateCount: "287",
    ),
    ProductModel(
      name: "Papper",
      image: "assets/fruits/papper.png",
      price: "2.99",
      rate: "4",
      rateCount: "287",
    ),
    ProductModel(
      name: "Orange",
      image: "assets/fruits/orange.png",
      price: "1.99",
      rate: "4",
      rateCount: "287",
    ),
    ProductModel(
      name: "Egg",
      image: "assets/category/egg.png",
      price: "1.99",
      rate: "4",
      rateCount: "287",
    ),
    // Adding 10 more items
    ProductModel(
      name: "Fresh Banana",
      image: "assets/fruits/banana.png",
      price: "4.99",
      rate: "4.5",
      rateCount: "320",
    ),
    ProductModel(
      name: "Red Papper",
      image: "assets/fruits/papper.png",
      price: "3.49",
      rate: "4.2",
      rateCount: "245",
    ),
    ProductModel(
      name: "Sweet Orange",
      image: "assets/fruits/orange.png",
      price: "2.49",
      rate: "4.7",
      rateCount: "412",
    ),
    ProductModel(
      name: "Organic Egg",
      image: "assets/category/egg.png",
      price: "2.99",
      rate: "4.3",
      rateCount: "178",
    ),
    ProductModel(
      name: "Premium Banana",
      image: "assets/fruits/banana.png",
      price: "5.99",
      rate: "4.8",
      rateCount: "523",
    ),
    ProductModel(
      name: "Green Papper",
      image: "assets/fruits/papper.png",
      price: "3.29",
      rate: "4.1",
      rateCount: "156",
    ),
    ProductModel(
      name: "Mandarin Orange",
      image: "assets/fruits/orange.png",
      price: "2.79",
      rate: "4.6",
      rateCount: "289",
    ),
    ProductModel(
      name: "Farm Egg",
      image: "assets/category/egg.png",
      price: "2.49",
      rate: "4.4",
      rateCount: "198",
    ),
    ProductModel(
      name: "Yellow Banana",
      image: "assets/fruits/banana.png",
      price: "4.49",
      rate: "4.3",
      rateCount: "267",
    ),
    ProductModel(
      name: "Mixed Papper",
      image: "assets/fruits/papper.png",
      price: "3.99",
      rate: "4.5",
      rateCount: "345",
    ),
  ];

  List basketList = [
    ProductModel(
      name: "Banana",
      image: "assets/fruits/banana.png",
      price: "3.99",
      rate: "4",
      rateCount: "287",
    ),
    ProductModel(
      name: "Orange",
      image: "assets/fruits/orange.png",
      price: "1.99",
      rate: "4",
      rateCount: "287",
    ),
    ProductModel(
      name: "Papper",
      image: "assets/fruits/papper.png",
      price: "2.99",
      rate: "4",
      rateCount: "287",
    ),
    ProductModel(
      name: "Fresh Banana",
      image: "assets/fruits/banana.png",
      price: "4.99",
      rate: "4.5",
      rateCount: "320",
    ),
    ProductModel(
      name: "Sweet Orange",
      image: "assets/fruits/orange.png",
      price: "2.49",
      rate: "4.7",
      rateCount: "412",
    ),
    ProductModel(
      name: "Red Papper",
      image: "assets/fruits/papper.png",
      price: "3.49",
      rate: "4.2",
      rateCount: "245",
    ),
    ProductModel(
      name: "Premium Banana",
      image: "assets/fruits/banana.png",
      price: "5.99",
      rate: "4.8",
      rateCount: "523",
    ),
    ProductModel(
      name: "Green Papper",
      image: "assets/fruits/papper.png",
      price: "3.29",
      rate: "4.1",
      rateCount: "156",
    ),
  ];

  void toggleSelection(ProductModel product) {
    setState(() {
      if (basketList.contains(product)) {
        basketList.remove(product);
      } else {
        basketList.add(product);
      }
    });
  }

  bool isSelected(ProductModel product) => basketList.contains(product);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox.shrink(),
        leadingWidth: 0,
        title: Row(
          children: [
            SvgPicture.asset("assets/icons/motor.svg"),
            const SizedBox(width: 10),
            const Text("61 Hopper street..", style: TextStyle(fontSize: 19)),
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 34),
            const Spacer(),
            SvgPicture.asset("assets/icons/basket.svg"),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// banner
              CarouselSlider.builder(
                itemCount: items.length,
                itemBuilder:
                    (BuildContext context, int index, int pageViewIndex) =>
                        Image.asset(
                          items[index],
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.error));
                          },
                        ),
                options: CarouselOptions(
                  height: 170,
                  aspectRatio: 1,
                  viewportFraction: 0.6,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(seconds: 3),
                  autoPlayCurve: Curves.linear,
                  enlargeCenterPage: true,
                ),
              ),

              const SizedBox(height: 20),

              /// category
              SizedBox(
                height: 120,
                child: CarouselSlider.builder(
                  itemCount: category.length,
                  itemBuilder: (context, index, pageViewIndex) {
                    final item = category[index];
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          width: 70,
                          height: 70,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              item.image,
                              width: 60,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.error),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 120,
                    viewportFraction: 0.25,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 800,
                    ),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: false,
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// products title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Fruits",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// products
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(product.length, (index) {
                    final item = product[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ProductItem(
                        image: item.image,
                        name: item.name,
                        rate: item.rate,
                        rateCount: item.rateCount,
                        price: item.price,
                        onTap: () => toggleSelection(item),
                        icon:
                            isSelected(item)
                                ? const Icon(Icons.close)
                                : const Icon(Icons.add),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              /// Special offers title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Special Offers",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// Special offers carousel
              CarouselSlider.builder(
                itemCount: product.length ~/ 2,
                itemBuilder: (context, index, pageViewIndex) {
                  final item = product[index];
                  return Container(
                    width: 160,  // تحديد عرض ثابت
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 100,  // تقليل الارتفاع
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  item.image,
                                  height: 70,  // تقليل حجم الصورة
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 14,  // تصغير حجم الخط
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        "\$${item.price}",
                                        style: TextStyle(
                                          fontSize: 16,  // تصغير حجم السعر
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "\$${(double.parse(item.price) * 1.2).toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 12,  // تصغير حجم السعر القديم
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "20% OFF",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,  // تصغير حجم نص الخصم
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 180,  // تقليل الارتفاع الكلي
                  viewportFraction: 0.45,  // تعديل نسبة العرض لتظهر عناصر أكثر
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

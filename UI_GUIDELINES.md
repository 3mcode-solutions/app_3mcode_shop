# إرشادات واجهة المستخدم لتطبيق 3MCode Shop

<p align="center">
  <img src="assets/logo/logo.svg" alt="3MCode Shop Logo" width="150"/>
</p>

<p align="center">
  <a href="#design-system">نظام التصميم</a> •
  <a href="#components">المكونات</a> •
  <a href="#screens">الشاشات</a> •
  <a href="#animations">الرسوم المتحركة</a> •
  <a href="#accessibility">إمكانية الوصول</a> •
  <a href="#rtl-support">دعم RTL</a>
</p>

## <a id="design-system"></a>نظام التصميم

### الألوان

تستخدم واجهة المستخدم مجموعة ألوان متناسقة تعكس هوية العلامة التجارية وتوفر تباينًا جيدًا للقراءة.

#### الألوان الأساسية

| اللون | القيمة (الوضع الفاتح) | القيمة (الوضع الداكن) | الاستخدام |
|-------|----------------------|----------------------|----------|
| أساسي | `#4CAF50` | `#81C784` | العناصر الرئيسية، الأزرار، التمييز |
| ثانوي | `#FFC107` | `#FFD54F` | العناصر الثانوية، الشارات، التنبيهات |
| خلفية | `#FFFFFF` | `#121212` | خلفية الشاشات |
| سطح | `#F5F5F5` | `#1E1E1E` | البطاقات، الحاويات |
| نص أساسي | `#212121` | `#FFFFFF` | النصوص الرئيسية |
| نص ثانوي | `#757575` | `#B0B0B0` | النصوص الثانوية |
| حدود | `#E0E0E0` | `#424242` | الحدود، الفواصل |
| خطأ | `#F44336` | `#E57373` | رسائل الخطأ، التنبيهات |
| نجاح | `#4CAF50` | `#81C784` | رسائل النجاح |
| تحذير | `#FF9800` | `#FFB74D` | رسائل التحذير |
| معلومات | `#2196F3` | `#64B5F6` | رسائل المعلومات |

### الخطوط

يستخدم التطبيق خطوطًا واضحة وسهلة القراءة مع أحجام متناسقة.

#### عائلات الخطوط

- **الخط الرئيسي**: `Roboto` للإنجليزية، `Cairo` للعربية
- **خط العناوين**: `Roboto` للإنجليزية، `Cairo` للعربية

#### أحجام الخطوط

| الاسم | الحجم | الوزن | الاستخدام |
|-------|------|------|----------|
| عنوان كبير | 24sp | Bold | العناوين الرئيسية |
| عنوان متوسط | 20sp | Bold | العناوين الثانوية |
| عنوان صغير | 18sp | Medium | عناوين الأقسام |
| نص عادي | 16sp | Regular | النصوص الأساسية |
| نص صغير | 14sp | Regular | النصوص الثانوية |
| نص أصغر | 12sp | Regular | التسميات، الشارات |

### المسافات والهوامش

يستخدم التطبيق نظام مسافات متناسق لضمان تجربة مستخدم متسقة.

| الاسم | القيمة | الاستخدام |
|-------|------|----------|
| xxs | 4dp | مسافات داخلية صغيرة جدًا |
| xs | 8dp | مسافات داخلية صغيرة |
| s | 12dp | مسافات داخلية متوسطة |
| m | 16dp | مسافات داخلية قياسية |
| l | 24dp | مسافات داخلية كبيرة |
| xl | 32dp | مسافات داخلية كبيرة جدًا |
| xxl | 48dp | مسافات داخلية ضخمة |

### الزوايا والظلال

| العنصر | القيمة | الاستخدام |
|--------|------|----------|
| زاوية صغيرة | 4dp | العناصر الصغيرة |
| زاوية متوسطة | 8dp | البطاقات، الأزرار |
| زاوية كبيرة | 16dp | الحاويات الكبيرة |
| ظل خفيف | elevation: 1 | العناصر المرتفعة قليلاً |
| ظل متوسط | elevation: 3 | البطاقات، الأزرار |
| ظل قوي | elevation: 6 | العناصر البارزة |

## <a id="components"></a>المكونات

### الأزرار

#### الزر الأساسي

```dart
AnimatedButton(
  text: 'أضف إلى السلة',
  onPressed: () {},
  backgroundColor: AppColors.primary,
  textColor: Colors.white,
  borderRadius: 8.0,
)
```

#### الزر الثانوي

```dart
AnimatedButton(
  text: 'إلغاء',
  onPressed: () {},
  backgroundColor: Colors.transparent,
  textColor: AppColors.primary,
  borderColor: AppColors.primary,
  borderRadius: 8.0,
)
```

#### زر الأيقونة

```dart
IconButton(
  icon: Icon(Icons.favorite_border),
  onPressed: () {},
  color: AppColors.primary,
)
```

### حقول الإدخال

#### حقل النص العادي

```dart
AnimatedTextField(
  controller: _textController,
  label: 'الاسم الكامل',
  prefixIcon: Icons.person,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  },
)
```

#### حقل كلمة المرور

```dart
AnimatedTextField(
  controller: _passwordController,
  label: 'كلمة المرور',
  prefixIcon: Icons.lock,
  obscureText: _obscurePassword,
  suffixIcon: IconButton(
    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
    onPressed: _togglePasswordVisibility,
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
    }
    return null;
  },
)
```

### البطاقات

#### بطاقة المنتج

```dart
ProductCard(
  product: product,
  onTap: () => _navigateToProductDetail(product),
  onAddToCart: () => _addToCart(product),
  isInCart: isInCart,
  onIncrement: isInCart ? () => _incrementQuantity(product) : null,
  onDecrement: isInCart ? () => _decrementQuantity(product) : null,
  quantity: quantity,
)
```

#### بطاقة التصنيف

```dart
CategoryItem(
  category: category,
  isSelected: isSelected,
  onTap: () => _selectCategory(category),
)
```

#### بطاقة عنصر السلة

```dart
CartItemCard(
  cartItem: cartItem,
  onIncrement: () => _incrementQuantity(cartItem),
  onDecrement: () => _decrementQuantity(cartItem),
  onRemove: () => _removeFromCart(cartItem),
)
```

### الشارات والمؤشرات

#### شارة السلة

```dart
Badge(
  label: Text('$cartItemCount'),
  isLabelVisible: cartItemCount > 0,
  child: Icon(Icons.shopping_cart),
)
```

#### شارة المفضلة

```dart
Badge(
  label: Text('$favoriteCount'),
  isLabelVisible: favoriteCount > 0,
  child: Icon(Icons.favorite, color: Colors.red),
)
```

#### مؤشر التحميل

```dart
LoadingIndicator(
  color: AppColors.primary,
  size: 40.0,
)
```

#### رسالة الخطأ

```dart
ErrorView(
  message: 'حدث خطأ أثناء تحميل البيانات',
  onRetry: _loadData,
)
```

## <a id="screens"></a>الشاشات

### الشاشة الرئيسية

تعرض الشاشة الرئيسية العناصر التالية:

1. **شريط التطبيق**: يحتوي على شعار التطبيق وأيقونة المفضلة وأيقونة السلة وصورة المستخدم.
2. **البانر المتحرك**: يعرض العروض والإعلانات.
3. **قائمة التصنيفات**: تعرض التصنيفات المتاحة بشكل أفقي.
4. **المنتجات الشائعة**: تعرض المنتجات الأكثر شعبية.
5. **المنتجات الجديدة**: تعرض المنتجات التي تم إضافتها مؤخرًا.

### شاشة المنتجات

تعرض شاشة المنتجات العناصر التالية:

1. **شريط التطبيق**: يحتوي على زر الرجوع وعنوان التصنيف وأيقونة السلة.
2. **شريط البحث**: يتيح للمستخدم البحث عن المنتجات.
3. **قائمة التصنيفات**: تعرض التصنيفات المتاحة بشكل أفقي.
4. **قائمة المنتجات**: تعرض المنتجات في شكل شبكة.

### شاشة تفاصيل المنتج

تعرض شاشة تفاصيل المنتج العناصر التالية:

1. **شريط التطبيق**: يحتوي على زر الرجوع وأيقونة السلة.
2. **صورة المنتج**: تعرض صورة المنتج بحجم كبير.
3. **معلومات المنتج**: تعرض اسم المنتج والسعر والتقييم.
4. **وصف المنتج**: يعرض وصفًا تفصيليًا للمنتج.
5. **زر الإضافة إلى السلة**: يتيح للمستخدم إضافة المنتج إلى السلة.

### شاشة السلة

تعرض شاشة السلة العناصر التالية:

1. **شريط التطبيق**: يحتوي على عنوان "السلة" وزر تفريغ السلة.
2. **قائمة العناصر**: تعرض المنتجات في السلة مع خيارات تعديل الكمية.
3. **ملخص الطلب**: يعرض المجموع الفرعي والضرائب ورسوم الشحن والإجمالي.
4. **زر متابعة الدفع**: يتيح للمستخدم الانتقال إلى شاشة الدفع.

### شاشة الدفع

تعرض شاشة الدفع العناصر التالية:

1. **شريط التطبيق**: يحتوي على زر الرجوع وعنوان "الدفع".
2. **نموذج عنوان الشحن**: يتيح للمستخدم إدخال عنوان الشحن.
3. **خيارات الدفع**: تعرض طرق الدفع المتاحة.
4. **ملخص الطلب**: يعرض ملخصًا للطلب.
5. **زر تأكيد الطلب**: يتيح للمستخدم تأكيد الطلب.

## <a id="animations"></a>الرسوم المتحركة

يستخدم التطبيق الرسوم المتحركة لتحسين تجربة المستخدم وجعلها أكثر حيوية.

### انتقالات الصفحات

```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => TargetScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  ),
);
```

### رسوم متحركة للمكونات

#### زر متحرك

```dart
class AnimatedButton extends StatefulWidget {
  // ...
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          // ...
        ),
      ),
    );
  }
}
```

#### حقل نص متحرك

```dart
class AnimatedTextField extends StatefulWidget {
  // ...
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _borderAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: AppColors.primary,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return TextField(
          // ...
          decoration: InputDecoration(
            // ...
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: _colorAnimation.value ?? Colors.grey,
                width: _borderAnimation.value,
              ),
            ),
          ),
          onTap: () => _controller.forward(),
          onEditingComplete: () => _controller.reverse(),
        );
      },
    );
  }
}
```

### رسائل متحركة

```dart
void showAnimatedToast(BuildContext context, String message, {bool isError = false}) {
  AnimatedToast.show(
    context: context,
    message: message,
    backgroundColor: isError ? AppColors.error : AppColors.success,
    textColor: Colors.white,
    duration: const Duration(seconds: 3),
    animation: AnimatedToastAnimation.slideFromTop,
  );
}
```

## <a id="accessibility"></a>إمكانية الوصول

يهتم التطبيق بتوفير تجربة مستخدم جيدة لجميع المستخدمين، بما في ذلك ذوي الاحتياجات الخاصة.

### تباين الألوان

- يجب أن يكون التباين بين لون النص ولون الخلفية كافيًا لضمان سهولة القراءة.
- يجب استخدام ألوان متباينة للعناصر التفاعلية مثل الأزرار والروابط.

### حجم النص

- يجب استخدام وحدة `sp` لأحجام النصوص لضمان تكيفها مع إعدادات الجهاز.
- يجب أن تكون النصوص قابلة للتكبير دون كسر تخطيط الواجهة.

### وصف الصور

- يجب توفير وصف نصي للصور باستخدام خاصية `semanticLabel`.

```dart
Image.asset(
  'assets/logo/logo.png',
  semanticLabel: 'شعار 3MCode Shop',
)
```

### العناصر التفاعلية

- يجب أن تكون العناصر التفاعلية كبيرة بما يكفي للنقر عليها بسهولة.
- يجب توفير تغذية راجعة بصرية عند التفاعل مع العناصر.

## <a id="rtl-support"></a>دعم RTL

يدعم التطبيق اتجاه النص من اليمين إلى اليسار (RTL) للغة العربية.

### تطبيق الاتجاه

```dart
Directionality(
  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
  child: Scaffold(
    // ...
  ),
)
```

### تخطيط متجاوب

- يجب استخدام خصائص مثل `start` و `end` بدلاً من `left` و `right`.
- يجب استخدام `TextDirection` لتحديد اتجاه النص.

```dart
Padding(
  padding: const EdgeInsets.only(start: 16.0, end: 16.0),
  child: Text(
    'نص باللغة العربية',
    textDirection: TextDirection.rtl,
  ),
)
```

### الأيقونات والصور

- يجب عكس الأيقونات التي تشير إلى اتجاه مثل أسهم الرجوع والتقدم.

```dart
Icon(
  isRtl ? Icons.arrow_forward : Icons.arrow_back,
)
```

---

<p align="center">
  تم التطوير بواسطة <a href="https://www.3mcode.com">3MCode</a> - جميع الحقوق محفوظة © 2025
</p>

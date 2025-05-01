# التوثيق التقني للوضع الداكن (Dark Mode)

## المكتبات المستخدمة

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  shared_preferences: ^2.2.2
  equatable: ^2.0.5
```

## هيكل الكود

```
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart       # ألوان التطبيق
│       ├── app_theme.dart        # سمات التطبيق
│       └── theme_manager.dart    # مدير السمات
└── presentation/
    ├── blocs/
    │   └── theme/
    │       ├── theme_bloc.dart   # كتلة السمات
    │       ├── theme_event.dart  # أحداث السمات
    │       └── theme_state.dart  # حالات السمات
    └── widgets/
        └── theme_switcher.dart   # زر تبديل السمة
```

## تعريف الألوان (app_colors.dart)

```dart
import 'package:flutter/material.dart';

class AppColors {
  // ألوان الوضع الفاتح
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF388E3C);
  
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color card = Color(0xFFFFFFFF);
  
  static const Color text = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFEEEEEE);
  
  // ألوان الوضع الداكن
  static const Color primaryDarkMode = Color(0xFF66BB6A);
  static const Color primaryLightDarkMode = Color(0xFF81C784);
  static const Color primaryDarkDarkMode = Color(0xFF4CAF50);
  
  static const Color backgroundDarkMode = Color(0xFF121212);
  static const Color surfaceDarkMode = Color(0xFF1E1E1E);
  static const Color cardDarkMode = Color(0xFF2C2C2C);
  
  static const Color textDarkMode = Color(0xFFFFFFFF);
  static const Color textSecondaryDarkMode = Color(0xFFBBBBBB);
  static const Color dividerDarkMode = Color(0xFF333333);
  
  // دالة للحصول على اللون المناسب حسب الوضع
  static Color getColor(Color lightColor, Color darkColor, bool isDark) {
    return isDark ? darkColor : lightColor;
  }
}
```

## تعريف السمات (app_theme.dart)

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // سمة الوضع الفاتح
  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryLight,
      primaryColorDark: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.card,
      dividerColor: AppColors.divider,
      
      // تخصيص النصوص
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.text),
        titleSmall: TextStyle(color: AppColors.textSecondary),
        bodyLarge: TextStyle(color: AppColors.text),
        bodyMedium: TextStyle(color: AppColors.text),
        bodySmall: TextStyle(color: AppColors.textSecondary),
        labelLarge: TextStyle(color: AppColors.text),
      ),
      
      // تخصيص الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // تخصيص البطاقات
      cardTheme: CardTheme(
        color: AppColors.card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // تخصيص شريط التطبيق
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      
      // تخصيص القائمة الجانبية
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.background,
      ),
      
      // تخصيص حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.surface,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
  
  // سمة الوضع الداكن
  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDarkMode,
      primaryColorLight: AppColors.primaryLightDarkMode,
      primaryColorDark: AppColors.primaryDarkDarkMode,
      scaffoldBackgroundColor: AppColors.backgroundDarkMode,
      cardColor: AppColors.cardDarkMode,
      dividerColor: AppColors.dividerDarkMode,
      
      // تخصيص النصوص
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textDarkMode, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: AppColors.textDarkMode, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: AppColors.textDarkMode, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.textDarkMode, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: AppColors.textDarkMode, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: AppColors.textDarkMode, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.textDarkMode),
        titleSmall: TextStyle(color: AppColors.textSecondaryDarkMode),
        bodyLarge: TextStyle(color: AppColors.textDarkMode),
        bodyMedium: TextStyle(color: AppColors.textDarkMode),
        bodySmall: TextStyle(color: AppColors.textSecondaryDarkMode),
        labelLarge: TextStyle(color: AppColors.textDarkMode),
      ),
      
      // تخصيص الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkMode,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // تخصيص البطاقات
      cardTheme: CardTheme(
        color: AppColors.cardDarkMode,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // تخصيص شريط التطبيق
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryDarkMode,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      
      // تخصيص القائمة الجانبية
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.backgroundDarkMode,
      ),
      
      // تخصيص حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.surfaceDarkMode,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryDarkMode, width: 2),
        ),
      ),
    );
  }
}
```

## مدير السمات (theme_manager.dart)

```dart
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static const String _themeKey = 'theme_mode';
  static const String _followSystemKey = 'follow_system';
  
  // الحصول على وضع السمة الحالي
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
  
  // تعيين وضع السمة
  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
    // عند تعيين وضع السمة يدويًا، نلغي خيار اتباع النظام
    await prefs.setBool(_followSystemKey, false);
  }
  
  // تبديل وضع السمة
  static Future<bool> toggleTheme() async {
    final isDark = await isDarkMode();
    await setDarkMode(!isDark);
    return !isDark;
  }
  
  // الحصول على حالة اتباع إعدادات النظام
  static Future<bool> isFollowingSystem() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_followSystemKey) ?? false;
  }
  
  // تعيين حالة اتباع إعدادات النظام
  static Future<void> setFollowSystem(bool follow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_followSystemKey, follow);
  }
}
```

## كتلة السمات (BLoC)

### حالات السمة (theme_state.dart)

```dart
import 'package:equatable/equatable.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();
  
  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLight extends ThemeState {}

class ThemeDark extends ThemeState {}

class ThemeFollowSystem extends ThemeState {
  final bool isDark;
  
  const ThemeFollowSystem(this.isDark);
  
  @override
  List<Object> get props => [isDark];
}
```

### أحداث السمة (theme_event.dart)

```dart
import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  
  @override
  List<Object> get props => [];
}

class LoadTheme extends ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class SetDarkTheme extends ThemeEvent {
  final bool isDark;
  
  const SetDarkTheme(this.isDark);
  
  @override
  List<Object> get props => [isDark];
}

class SetFollowSystem extends ThemeEvent {
  final bool follow;
  final bool currentSystemIsDark;
  
  const SetFollowSystem({
    required this.follow,
    required this.currentSystemIsDark,
  });
  
  @override
  List<Object> get props => [follow, currentSystemIsDark];
}

class SystemThemeChanged extends ThemeEvent {
  final bool isDark;
  
  const SystemThemeChanged(this.isDark);
  
  @override
  List<Object> get props => [isDark];
}
```

### كتلة السمة (theme_bloc.dart)

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../core/theme/theme_manager.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetDarkTheme>(_onSetDarkTheme);
    on<SetFollowSystem>(_onSetFollowSystem);
    on<SystemThemeChanged>(_onSystemThemeChanged);
  }
  
  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final followSystem = await ThemeManager.isFollowingSystem();
    
    if (followSystem) {
      final brightness = SchedulerBinding.instance.window.platformBrightness;
      final isDark = brightness == Brightness.dark;
      emit(ThemeFollowSystem(isDark));
    } else {
      final isDark = await ThemeManager.isDarkMode();
      emit(isDark ? ThemeDark() : ThemeLight());
    }
  }
  
  Future<void> _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    final newIsDark = await ThemeManager.toggleTheme();
    emit(newIsDark ? ThemeDark() : ThemeLight());
  }
  
  Future<void> _onSetDarkTheme(SetDarkTheme event, Emitter<ThemeState> emit) async {
    await ThemeManager.setDarkMode(event.isDark);
    emit(event.isDark ? ThemeDark() : ThemeLight());
  }
  
  Future<void> _onSetFollowSystem(SetFollowSystem event, Emitter<ThemeState> emit) async {
    await ThemeManager.setFollowSystem(event.follow);
    
    if (event.follow) {
      emit(ThemeFollowSystem(event.currentSystemIsDark));
    } else {
      // عند إلغاء اتباع النظام، نستخدم الوضع الحالي للنظام كوضع افتراضي
      await ThemeManager.setDarkMode(event.currentSystemIsDark);
      emit(event.currentSystemIsDark ? ThemeDark() : ThemeLight());
    }
  }
  
  void _onSystemThemeChanged(SystemThemeChanged event, Emitter<ThemeState> emit) async {
    final followSystem = await ThemeManager.isFollowingSystem();
    
    if (followSystem) {
      emit(ThemeFollowSystem(event.isDark));
    }
  }
}
```

## زر تبديل السمة (theme_switcher.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/theme/theme_bloc.dart';
import '../../../presentation/blocs/theme/theme_event.dart';
import '../../../presentation/blocs/theme/theme_state.dart';
import '../../../core/localization/app_localizations.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state is ThemeDark || 
                       (state is ThemeFollowSystem && state.isDark);
        
        return ListTile(
          leading: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            localizations.translate('dark_mode'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          trailing: Switch(
            value: isDark,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (value) {
              context.read<ThemeBloc>().add(SetDarkTheme(value));
            },
          ),
        );
      },
    );
  }
}
```

## تطبيق السمة في التطبيق الرئيسي (app.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/theme/theme_state.dart';
import 'presentation/screens/main_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state is ThemeDark || 
                       (state is ThemeFollowSystem && state.isDark);
        
        return MaterialApp(
          title: 'Shopping App',
          theme: AppTheme.getLightTheme(),
          darkTheme: AppTheme.getDarkTheme(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const MainScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
```

## مراقبة تغييرات وضع النظام

```dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/theme/theme_event.dart';

class ThemeObserver extends WidgetsBindingObserver {
  final ThemeBloc themeBloc;
  
  ThemeObserver(this.themeBloc);
  
  @override
  void didChangePlatformBrightness() {
    final brightness = SchedulerBinding.instance.window.platformBrightness;
    final isDark = brightness == Brightness.dark;
    themeBloc.add(SystemThemeChanged(isDark));
    super.didChangePlatformBrightness();
  }
}

// استخدام المراقب في main.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final themeBloc = ThemeBloc();
  themeBloc.add(LoadTheme());
  
  // إضافة مراقب لتغييرات وضع النظام
  final themeObserver = ThemeObserver(themeBloc);
  WidgetsBinding.instance.addObserver(themeObserver);
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => themeBloc,
        ),
        // ... المزيد من موفري BLoC
      ],
      child: const App(),
    ),
  );
}
```

## اختبار الوضع الداكن

### اختبار مدير السمات

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_3mcode_shop/core/theme/theme_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ThemeManager Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });
    
    test('isDarkMode returns false by default', () async {
      final result = await ThemeManager.isDarkMode();
      expect(result, false);
    });
    
    test('setDarkMode sets the theme mode', () async {
      await ThemeManager.setDarkMode(true);
      final result = await ThemeManager.isDarkMode();
      expect(result, true);
    });
    
    test('toggleTheme toggles the theme mode', () async {
      await ThemeManager.setDarkMode(false);
      final result = await ThemeManager.toggleTheme();
      expect(result, true);
      
      final newMode = await ThemeManager.isDarkMode();
      expect(newMode, true);
    });
    
    test('isFollowingSystem returns false by default', () async {
      final result = await ThemeManager.isFollowingSystem();
      expect(result, false);
    });
    
    test('setFollowSystem sets the follow system flag', () async {
      await ThemeManager.setFollowSystem(true);
      final result = await ThemeManager.isFollowingSystem();
      expect(result, true);
    });
    
    test('setDarkMode disables follow system', () async {
      await ThemeManager.setFollowSystem(true);
      await ThemeManager.setDarkMode(true);
      
      final followSystem = await ThemeManager.isFollowingSystem();
      expect(followSystem, false);
      
      final isDark = await ThemeManager.isDarkMode();
      expect(isDark, true);
    });
  });
}
```

### اختبار كتلة السمة

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ThemeBloc Tests', () {
    late ThemeBloc themeBloc;
    
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      themeBloc = ThemeBloc();
    });
    
    tearDown(() {
      themeBloc.close();
    });
    
    test('initial state is ThemeInitial', () {
      expect(themeBloc.state, isA<ThemeInitial>());
    });
    
    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeLight] when LoadTheme is added with default settings',
      build: () => themeBloc,
      act: (bloc) => bloc.add(LoadTheme()),
      expect: () => [isA<ThemeLight>()],
    );
    
    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeDark] when SetDarkTheme(true) is added',
      build: () => themeBloc,
      act: (bloc) => bloc.add(const SetDarkTheme(true)),
      expect: () => [isA<ThemeDark>()],
    );
    
    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeLight] when SetDarkTheme(false) is added',
      build: () => themeBloc,
      act: (bloc) => bloc.add(const SetDarkTheme(false)),
      expect: () => [isA<ThemeLight>()],
    );
    
    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeDark, ThemeLight] when ToggleTheme is added twice',
      build: () => themeBloc,
      act: (bloc) => bloc
        ..add(const SetDarkTheme(true))
        ..add(ToggleTheme())
        ..add(ToggleTheme()),
      expect: () => [
        isA<ThemeDark>(),
        isA<ThemeLight>(),
        isA<ThemeDark>(),
      ],
    );
    
    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeFollowSystem] when SetFollowSystem is added',
      build: () => themeBloc,
      act: (bloc) => bloc.add(const SetFollowSystem(
        follow: true,
        currentSystemIsDark: false,
      )),
      expect: () => [isA<ThemeFollowSystem>()],
    );
    
    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeFollowSystem] with updated isDark when SystemThemeChanged is added',
      build: () => themeBloc,
      seed: () => const ThemeFollowSystem(false),
      act: (bloc) => bloc.add(const SystemThemeChanged(true)),
      expect: () => [const ThemeFollowSystem(true)],
    );
  });
}
```

## أفضل الممارسات

1. **فصل المخاوف**: فصل منطق السمة عن بقية التطبيق باستخدام نمط BLoC
2. **التخزين المستمر**: حفظ تفضيلات المستخدم باستخدام SharedPreferences
3. **الاتساق**: استخدام نفس الألوان والأنماط في جميع أنحاء التطبيق
4. **المرونة**: دعم اتباع إعدادات النظام أو الاختيار اليدوي
5. **الاختبار**: اختبار جميع مكونات الوضع الداكن للتأكد من عملها بشكل صحيح
6. **الأداء**: تحسين الأداء عن طريق تجنب إعادة بناء الواجهة بالكامل عند تغيير السمة

## الأمان والخصوصية

1. **التخزين المحلي**: يتم تخزين تفضيلات السمة محليًا فقط على جهاز المستخدم
2. **لا توجد بيانات حساسة**: لا يتم جمع أو مشاركة أي بيانات حساسة
3. **الشفافية**: يتم إخبار المستخدم بوضوح عن خيارات السمة المتاحة

## التحسينات المستقبلية

1. **سمات إضافية**: إضافة سمات ملونة متعددة
2. **جدولة السمات**: تغيير السمة تلقائيًا حسب الوقت من اليوم
3. **تخصيص أكثر**: السماح للمستخدم بتخصيص ألوان معينة في السمة
4. **وضع القراءة**: إضافة وضع خاص للقراءة يقلل من الضوء الأزرق
5. **تحسين الأداء**: تحسين أداء تبديل السمة في التطبيقات الكبيرة

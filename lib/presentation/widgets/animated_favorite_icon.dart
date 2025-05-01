import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/colors.dart';

class AnimatedFavoriteIcon extends StatefulWidget {
  final int favoriteCount;
  final VoidCallback onTap;

  const AnimatedFavoriteIcon({
    Key? key,
    required this.favoriteCount,
    required this.onTap,
  }) : super(key: key);

  /// تشغيل تأثير حركي على أيقونة المفضلة
  /// يمكن استخدامها من أي مكان في التطبيق
  static void playAnimation(BuildContext context) {
    // تأثير بسيط للنبض
    final icon = Icon(Icons.favorite, color: Colors.red, size: 28);

    // إنشاء تأثير حركي مؤقت
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).size.height / 2 - 50,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.5, end: 2.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: 2.0 - value, child: icon),
                  );
                },
                onEnd: () {
                  overlayEntry.remove();
                },
              ),
            ),
          ),
    );

    // إضافة التأثير إلى الشاشة
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  State<AnimatedFavoriteIcon> createState() => _AnimatedFavoriteIconState();
}

class _AnimatedFavoriteIconState extends State<AnimatedFavoriteIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _animationController.forward().then((_) {
          _animationController.reverse().then((_) {
            widget.onTap();
          });
        });
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale:
                _animationController.value >= 0.5
                    ? _pulseAnimation.value
                    : _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 28),
                if (widget.favoriteCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        widget.favoriteCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

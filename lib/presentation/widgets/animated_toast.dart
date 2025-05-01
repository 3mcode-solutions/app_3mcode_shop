import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/colors.dart';

enum ToastType { success, error, info, warning }

class AnimatedToast {
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onDismiss,
  }) {
    // Remove any existing toast
    _removeToast();
    
    // Create overlay entry
    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: onDismiss,
      ),
    );
    
    // Show toast
    Overlay.of(context).insert(overlayEntry);
    
    // Auto dismiss after duration
    Future.delayed(duration, () {
      _removeToast(overlayEntry: overlayEntry);
      if (onDismiss != null) {
        onDismiss();
      }
    });
    
    // Store current overlay entry
    _currentOverlayEntry = overlayEntry;
  }
  
  static OverlayEntry? _currentOverlayEntry;
  
  static void _removeToast({OverlayEntry? overlayEntry}) {
    overlayEntry = overlayEntry ?? _currentOverlayEntry;
    overlayEntry?.remove();
    if (overlayEntry == _currentOverlayEntry) {
      _currentOverlayEntry = null;
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback? onDismiss;
  
  const _ToastWidget({
    Key? key,
    required this.message,
    required this.type,
    this.onDismiss,
  }) : super(key: key);
  
  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
        reverseCurve: Curves.elasticIn,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _getIcon(),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _animationController.reverse().then((_) {
                            AnimatedToast._removeToast();
                            if (widget.onDismiss != null) {
                              widget.onDismiss!();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
      default:
        return AppColors.primary;
    }
  }
  
  Widget _getIcon() {
    IconData iconData;
    
    switch (widget.type) {
      case ToastType.success:
        iconData = Icons.check_circle;
        break;
      case ToastType.error:
        iconData = Icons.error;
        break;
      case ToastType.warning:
        iconData = Icons.warning;
        break;
      case ToastType.info:
      default:
        iconData = Icons.info;
        break;
    }
    
    return Icon(
      iconData,
      color: Colors.white,
      size: 24.0,
    );
  }
}

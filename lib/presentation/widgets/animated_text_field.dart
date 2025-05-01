import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_3mcode_shop/colors.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool isRequired;
  final int? maxLength;
  final int? maxLines;
  final bool enabled;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  
  const AnimatedTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.isRequired = false,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);
  
  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    widget.focusNode?.addListener(_handleFocusChange);
  }
  
  void _handleFocusChange() {
    if (widget.focusNode?.hasFocus != _isFocused) {
      setState(() {
        _isFocused = widget.focusNode?.hasFocus ?? false;
      });
      
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
              
              // Clear error state when user types
              if (_hasError) {
                setState(() {
                  _hasError = false;
                });
              }
            },
            onFieldSubmitted: widget.onSubmitted,
            validator: (value) {
              if (widget.validator != null) {
                final error = widget.validator!(value);
                setState(() {
                  _hasError = error != null;
                });
                return error;
              } else if (widget.isRequired && (value == null || value.isEmpty)) {
                setState(() {
                  _hasError = true;
                });
                return 'This field is required';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: widget.label + (widget.isRequired ? ' *' : ''),
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppColors.primary
                          : _hasError
                              ? Colors.red
                              : Colors.grey,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        widget.suffixIcon,
                        color: _isFocused
                            ? AppColors.primary
                            : _hasError
                                ? Colors.red
                                : Colors.grey,
                      ),
                      onPressed: widget.onSuffixIconPressed,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _hasError ? Colors.red : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _hasError ? Colors.red : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _hasError ? Colors.red : AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: _isFocused
                  ? AppColors.primary.withOpacity(0.05)
                  : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}

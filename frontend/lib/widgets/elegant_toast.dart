import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/constants/colors.dart';

class ElegantToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  final Color? backgroundColor;
  final IconData? icon;
  final Duration? duration;

  const ElegantToast({
    Key? key,
    required this.message,
    required this.onDismiss,
    this.backgroundColor,
    this.icon,
    this.duration,
  }) : super(key: key);

  @override
  State<ElegantToast> createState() => _ElegantToastState();

  /// Show a success toast notification
  static void showSuccess(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message,
      backgroundColor: AppColors.mainGreen,
      icon: Icons.check_circle,
      duration: duration,
    );
  }

  /// Show an error toast notification
  static void showError(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message,
      backgroundColor: AppTheme.errorColor,
      icon: Icons.error,
      duration: duration,
    );
  }

  /// Show an info toast notification
  static void showInfo(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message,
      backgroundColor: AppTheme.infoColor,
      icon: Icons.info,
      duration: duration,
    );
  }

  /// Show a warning toast notification
  static void showWarning(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message,
      backgroundColor: AppTheme.warningColor,
      icon: Icons.warning,
      duration: duration,
    );
  }

  /// Generic method to show any toast
  static void _show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    IconData? icon,
    Duration? duration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => ElegantToast(
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        duration: duration,
        onDismiss: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto dismiss after specified duration or default 3 seconds
    final autoDismissDuration = duration ?? const Duration(seconds: 3);
    Future.delayed(autoDismissDuration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _ElegantToastState extends State<ElegantToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
    
    // Auto dismiss animation - 500ms before the actual dismiss to account for animation
    final animationOffset = const Duration(milliseconds: 500);
    final totalDuration = widget.duration ?? const Duration(seconds: 3);
    final dismissAfter = totalDuration - animationOffset;
    
    Future.delayed(dismissAfter, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? AppColors.mainGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon ?? Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _controller.reverse().then((_) => widget.onDismiss());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 
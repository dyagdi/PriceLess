import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.backgroundColor,
    required this.buttonText,
    required this.buttonTextColor,
    this.height = 48,
    this.onTap,
    this.textSize = 18,
    this.isSecondary = false,
    this.buttonIcon,
    this.buttonImage,
    this.width,
  });
  final Color? backgroundColor;
  final String buttonText;
  final Color? buttonTextColor;
  final void Function()? onTap;
  final double height;
  final double textSize;
  final bool isSecondary;
  final Icon? buttonIcon;
  final Image? buttonImage;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (buttonIcon != null) buttonIcon!,
              if (buttonIcon != null)
                const SizedBox(
                  width: 8,
                ),
              if (buttonImage != null) buttonImage!,
              if (buttonImage != null)
                const SizedBox(
                  width: 8,
                ),
              Text(
                buttonText,
                style: TextStyle(
                  color: buttonTextColor ??
                      Theme.of(context).colorScheme.onPrimary,
                  fontSize: textSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

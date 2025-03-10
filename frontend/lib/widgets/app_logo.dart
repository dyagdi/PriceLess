import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 100,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: logoColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shopping basket icon
                Icon(
                  Icons.shopping_basket_rounded,
                  size: size * 0.6,
                  color: logoColor,
                ),

                // Price tag overlay
                Positioned(
                  top: size * 0.15,
                  right: size * 0.15,
                  child: Container(
                    padding: EdgeInsets.all(size * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: logoColor, width: 2),
                    ),
                    child: Text(
                      "₺",
                      style: TextStyle(
                        color: logoColor,
                        fontWeight: FontWeight.bold,
                        fontSize: size * 0.15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            "PriceLess",
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              color: logoColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}

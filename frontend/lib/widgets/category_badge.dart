import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/theme/app_theme.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({required this.category, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(
          color: _getCategoryColor(category).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: _getCategoryColor(category),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Map different categories to different colors for visual variety
    final Map<String, Color> categoryColors = {
      'Meyve & Sebze': AppColors.mainGreenDark,
      'Süt & Süt Ürünleri': Colors.blue[700]!,
      'Et & Et Ürünleri': Colors.red[700]!,
      'Atıştırmalık': Colors.orange[700]!,
      'İçecek': Colors.purple[700]!,
      'Temel Gıda': Colors.brown[700]!,
      'Kahvaltılık': Colors.amber[800]!,
      'Kişisel Bakım': Colors.pink[700]!,
      'Temizlik': Colors.cyan[700]!,
      'Bebek & Çocuk': Colors.indigo[700]!,
      'Ev & Yaşam': Colors.teal[700]!,
    };

    // Return the mapped color or default to the primary color
    return categoryColors[category] ?? AppColors.mainGreenDark;
  }
}

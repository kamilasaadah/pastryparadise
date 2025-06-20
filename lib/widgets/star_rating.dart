import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showRatingText;
  final int? reviewCount;

  const StarRating({
    Key? key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.activeColor,
    this.inactiveColor,
    this.showRatingText = false,
    this.reviewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStarColor = activeColor ?? Colors.amber;
    final inactiveStarColor = inactiveColor ?? Colors.grey.shade300;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bintang-bintang
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxRating, (index) {
            final starValue = index + 1;
            
            if (rating >= starValue) {
              // Bintang penuh
              return Icon(
                Icons.star,
                size: size,
                color: activeStarColor,
              );
            } else if (rating > index && rating < starValue) {
              // Bintang setengah
              return Stack(
                children: [
                  Icon(
                    Icons.star,
                    size: size,
                    color: inactiveStarColor,
                  ),
                  ClipRect(
                    clipper: _HalfClipper(),
                    child: Icon(
                      Icons.star,
                      size: size,
                      color: activeStarColor,
                    ),
                  ),
                ],
              );
            } else {
              // Bintang kosong
              return Icon(
                Icons.star_border,
                size: size,
                color: inactiveStarColor,
              );
            }
          }),
        ),
        
        // Teks rating dan jumlah review
        if (showRatingText) ...[
          const SizedBox(width: 6),
          Text(
            rating > 0 
                ? '${rating.toStringAsFixed(1)}${reviewCount != null && reviewCount! > 0 ? ' ($reviewCount)' : ''}'
                : 'Belum ada rating',
            style: TextStyle(
              fontSize: size * 0.8,
              // ignore: deprecated_member_use
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}

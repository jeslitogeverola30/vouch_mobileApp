import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../constatnt/colors.dart';

class AmenitiesCard extends StatelessWidget {
  AmenitiesCard({super.key, required this.amenites});
  List amenites;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenites.take(4).map((amenity) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: ColorsData.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ColorsData.primaryColor.withOpacity(0.2),
            ),
          ),
          child: Text(
            amenity,
            style: TextStyle(
              color: ColorsData.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

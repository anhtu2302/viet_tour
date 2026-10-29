import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:viet_tour/core/utils/responsive.dart';
import '../theme/app_colors.dart';

class SkeletonTourCard extends StatelessWidget {
  const SkeletonTourCard({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.border,
    highlightColor: Colors.white,
    child: Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.radius(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 22.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(Responsive.radius(16)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 24.w, height: 2.h, color: Colors.white),
                SizedBox(height: 1.5.h),
                Container(width: 76.w, height: 2.h, color: Colors.white),
                SizedBox(height: 1.h),
                Container(width: 54.w, height: 2.h, color: Colors.white),
                SizedBox(height: 2.h),
                Container(width: 32.w, height: 2.5.h, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

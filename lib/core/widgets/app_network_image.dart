import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viet_tour/core/utils/responsive.dart';
import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  final String url;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(Responsive.radius(borderRadius)),
    child: CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => Container(
        color: AppColors.border,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Image.network(
        AppAssets.placeholder,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.border,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.muted,
          ),
        ),
      ),
    ),
  );
}

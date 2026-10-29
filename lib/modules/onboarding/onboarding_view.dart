import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:viet_tour/core/utils/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/app_widgets.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  static const _pages = [
    (
      'Khám phá những miền đất mới',
      'Từ biển xanh đến núi cao, hành trình Việt Nam đang chờ bạn.',
      'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=1200',
    ),
    (
      'Trải nghiệm theo cách riêng',
      'Chọn lịch trình yêu thích, khám phá văn hóa và ẩm thực địa phương.',
      'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=1200',
    ),
    (
      'Đặt tour thật dễ dàng',
      'Lưu hành trình yêu thích và quản lý chuyến đi ngay trên VietTour.',
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Obx(() {
        final item = _pages[controller.page.value];
        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => controller.page.value = 2,
                child: const Text('Bỏ qua'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Responsive.radius(24),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppNetworkImage(url: item.$3),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0x990F172A),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 6.w,
                              right: 6.w,
                              bottom: 5.h,
                              child: Text(
                                item.$1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.font(23),
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      item.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: Responsive.font(13),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: EdgeInsets.symmetric(horizontal: 0.6.w),
                          width: controller.page.value == index ? 7.w : 2.w,
                          height: 1.h,
                          decoration: BoxDecoration(
                            color: controller.page.value == index
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(
                              Responsive.radius(99),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    AppButton(
                      label: controller.page.value == 2
                          ? 'Đăng nhập'
                          : 'Tiếp tục',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: controller.continueFlow,
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    ),
  );
}

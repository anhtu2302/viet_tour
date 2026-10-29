import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:viet_tour/core/utils/responsive.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_view.dart';
import '../orders/orders_view.dart';
import '../profile/profile_view.dart';
import '../search/search_controller.dart' as search;
import '../search/search_view.dart';
import '../wishlist/wishlist_view.dart';
import 'main_shell_controller.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    const pages = [
      HomeView(),
      SearchView(),
      WishlistView(),
      OrdersView(),
      ProfileView(),
    ];
    const labels = [
      'Trang chủ',
      'Khám phá',
      'Yêu thích',
      'Đơn của tôi',
      'Tài khoản',
    ];
    const icons = [
      Icons.home_outlined,
      Icons.travel_explore_rounded,
      Icons.favorite_border_rounded,
      Icons.confirmation_number_outlined,
      Icons.person_outline_rounded,
    ];
    return Scaffold(
      body: Obx(
        () => IndexedStack(index: app.selectedTab.value, children: pages),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.06).round()),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 8.h,
              child: Row(
                children: List.generate(pages.length, (index) {
                  final selected = app.selectedTab.value == index;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        app.selectedTab.value = index;
                        if (index == 1) {
                          Get.find<search.SearchController>().loadResults();
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icons[index],
                            size: 5.w,
                            color: selected
                                ? AppColors.primary
                                : AppColors.muted,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            labels[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Responsive.font(8.5),
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.muted,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

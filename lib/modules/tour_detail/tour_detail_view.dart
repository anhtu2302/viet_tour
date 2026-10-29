import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:viet_tour/core/utils/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/departure_model.dart';
import '../../data/models/tour_model.dart';
import 'tour_detail_controller.dart';

class TourDetailView extends GetView<TourDetailController> {
  const TourDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final tour = controller.tour;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 38.h,
            pinned: true,
            leading: _circleAction(Icons.arrow_back_rounded, Get.back),
            actions: [
              _circleAction(
                Icons.share_outlined,
                () => Get.snackbar(
                  'Chia sẻ',
                  'Liên kết tour đã sẵn sàng để chia sẻ.',
                ),
              ),
              Obx(() {
                final favorite = Get.find<AppController>().isFavorite(tour.id);
                return _circleAction(
                  favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  () => Get.find<AppController>().toggleFavorite(tour),
                  color: favorite ? AppColors.primary : AppColors.navy,
                );
              }),
              SizedBox(width: 3.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'tour-${tour.id}',
                    child: PageView(
                      onPageChanged: (index) =>
                          controller.selectedImage.value = index,
                      children: [
                        tour.imageUrl,
                        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1000',
                        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1000',
                      ].map((url) => AppNetworkImage(url: url)).toList(),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33000000),
                          Colors.transparent,
                          Color(0x44000000),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 5.w,
                    bottom: 2.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          Responsive.radius(99),
                        ),
                      ),
                      child: Text(
                        tour.isInternational
                            ? 'TOUR QUỐC TẾ'
                            : 'TOUR TRONG NƯỚC',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: Responsive.font(9),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5.w,
                    bottom: 2.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withAlpha((255 * 0.75).round()),
                        borderRadius: BorderRadius.circular(
                          Responsive.radius(99),
                        ),
                      ),
                      child: Obx(
                        () => Text(
                          '${controller.selectedImage.value + 1} / 3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.font(9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBadge(
                    rating: tour.rating,
                    reviewCount: tour.reviewCount,
                  ),
                  SizedBox(height: 1.2.h),
                  Text(
                    tour.title,
                    style: TextStyle(
                      fontSize: Responsive.font(21),
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 4.w,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          tour.destination,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: Responsive.font(11),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.schedule_rounded,
                        size: 4.w,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        tour.duration,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: Responsive.font(10),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.5.h),
                  _section('TỔNG QUAN', _overview(tour)),
                  _section('LỊCH KHỞI HÀNH', _departureChoices()),
                  _section('LỊCH TRÌNH THEO NGÀY', _itinerary(context, tour)),
                  _section(
                    'DỊCH VỤ BAO GỒM',
                    Column(
                      children: [
                        _bullet('Phương tiện di chuyển theo chương trình'),
                        _bullet('Khách sạn tiêu chuẩn, phòng 2 khách'),
                        _bullet('Các bữa ăn và vé tham quan theo lịch trình'),
                        _bullet('Bảo hiểm du lịch'),
                        _bullet(
                          'Chi phí cá nhân và dịch vụ ngoài chương trình chưa bao gồm',
                        ),
                      ],
                    ),
                  ),
                  _section(
                    'CHÍNH SÁCH HỦY',
                    Text(
                      'Hủy trước ngày khởi hành 15 ngày: phí 30%. Hủy từ 7 đến 14 ngày: phí 50%. Hủy trong vòng 7 ngày: phí 100%. Điều kiện có thể thay đổi theo chương trình tour.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: Responsive.font(11),
                        height: 1.55,
                      ),
                    ),
                  ),
                  _section(
                    'ĐÁNH GIÁ KHÁCH HÀNG',
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.star,
                          size: 7.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          tour.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: Responsive.font(19),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'trên ${tour.reviewCount} đánh giá',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: Responsive.font(11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(5.w, 1.2.h, 5.w, 1.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.08).round()),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Obx(
            () => Row(
              children: [
                Expanded(
                  child: PriceText(
                    price: controller.selectedDeparture?.price ?? tour.price,
                    originalPrice: tour.originalPrice,
                  ),
                ),
                SizedBox(width: 4.w),
                SizedBox(
                  width: 45.w,
                  child: AppButton(
                    label: controller.selectedDeparture == null
                        ? 'CHỌN LỊCH'
                        : 'ĐẶT NGAY',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: controller.bookSelectedDeparture,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _departureChoices() => Obx(() {
    if (controller.loadingDepartures.value && controller.departures.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.departures.isEmpty) {
      return Text(
        'Hiện chưa có lịch khởi hành cho tour này.',
        style: TextStyle(color: AppColors.muted, fontSize: Responsive.font(11)),
      );
    }
    return Column(
      children: controller.departures.map(_departureOption).toList(),
    );
  });

  Widget _departureOption(DepartureModel departure) {
    final selected = controller.selectedDepartureId.value == departure.id;
    final bookable = departure.isBookable;
    return InkWell(
      onTap: bookable
          ? () => controller.selectedDepartureId.value = departure.id
          : null,
      borderRadius: BorderRadius.circular(Responsive.radius(12)),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.starBackground : Colors.white,
          borderRadius: BorderRadius.circular(Responsive.radius(12)),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.muted,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Formatters.date(departure.startDate)} - ${Formatters.date(departure.endDate)}',
                    style: TextStyle(
                      fontSize: Responsive.font(10.5),
                      fontWeight: FontWeight.w700,
                      color: bookable ? AppColors.navy : AppColors.muted,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    bookable
                        ? 'Còn ${departure.remainingSeats} chỗ'
                        : departure.remainingSeats == 0
                        ? 'Đã hết chỗ'
                        : 'Không nhận đặt chỗ',
                    style: TextStyle(
                      fontSize: Responsive.font(9.5),
                      color: bookable ? AppColors.green : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              Formatters.currency(departure.price),
              style: TextStyle(
                fontSize: Responsive.font(10),
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overview(TourModel tour) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Một hành trình được VietTour tuyển chọn kỹ lưỡng, đưa bạn khám phá ${tour.destination} với dịch vụ chu đáo và lịch trình cân bằng.',
        style: TextStyle(
          color: AppColors.muted,
          fontSize: Responsive.font(11.5),
          height: 1.55,
        ),
      ),
      SizedBox(height: 1.5.h),
      _bullet('Khởi hành từ ${tour.departure}'),
      _bullet('Hướng dẫn viên đồng hành suốt tuyến'),
      _bullet(
        tour.includesAirfare
            ? 'Bao gồm vé máy bay và khách sạn 4 sao'
            : 'Dịch vụ lưu trú chất lượng',
      ),
    ],
  );

  Widget _itinerary(BuildContext context, TourModel tour) => Column(
    children: List.generate(
      tour.itinerary.length,
      (index) => Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.only(bottom: 1.h),
          title: Text(
            'Ngày ${index + 1}: ${tour.itinerary[index]}',
            style: TextStyle(
              fontSize: Responsive.font(11),
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: CircleAvatar(
            radius: 4.w,
            backgroundColor: AppColors.starBackground,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: Responsive.font(10),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          children: [
            Text(
              'Tham quan theo chương trình, nghỉ ngơi và dùng bữa tại các điểm được chọn lọc bởi VietTour.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: Responsive.font(10.5),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _circleAction(
    IconData icon,
    VoidCallback onTap, {
    Color color = AppColors.navy,
  }) => Padding(
    padding: EdgeInsets.only(left: 1.w),
    child: Material(
      color: Colors.white.withAlpha((255 * 0.95).round()),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(2.5.w),
          child: Icon(icon, size: 4.8.w, color: color),
        ),
      ),
    ),
  );

  Widget _section(String title, Widget child) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(top: 2.5.h),
    padding: EdgeInsets.only(top: 2.h),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.navy,
            fontSize: Responsive.font(12),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 1.5.h),
        child,
      ],
    ),
  );

  Widget _bullet(String text) => Padding(
    padding: EdgeInsets.only(bottom: 1.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, size: 4.w, color: AppColors.green),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: Responsive.font(10.5),
            ),
          ),
        ),
      ],
    ),
  );
}

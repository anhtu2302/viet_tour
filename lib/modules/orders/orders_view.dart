import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:viet_tour/core/utils/responsive.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/models/customer_booking_model.dart';
import 'orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Đơn của tôi',
        style: TextStyle(
          fontSize: Responsive.font(18),
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.loadOrders,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Tải lại đơn hàng',
        ),
      ],
    ),
    body: Column(
      children: [
        SizedBox(
          height: 5.h,
          child: Obx(
            () => ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              children: OrdersController.statuses
                  .map(
                    (status) => CategoryChip(
                      label: status,
                      selected: controller.selectedStatus.value == status,
                      onTap: () => controller.selectedStatus.value = status,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            final orders = controller.orders;
            if (controller.loading.value && controller.allOrders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (orders.isEmpty) {
              return RefreshIndicator(
                onRefresh: controller.loadOrders,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 18.h),
                    EmptyState(
                      title: controller.errorMessage.value.isNotEmpty
                          ? 'Không tải được đơn hàng'
                          : 'Chưa có đơn đặt tour',
                      message: controller.errorMessage.value.isNotEmpty
                          ? controller.errorMessage.value
                          : 'Các chuyến đi của bạn sẽ được hiển thị tại đây.',
                      icon: controller.errorMessage.value.isNotEmpty
                          ? Icons.cloud_off_outlined
                          : Icons.confirmation_number_outlined,
                      action: controller.errorMessage.value.isNotEmpty
                          ? 'Thử lại'
                          : null,
                      onAction: controller.loadOrders,
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.loadOrders,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
                itemCount:
                    orders.length +
                    (controller.errorMessage.value.isNotEmpty ? 1 : 0),
                separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
                itemBuilder: (_, index) {
                  if (controller.errorMessage.value.isNotEmpty && index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: Responsive.font(10),
                        ),
                      ),
                    );
                  }
                  final orderIndex = controller.errorMessage.value.isNotEmpty
                      ? index - 1
                      : index;
                  return _OrderCard(
                    booking: orders[orderIndex],
                    onTap: () => _showOrder(context, orders[orderIndex]),
                  );
                },
              ),
            );
          }),
        ),
      ],
    ),
  );

  void _showOrder(BuildContext context, CustomerBookingModel booking) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.radius(20)),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(Responsive.radius(99)),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Chi tiết đơn ${booking.code}',
                style: TextStyle(
                  fontSize: Responsive.font(17),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 1.5.h),
              Text(
                booking.tour.title,
                style: TextStyle(
                  fontSize: Responsive.font(13),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Khởi hành: ${Formatters.date(booking.departureDate)} · ${booking.adults} người lớn, ${booking.children} trẻ em',
                style: TextStyle(
                  fontSize: Responsive.font(10.5),
                  color: AppColors.muted,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Trạng thái đơn: ${booking.statusLabel}',
                style: TextStyle(
                  fontSize: Responsive.font(10.5),
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Thanh toán: ${booking.paymentStatus}',
                style: TextStyle(
                  fontSize: Responsive.font(10.5),
                  color: AppColors.muted,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Tổng thanh toán: ${Formatters.currency(booking.total)}',
                style: TextStyle(
                  fontSize: Responsive.font(12),
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (booking.amountDue > 0) ...[
                SizedBox(height: 0.5.h),
                Text(
                  'Còn phải thanh toán: ${Formatters.currency(booking.amountDue)}',
                  style: TextStyle(
                    fontSize: Responsive.font(10.5),
                    color: AppColors.muted,
                  ),
                ),
              ],
              SizedBox(height: 2.h),
              if (booking.canPay)
                AppButton(
                  label: 'Thanh toán lại với VNPay',
                  icon: Icons.credit_card_rounded,
                  onPressed: () {
                    Get.back();
                    controller.payAgain(booking);
                  },
                ),
              if (booking.isPaid) ...[
                if (booking.canPay) SizedBox(height: 1.h),
                AppButton(
                  label: 'Xem vé điện tử',
                  icon: Icons.qr_code_rounded,
                  outlined: true,
                  onPressed: () {
                    Get.back();
                    controller.openTicket(booking);
                  },
                ),
              ],
              if (booking.canCancel) ...[
                SizedBox(height: 1.h),
                AppButton(
                  label: 'Hủy đơn',
                  outlined: true,
                  onPressed: () {
                    Get.back();
                    _confirmCancellation(context, booking);
                  },
                ),
              ],
              if (booking.canReview) ...[
                SizedBox(height: 1.h),
                AppButton(
                  label: 'Viết đánh giá',
                  icon: Icons.star_outline_rounded,
                  outlined: true,
                  onPressed: () {
                    Get.back();
                    _showReviewDialog(context, booking);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancellation(
    BuildContext context,
    CustomerBookingModel booking,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn đặt tour?'),
        content: const Text(
          'Đơn chưa thanh toán sẽ bị hủy và số chỗ được hoàn lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Giữ đơn'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận hủy'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.cancelBooking(booking);
  }

  Future<void> _showReviewDialog(
    BuildContext context,
    CustomerBookingModel booking,
  ) async {
    var stars = 5;
    final comment = TextEditingController();
    var submitted = false;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Đánh giá chuyến đi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    onPressed: () => setState(() => stars = index + 1),
                    icon: Icon(
                      index < stars ? Icons.star_rounded : Icons.star_outline,
                      color: AppColors.orange,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: comment,
                maxLength: 2000,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Chia sẻ trải nghiệm của bạn (không bắt buộc)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Để sau'),
            ),
            FilledButton(
              onPressed: () {
                submitted = true;
                Navigator.pop(context);
              },
              child: const Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
    if (submitted) {
      await controller.submitReview(
        booking,
        stars: stars,
        comment: comment.text,
      );
    }
    comment.dispose();
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.booking, required this.onTap});

  final CustomerBookingModel booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = booking.status == 'Da thanh toan'
        ? AppColors.green
        : booking.status == 'Hoan thanh'
        ? AppColors.blue
        : booking.status == 'Da huy'
        ? AppColors.muted
        : AppColors.orange;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(Responsive.radius(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.radius(15)),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mã đơn ${booking.code}',
                      style: TextStyle(
                        fontSize: Responsive.font(10),
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.5.w,
                      vertical: 0.7.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha((255 * 0.1).round()),
                      borderRadius: BorderRadius.circular(
                        Responsive.radius(99),
                      ),
                    ),
                    child: Text(
                      booking.statusLabel,
                      style: TextStyle(
                        color: color,
                        fontSize: Responsive.font(9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              Row(
                children: [
                  SizedBox(
                    width: 24.w,
                    height: 17.w,
                    child: AppNetworkImage(
                      url: booking.tour.imageUrl,
                      borderRadius: 10,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.tour.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Responsive.font(11.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        Text(
                          'Khởi hành ${Formatters.date(booking.departureDate)}',
                          style: TextStyle(
                            fontSize: Responsive.font(9.5),
                            color: AppColors.muted,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        Text(
                          booking.paymentStatus,
                          style: TextStyle(
                            fontSize: Responsive.font(9.5),
                            color: AppColors.muted,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        Text(
                          Formatters.currency(booking.total),
                          style: TextStyle(
                            fontSize: Responsive.font(11),
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

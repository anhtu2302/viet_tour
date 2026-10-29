import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:viet_tour/core/utils/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/app_widgets.dart';
import 'booking_controller.dart';

class BookingView extends GetView<BookingController> {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Đặt tour',
        style: TextStyle(
          fontSize: Responsive.font(18),
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    body: Form(
      key: controller.formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
        children: [
          _heading('CHUYẾN ĐI'),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.radius(14)),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 27.w,
                  height: 19.w,
                  child: AppNetworkImage(
                    url: controller.tour.imageUrl,
                    borderRadius: 10,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.tour.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Responsive.font(11.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 0.7.h),
                      Text(
                        '${controller.tour.duration} · ${controller.tour.destination}',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: Responsive.font(9.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.5.h),
          _heading('NGÀY KHỞI HÀNH'),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.radius(12)),
              border: Border.all(color: AppColors.border),
            ),
            child: Obx(() {
              final departure = controller.selectedDeparture.value;
              if (departure == null) {
                return const Text('Chưa chọn lịch khởi hành.');
              }
              return Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Formatters.date(departure.startDate)} - ${Formatters.date(departure.endDate)}',
                          style: TextStyle(
                            fontSize: Responsive.font(11.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Còn ${departure.remainingSeats} chỗ',
                          style: TextStyle(
                            fontSize: Responsive.font(9.5),
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 2.5.h),
          _heading('SỐ LƯỢNG KHÁCH'),
          _stepper(
            'Người lớn',
            'Từ 12 tuổi',
            controller.adults,
            canDecrease: (value) => value > 1,
            canIncrease: () =>
                controller.adults.value + controller.children.value <
                controller.availableSeats,
            onDecrease: controller.decrementAdults,
            onIncrease: controller.incrementAdults,
          ),
          SizedBox(height: 1.h),
          _stepper(
            'Trẻ em',
            'Giá theo bảng giá tour',
            controller.children,
            canDecrease: (value) => value > 0,
            canIncrease: () =>
                controller.adults.value + controller.children.value <
                controller.availableSeats,
            onDecrease: controller.decrementChildren,
            onIncrease: controller.incrementChildren,
          ),
          SizedBox(height: 2.5.h),
          _heading('THÔNG TIN LIÊN HỆ'),
          Text(
            'Thông tin này sẽ cập nhật hồ sơ khách hàng của bạn.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: Responsive.font(9.5),
            ),
          ),
          SizedBox(height: 1.h),
          AppTextField(
            label: 'Họ và tên',
            controller: controller.contactName,
            prefixIcon: Icons.person_outline_rounded,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lòng nhập họ tên'
                : null,
          ),
          SizedBox(height: 1.5.h),
          AppTextField(
            label: 'Email',
            hint: 'ban@email.com',
            controller: controller.contactEmail,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
            validator: (value) =>
                value == null || !GetUtils.isEmail(value.trim())
                ? 'Vui lòng nhập email hợp lệ'
                : null,
          ),
          SizedBox(height: 1.5.h),
          AppTextField(
            label: 'Số điện thoại',
            hint: '09xx xxx xxx',
            controller: controller.contactPhone,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.call_outlined,
            validator: (value) => value == null || value.trim().length < 9
                ? 'Vui lòng nhập số điện thoại hợp lệ'
                : null,
          ),
          SizedBox(height: 2.5.h),
          _heading('MÃ ƯU ĐÃI'),
          Obx(
            () => controller.appliedVoucher.value == null
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.voucherCode,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'Nhập mã giảm giá',
                            prefixIcon: Icon(Icons.local_offer_outlined),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      TextButton(
                        onPressed: controller.voucherLoading.value
                            ? null
                            : controller.applyVoucher,
                        child: controller.voucherLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Áp dụng'),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Đã áp dụng ${controller.appliedVoucher.value}',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: Responsive.font(10),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: controller.removeVoucher,
                        child: const Text('Bỏ mã'),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: 2.5.h),
          _heading('THANH TOÁN'),
          const Text('Bạn sẽ chọn phương thức thanh toán sau khi tạo đơn.'),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.radius(14)),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Obx(
                  () => _priceRow(
                    'Người lớn × ${controller.adults.value}',
                    (controller.selectedDeparture.value?.price ??
                            controller.tour.price) *
                        controller.adults.value,
                  ),
                ),
                Obx(
                  () => controller.children.value == 0
                      ? const SizedBox.shrink()
                      : _priceRow(
                          'Trẻ em × ${controller.children.value}',
                          controller.tour.childPrice *
                              controller.children.value,
                        ),
                ),
                Obx(
                  () => controller.voucherDiscount.value == 0
                      ? const SizedBox.shrink()
                      : _priceRow('Ưu đãi', -controller.voucherDiscount.value),
                ),
                Divider(height: 2.5.h),
                Obx(
                  () => _priceRow(
                    'Tổng thanh toán',
                    controller.totalAfterDiscount,
                    bold: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Obx(
            () => AppButton(
              label: 'XÁC NHẬN ĐẶT TOUR',
              icon: Icons.lock_outline_rounded,
              loading: controller.loading.value,
              onPressed: controller.confirm,
            ),
          ),
          SizedBox(height: 1.h),
          Center(
            child: Text(
              'Thông tin của bạn được bảo mật an toàn',
              style: TextStyle(
                fontSize: Responsive.font(9),
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _heading(String text) => Padding(
    padding: EdgeInsets.only(bottom: 1.2.h),
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.primary,
        fontSize: Responsive.font(10),
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _stepper(
    String title,
    String subtitle,
    RxInt value, {
    required bool Function(int) canDecrease,
    required bool Function() canIncrease,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) => Obx(
    () => Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Responsive.radius(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.font(12),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: Responsive.font(9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: canDecrease(value.value) ? onDecrease : null,
            icon: const Icon(
              Icons.remove_circle_outline_rounded,
              color: AppColors.muted,
            ),
          ),
          Text(
            '${value.value}',
            style: TextStyle(
              fontSize: Responsive.font(13),
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            onPressed: canIncrease() ? onIncrease : null,
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _priceRow(String label, int value, {bool bold = false}) => Padding(
    padding: EdgeInsets.symmetric(vertical: 0.5.h),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: bold ? Responsive.font(12) : Responsive.font(10.5),
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          Formatters.currency(value),
          style: TextStyle(
            fontSize: bold ? Responsive.font(13) : Responsive.font(10.5),
            color: bold ? AppColors.primary : AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

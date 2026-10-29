import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:viet_tour/core/utils/responsive.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import 'ticket_controller.dart';

class TicketView extends GetView<TicketController> {
  const TicketView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Vé điện tử',
        style: TextStyle(
          fontSize: Responsive.font(18),
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.loadTicket,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Tải lại vé',
        ),
      ],
    ),
    body: Obx(() {
      if (controller.loading.value && controller.ticket.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final order = controller.ticket.value;
      if (order == null) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: Responsive.font(12),
                  ),
                ),
                SizedBox(height: 2.h),
                TextButton(
                  onPressed: controller.loadTicket,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        );
      }
      final schedule = order['LichKhoiHanh'] as Map<String, dynamic>;
      final tour = schedule['Tour'] as Map<String, dynamic>;
      final passengers =
          order['ChiTietHanhKhach'] as List<dynamic>? ?? const [];
      final departureDate = DateTime.parse(schedule['NgayKhoiHanh'] as String);
      return RefreshIndicator(
        onRefresh: controller.loadTicket,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Responsive.radius(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['MaDon']?.toString() ?? controller.bookingCode,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: Responsive.font(11),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    tour['TenTour']?.toString() ?? 'Tour',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: Responsive.font(16),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Ngày khởi hành: ${Formatters.date(departureDate)}',
                    style: TextStyle(fontSize: Responsive.font(11)),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Số hành khách: ${passengers.length}',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: Responsive.font(10),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            ...passengers.map((entry) {
              final passenger = entry as Map<String, dynamic>;
              final qrCode = passenger['MaQRVe']?.toString() ?? '';
              return Container(
                margin: EdgeInsets.only(bottom: 1.5.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.radius(15)),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      passenger['HoTen']?.toString() ?? 'Hành khách',
                      style: TextStyle(
                        fontSize: Responsive.font(13),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      passenger['LoaiKhach']?.toString() ?? '',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: Responsive.font(10),
                      ),
                    ),
                    if (qrCode.isNotEmpty) ...[
                      SizedBox(height: 1.h),
                      QrImageView(
                        data: qrCode,
                        size: 52.w,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                      Text(
                        qrCode,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: Responsive.font(9),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }),
  );
}

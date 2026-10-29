import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_routes.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/network/api_client.dart';
import '../../data/models/departure_model.dart';
import '../../data/models/tour_model.dart';
import '../../data/services/booking_service.dart';

class BookingController extends GetxController {
  BookingController({BookingService? bookingService})
    : _bookingService = bookingService ?? BookingService();

  final BookingService _bookingService;
  late final TourModel tour;
  final selectedDeparture = Rxn<DepartureModel>();
  final adults = 1.obs;
  final children = 0.obs;
  final loading = false.obs;
  final contactName = TextEditingController();
  final contactEmail = TextEditingController();
  final contactPhone = TextEditingController();
  final voucherCode = TextEditingController();
  final voucherLoading = false.obs;
  final voucherDiscount = 0.obs;
  final appliedVoucher = RxnString();
  final formKey = GlobalKey<FormState>();

  int get total {
    final adultPrice = selectedDeparture.value?.price ?? tour.price;
    return adultPrice * adults.value + tour.childPrice * children.value;
  }

  int get availableSeats => selectedDeparture.value?.remainingSeats ?? 0;
  int get totalAfterDiscount =>
      (total - voucherDiscount.value).clamp(0, total).toInt();

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is! Map ||
        arguments['tour'] is! TourModel ||
        arguments['departure'] is! DepartureModel) {
      throw StateError('Thiếu thông tin tour hoặc lịch khởi hành.');
    }
    tour = arguments['tour'] as TourModel;
    selectedDeparture.value = arguments['departure'] as DepartureModel;

    final user = Get.find<AppController>().currentUser.value;
    contactName.text = (user?['name'] ?? user?['hoTen'] ?? '').toString();
    contactEmail.text = (user?['email'] ?? '').toString();
    contactPhone.text = (user?['phone'] ?? '').toString();
  }

  void setDeparture(DepartureModel? departure) {
    selectedDeparture.value = departure;
    _clearVoucher();
    if (departure != null &&
        adults.value + children.value > departure.remainingSeats) {
      if (adults.value > departure.remainingSeats) {
        adults.value = departure.remainingSeats > 0
            ? departure.remainingSeats
            : 1;
      }
      children.value = (departure.remainingSeats - adults.value)
          .clamp(0, 20)
          .toInt();
    }
  }

  void incrementAdults() {
    if (adults.value + children.value < availableSeats) {
      adults.value++;
      _clearVoucher();
    }
  }

  void decrementAdults() {
    if (adults.value > 1) {
      adults.value--;
      _clearVoucher();
    }
  }

  void incrementChildren() {
    if (adults.value + children.value < availableSeats) {
      children.value++;
      _clearVoucher();
    }
  }

  void decrementChildren() {
    if (children.value > 0) {
      children.value--;
      _clearVoucher();
    }
  }

  Future<void> applyVoucher() async {
    final departure = selectedDeparture.value;
    final code = voucherCode.text.trim();
    if (code.isEmpty) {
      Get.snackbar('Mã ưu đãi', 'Vui lòng nhập mã ưu đãi.');
      return;
    }
    if (departure == null || !departure.isBookable) {
      Get.snackbar('Mã ưu đãi', 'Vui lòng chọn lịch khởi hành còn chỗ.');
      return;
    }
    voucherLoading.value = true;
    try {
      final result = await _bookingService.validateVoucher(
        code: code,
        departureId: departure.id,
        adults: adults.value,
        children: children.value,
      );
      voucherDiscount.value = (result['giamGia'] as num).round();
      appliedVoucher.value = result['maKhuyenMai']?.toString() ?? code;
      Get.snackbar('Đã áp dụng mã', 'Mã ưu đãi đã được xác nhận từ máy chủ.');
    } on ApiClientException catch (error) {
      _clearVoucher();
      Get.snackbar('Mã ưu đãi không hợp lệ', error.message);
    } finally {
      voucherLoading.value = false;
    }
  }

  void _clearVoucher() {
    voucherDiscount.value = 0;
    appliedVoucher.value = null;
  }

  void removeVoucher() {
    voucherCode.clear();
    _clearVoucher();
  }

  Future<void> confirm() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final departure = selectedDeparture.value;
    if (departure == null || !departure.isBookable) {
      Get.snackbar(
        'Không thể đặt tour',
        'Vui lòng chọn lịch khởi hành còn chỗ.',
      );
      return;
    }
    if (adults.value + children.value > departure.remainingSeats) {
      Get.snackbar('Không đủ chỗ', 'Số khách vượt quá số chỗ còn lại.');
      return;
    }

    loading.value = true;
    try {
      final booking = await _bookingService.createBooking(
        departureId: departure.id,
        adults: adults.value,
        children: children.value,
        contactName: contactName.text.trim(),
        contactEmail: contactEmail.text.trim(),
        contactPhone: contactPhone.text.trim(),
        voucherCode: appliedVoucher.value,
      );
      Get.offNamed(AppRoutes.bookingSuccess, arguments: booking);
    } on ApiClientException catch (error) {
      Get.snackbar('Không thể tạo đơn', error.message);
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    contactName.dispose();
    contactEmail.dispose();
    contactPhone.dispose();
    voucherCode.dispose();
    super.onClose();
  }
}

class BookingBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<BookingController>(BookingController.new);
}

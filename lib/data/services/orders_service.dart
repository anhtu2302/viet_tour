import '../../core/constants/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/customer_booking_model.dart';

class OrdersService {
  OrdersService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<CustomerBookingModel>> getMyBookings() async {
    final response = await _api.getJson(ApiConfig.myBookings);
    if (response is! List<dynamic>) {
      throw const ApiClientException(
        statusCode: 502,
        message: 'Danh sách đơn hàng từ máy chủ không hợp lệ.',
      );
    }
    return response
        .map(
          (entry) =>
              CustomerBookingModel.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> cancelBooking(int bookingId) async {
    await _api.postJson(ApiConfig.bookingCancel(bookingId));
  }

  Future<void> submitReview(
    int bookingId, {
    required int stars,
    required String comment,
  }) async {
    await _api.postJson(
      ApiConfig.bookingReview(bookingId),
      body: {
        'soSao': stars,
        if (comment.trim().isNotEmpty) 'binhLuan': comment.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> getTicket(String bookingCode) async {
    final response = await _api.getJson(
      ApiConfig.ticketByOrderCode(bookingCode),
    );
    if (response is! Map<String, dynamic>) {
      throw const ApiClientException(
        statusCode: 502,
        message: 'Thông tin vé điện tử từ máy chủ không hợp lệ.',
      );
    }
    return response;
  }
}

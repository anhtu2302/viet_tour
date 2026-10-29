import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../data/services/orders_service.dart';

class TicketController extends GetxController {
  TicketController({OrdersService? ordersService})
    : _ordersService = ordersService ?? OrdersService();

  final OrdersService _ordersService;
  final ticket = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final errorMessage = ''.obs;
  late final String bookingCode;

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    if (argument is! String || argument.isEmpty) {
      throw StateError('Thiếu mã đơn để tra cứu vé điện tử.');
    }
    bookingCode = argument;
    loadTicket();
  }

  Future<void> loadTicket() async {
    loading.value = true;
    errorMessage.value = '';
    try {
      ticket.value = await _ordersService.getTicket(bookingCode);
    } on ApiClientException catch (error) {
      errorMessage.value = error.message;
    } finally {
      loading.value = false;
    }
  }
}

class TicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TicketController>(TicketController.new);
  }
}

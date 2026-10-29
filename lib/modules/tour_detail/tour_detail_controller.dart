import 'package:get/get.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/departure_model.dart';
import '../../data/models/tour_model.dart';
import '../../data/services/tour_service.dart';

class TourDetailController extends GetxController {
  TourDetailController({TourService? tourService})
    : _tourService = tourService ?? TourService();

  final TourService _tourService;
  late final TourModel tour;
  final selectedImage = 0.obs;
  final departures = <DepartureModel>[].obs;
  final selectedDepartureId = RxnInt();
  final loadingDepartures = false.obs;

  @override
  void onInit() {
    super.onInit();
    tour = Get.arguments as TourModel;
    departures.assignAll(tour.departures);
    _loadDepartures();
  }

  DepartureModel? get selectedDeparture {
    final id = selectedDepartureId.value;
    if (id == null) return null;
    for (final departure in departures) {
      if (departure.id == id) return departure;
    }
    return null;
  }

  Future<void> _loadDepartures() async {
    final id = int.tryParse(tour.id);
    if (id == null) return;
    loadingDepartures.value = true;
    try {
      final detail = await _tourService.fetchTourById(id);
      departures.assignAll(detail.departures);
      selectedDepartureId.value = null;
    } on ApiException catch (error) {
      Get.snackbar('Không tải được lịch khởi hành', error.message);
    } finally {
      loadingDepartures.value = false;
    }
  }

  void bookSelectedDeparture() {
    final departure = selectedDeparture;
    if (departure == null || !departure.isBookable) {
      Get.snackbar('Chọn lịch khởi hành', 'Vui lòng chọn lịch còn chỗ.');
      return;
    }
    Get.toNamed(
      AppRoutes.booking,
      arguments: {'tour': tour, 'departure': departure},
    );
  }
}

class TourDetailBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<TourDetailController>(TourDetailController.new);
}

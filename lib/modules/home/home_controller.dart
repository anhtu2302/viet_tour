import 'package:get/get.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/tour_model.dart';
import '../../data/services/tour_service.dart';

/// Load state for async data fetched from the backend.
enum LoadState { idle, loading, success, error, empty }

class HomeController extends GetxController {
  HomeController({TourService? tourService})
      : _tourService = tourService ?? TourService();

  final TourService _tourService;

  final selectedFilter = 'Tất cả Tour'.obs;
  final bannerIndex = 0.obs;

  /// Current load state for the tour list.
  final loadState = LoadState.idle.obs;

  /// Human-readable error message shown when [loadState] == [LoadState.error].
  final errorMessage = ''.obs;

  /// Tours fetched from the backend (may be empty if API unavailable).
  final _apiTours = <TourModel>[].obs;

  /// Whether the tour list is coming from the backend (true) or mock data (false).
  bool get _usingApi => _apiTours.isNotEmpty;

  final filters = const [
    'Tất cả Tour',
    'Tour Miền Trung',
    'Tour Miền Bắc',
    'Tour Quốc Tế',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchTours();
  }

  /// Fetches all tours from the NestJS backend.
  ///
  /// Falls back gracefully to [MockData] when the backend is unreachable so the
  /// UI still renders during development without the backend running.
  Future<void> fetchTours() async {
    loadState.value = LoadState.loading;
    errorMessage.value = '';
    try {
      final tours = await _tourService.fetchTours();
      _apiTours.assignAll(tours);
      loadState.value = tours.isEmpty ? LoadState.empty : LoadState.success;
    } catch (e) {
      // Backend unreachable — surface the error but let the UI fall back to
      // mock data so the rest of the app is still usable.
      errorMessage.value = _friendlyError(e);
      loadState.value = LoadState.error;
      // Keep any previously loaded tours; if none, use mock as fallback.
      if (_apiTours.isEmpty) {
        _apiTours.assignAll(MockData.tours);
      }
    }
  }

  /// All visible tours filtered by the currently selected tab.
  List<TourModel> get visibleTours {
    final source = _usingApi ? _apiTours : MockData.tours;
    if (selectedFilter.value == 'Tất cả Tour') return source;
    final region = selectedFilter.value.replaceFirst('Tour ', '');
    return source.where((tour) => tour.region == region).toList();
  }

  /// All tours (unfiltered) — used by search screen.
  List<TourModel> get allTours =>
      _usingApi ? List<TourModel>.unmodifiable(_apiTours) : MockData.tours;

  void selectFilter(String value) => selectedFilter.value = value;

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Failed host lookup')) {
      return 'Không kết nối được backend. Đảm bảo backend đang chạy tại http://localhost:4000';
    }
    return msg;
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<HomeController>(HomeController.new);
}

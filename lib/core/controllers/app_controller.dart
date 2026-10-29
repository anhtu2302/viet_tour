import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/tour_model.dart';
import '../../data/services/payment_service.dart';
import '../../modules/home/home_controller.dart';

class AppController extends GetxController {
  final selectedTab = 0.obs;

  final favoriteIds = <String>[].obs;
  final Map<String, bool> _pendingFavoriteChanges = {};
  final Completer<void> _favoritesReady = Completer<void>();
  final Completer<void> _initialPaymentLinkReady = Completer<void>();
  Future<void> _favoriteWrites = Future<void>.value();
  Uri? _initialPaymentLink;
  static const _favoriteStorageKey = 'viettour_favorite_tour_ids';

  final currentUser = Rxn<Map<String, dynamic>>();

  String get displayName {
    final user = currentUser.value;
    if (user == null) return 'Khách hàng';
    return (user['name'] ?? user['hoTen'] ?? user['email'] ?? 'Khách hàng')
        .toString();
  }

  String get userInitials {
    final name = displayName.trim();
    if (name.isEmpty) return 'VT';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  final searchQuery = ''.obs;
  final departureDate = Rxn<DateTime>();
  final guestCount = 2.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(_restoreFavorites());
    unawaited(_captureInitialPaymentLink());
  }

  Future<void> _captureInitialPaymentLink() async {
    try {
      _initialPaymentLink = await AppLinks().getInitialLink();
    } on PlatformException catch (error) {
      Get.snackbar(
        'Không đọc được liên kết thanh toán',
        error.message ??
            'Vui lòng kiểm tra trạng thái đơn trong mục Đơn của tôi.',
      );
    } on MissingPluginException catch (error) {
      Get.snackbar(
        'Không hỗ trợ liên kết thanh toán',
        error.message ??
            'Vui lòng kiểm tra trạng thái đơn trong mục Đơn của tôi.',
      );
    } finally {
      _initialPaymentLinkReady.complete();
    }
  }

  Future<void> processInitialPaymentReturn() async {
    await _initialPaymentLinkReady.future;
    final uri = _initialPaymentLink;
    _initialPaymentLink = null;
    if (uri == null ||
        uri.scheme != 'viettour' ||
        uri.host != 'payment-result') {
      return;
    }
    final bookingId = int.tryParse(uri.queryParameters['donHangId'] ?? '');
    if (bookingId == null) return;
    try {
      final status = await PaymentService().getPaymentStatus(bookingId);
      Get.snackbar(
        status['trangThaiDon'] == 'Da thanh toan'
            ? 'Thanh toán thành công'
            : 'Thanh toán chưa hoàn tất',
        status['trangThaiDon'] == 'Da thanh toan'
            ? 'Đơn ${status['donHangId']} đã được xác nhận từ máy chủ.'
            : 'Đơn vẫn chưa được ghi nhận thanh toán.',
      );
    } on ApiClientException catch (error) {
      Get.snackbar('Không kiểm tra được thanh toán', error.message);
    }
  }

  List<TourModel> get favorites {
    List<TourModel> source;
    try {
      // HomeController is registered by MainShellBinding once the main shell loads.
      source = Get.find<HomeController>().allTours;
    } catch (_) {
      // Home not yet loaded; use mock as fallback so Wishlist tab isn't empty.
      source = MockData.tours;
    }
    if (source.isEmpty) source = MockData.tours;
    return source.where((tour) => favoriteIds.contains(tour.id)).toList();
  }

  bool isFavorite(String tourId) => favoriteIds.contains(tourId);

  void toggleFavorite(TourModel tour) {
    final shouldAdd = !favoriteIds.contains(tour.id);
    if (shouldAdd) {
      favoriteIds.add(tour.id);
    } else {
      favoriteIds.remove(tour.id);
    }
    if (!_favoritesReady.isCompleted) {
      _pendingFavoriteChanges[tour.id] = shouldAdd;
      return;
    }
    unawaited(_queueFavoritePersistence());
  }

  Future<void> _restoreFavorites() async {
    var restored = false;
    try {
      final preferences = await SharedPreferences.getInstance();
      favoriteIds.assignAll(
        preferences.getStringList(_favoriteStorageKey) ?? const [],
      );
      restored = true;
    } catch (error) {
      Get.snackbar(
        'Không tải được yêu thích',
        'Không thể khôi phục danh sách yêu thích trên thiết bị: $error',
      );
    } finally {
      final pendingChanges = Map<String, bool>.from(_pendingFavoriteChanges);
      for (final entry in pendingChanges.entries) {
        if (entry.value) {
          if (!favoriteIds.contains(entry.key)) favoriteIds.add(entry.key);
        } else {
          favoriteIds.remove(entry.key);
        }
      }
      _pendingFavoriteChanges.clear();
      _favoritesReady.complete();
      if (restored || pendingChanges.isNotEmpty) {
        await _queueFavoritePersistence();
      }
    }
  }

  Future<void> _queueFavoritePersistence() {
    _favoriteWrites = _favoriteWrites.then((_) => _persistFavorites());
    return _favoriteWrites;
  }

  Future<void> _persistFavorites() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        _favoriteStorageKey,
        favoriteIds.toList(),
      );
    } catch (error) {
      Get.snackbar(
        'Không lưu được yêu thích',
        'Không thể lưu danh sách yêu thích trên thiết bị: $error',
      );
    }
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppController(), permanent: true);
  }
}

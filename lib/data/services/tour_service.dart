import 'package:http/http.dart' as http;
import '../models/tour_model.dart';
import '../../core/constants/api_config.dart';
import '../../core/network/api_client.dart';

/// Service responsible for communicating with the NestJS backend tour endpoints.
///
/// Endpoints used:
///   GET  /api/tours            — list all tours (with optional query params)
///   GET  /api/tours/:id        — single tour detail
///   GET  /api/tours/categories — tour categories
///
/// The backend runs at [ApiConfig.baseUrl] (`http://localhost:4000/api`).
/// On Windows Desktop `localhost` resolves to the same machine; no emulator
/// remapping is needed.
class TourService {
  TourService({http.Client? client}) : _api = ApiClient(client: client);

  final ApiClient _api;

  /// Fetch all tours.  Pass optional filters to narrow results.
  ///
  /// [search]    — full-text match on TenTour / MaTour
  /// [diemDen]   — destination contains filter
  Future<List<TourModel>> fetchTours({
    String? search,
    String? diemDen,
    String? trangThai,
  }) async {
    final uri = Uri.parse(ApiConfig.tours).replace(
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (diemDen != null && diemDen.isNotEmpty) 'diemDen': diemDen,
        'trangThai': ?trangThai,
      },
    );

    try {
      final response = await _api.getJson(uri.toString());
      if (response is! List<dynamic>) {
        throw const ApiException(
          statusCode: 502,
          message: 'Danh sách tour từ máy chủ không hợp lệ.',
        );
      }
      return response
          .map((e) => TourModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiClientException catch (error) {
      throw ApiException(statusCode: error.statusCode, message: error.message);
    }
  }

  /// Fetch a single tour by its integer primary key.
  Future<TourModel> fetchTourById(int id) async {
    try {
      final response = await _api.getJson(ApiConfig.tourById(id));
      if (response is! Map<String, dynamic>) {
        throw const ApiException(
          statusCode: 502,
          message: 'Thông tin tour từ máy chủ không hợp lệ.',
        );
      }
      return TourModel.fromJson(response);
    } on ApiClientException catch (error) {
      throw ApiException(statusCode: error.statusCode, message: error.message);
    }
  }
}

/// Exception thrown when the backend returns a non-2xx status code.
class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.message});
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

import 'departure_model.dart';

/// Typed model for a tour record returned by the NestJS backend.
///
/// The backend endpoint `GET /api/tours` returns an array of `Tour` Prisma
/// objects.  Field names follow the Prisma schema (PascalCase mapped from the
/// PostgreSQL snake_case columns).
///
/// The Flutter model mirrors the existing UI contract so screens that already
/// reference [TourModel] continue to work without changes.
class TourModel {
  const TourModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.region,
    required this.duration,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.departure,
    required this.imageUrl,
    required this.category,
    required this.itinerary,
    this.includesAirfare = true,
    this.isInternational = false,
    this.childPrice = 0,
    this.departures = const [],
  });

  final String id;
  final String title;
  final String destination;
  final String region;
  final String duration;
  final int price;
  final int originalPrice;
  final double rating;
  final int reviewCount;
  final String departure;
  final String imageUrl;
  final String category;
  final List<String> itinerary;
  final bool includesAirfare;
  final bool isInternational;
  final int childPrice;
  final List<DepartureModel> departures;

  // ── JSON deserialization from the NestJS /api/tours response ──────────────

  factory TourModel.fromJson(Map<String, dynamic> json) {
    // Average rating from DanhGia (review) relation, fallback to 0.
    final reviews = json['DanhGia'] as List<dynamic>? ?? [];
    double rating = 0;
    if (reviews.isNotEmpty) {
      final sum = reviews.fold<num>(
        0,
        (prev, r) => prev + ((r as Map<String, dynamic>)['SaoXepHang'] ?? 0),
      );
      rating = sum / reviews.length;
    }

    // Build a human-readable duration from ThoiGian or SoNgay/SoDem fields.
    final thoiGian = (json['ThoiGian'] as String?) ?? '';
    final soNgay = (json['SoNgay'] as num?)?.toInt() ?? 0;
    final soDem = (json['SoDem'] as num?)?.toInt() ?? 0;
    final duration = thoiGian.isNotEmpty
        ? thoiGian
        : (soNgay > 0 ? '$soNgay Ngày $soDem Đêm' : 'N/A');

    // Pick the first available image or fall back to empty string.
    final hinhAnh =
        (json['HinhAnhURL'] as String?) ??
        (json['AnhDaiDien'] as String?) ??
        '';
    final imageUrl = hinhAnh.isNotEmpty
        ? hinhAnh
        : 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=1000';

    // Category label from the nested DanhMuc relation.
    final danhMuc = json['DanhMuc'] as Map<String, dynamic>?;
    final category = (danhMuc?['TenDanhMuc'] as String?) ?? 'Tour';
    final adultPrice = _parseInt(json['GiaNguoiLon']);
    final departuresRaw = json['LichKhoiHanh'] as List<dynamic>? ?? const [];
    final departures = departuresRaw
        .map(
          (entry) => DepartureModel.fromJson(
            entry as Map<String, dynamic>,
            fallbackPrice: adultPrice,
          ),
        )
        .toList();

    // Determine if international by checking category and DiemDen (destination).
    final diemDen = (json['DiemDen'] as String?) ?? '';
    final categoryLower = category.toLowerCase();
    final isInternational =
        categoryLower.contains('quoc te') ||
        categoryLower.contains('quốc tế') ||
        (!diemDen.toLowerCase().contains('việt nam') &&
            diemDen.isNotEmpty &&
            (categoryLower.contains('quốc tế') ||
                (json['LoaiTour'] as String? ?? '').toLowerCase().contains(
                  'quoc te',
                )));

    // Itinerary from LichTrinhTour if present; else build from LichTrinh / MoTaChiTiet.
    final itineraryRaw = json['LichTrinhTour'] as List<dynamic>?;
    final List<String> itinerary;
    if (itineraryRaw != null && itineraryRaw.isNotEmpty) {
      itinerary = itineraryRaw
          .map((e) => (e as Map<String, dynamic>)['NoiDung'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      final lichTrinh = (json['LichTrinh'] as String?) ?? '';
      if (lichTrinh.isNotEmpty) {
        itinerary = lichTrinh
            .split(RegExp(r'(?<=\.)\s+|\n+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        final mota =
            (json['MoTaChiTiet'] as String?) ?? (json['MoTa'] as String?) ?? '';
        itinerary = mota.isNotEmpty ? [mota] : [];
      }
    }

    return TourModel(
      id: (json['TourID'] ?? '').toString(),
      title: (json['TenTour'] as String?) ?? 'Tour',
      destination: diemDen,
      region:
          (json['KhuVuc'] as String?) ??
          (diemDen.isNotEmpty ? diemDen : category),
      duration: duration,
      price: adultPrice,
      originalPrice: _parseInt(json['GiaGoc'] ?? json['GiaNguoiLon']),
      childPrice: _parseInt(json['GiaTreEm']),
      departures: departures,
      rating: double.parse(rating.toStringAsFixed(1)),
      reviewCount: reviews.length,
      departure: (json['DiemKhoiHanh'] as String?) ?? '',
      imageUrl: imageUrl,
      category: category,
      itinerary: itinerary,
      includesAirfare:
          (json['BaoGomVeMayBay'] as bool?) ??
          category.toLowerCase().contains('quốc tế'),
      isInternational: isInternational,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final str = value.toString();
    final asDouble = double.tryParse(str);
    return asDouble?.toInt() ?? 0;
  }
}

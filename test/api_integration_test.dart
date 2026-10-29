import 'package:flutter_test/flutter_test.dart';
import 'package:viet_tour/data/services/tour_service.dart';

void main() {
  test('TourService fetches and parses real tours from backend API', () async {
    final service = TourService();
    final tours = await service.fetchTours();

    expect(tours, isNotEmpty);
    expect(tours.length, equals(5));

    final first = tours.first;
    expect(first.id, equals('1'));
    expect(first.title, contains('Đà Nẵng'));
    expect(first.price, equals(5890000));
    expect(first.duration, equals('4 Ngày 3 Đêm'));
    expect(first.destination, equals('Đà Nẵng'));
    expect(first.imageUrl, isNotEmpty);
  });
}

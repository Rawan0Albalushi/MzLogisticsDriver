import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/json_readers.dart';
import '../../../shared/models/trip.dart';

final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  return TripsRepository(ref.watch(apiClientProvider));
});

class TripsRepository {
  TripsRepository(this._client);

  final ApiClient _client;

  Future<List<Trip>> list({String? status}) async {
    final envelope = await _client.get<List<Trip>>(
      ApiEndpoints.trips,
      query: {
        'per_page': 50,
        'status': ?status,
      },
      parse: (raw) => readMapList(raw).map(Trip.fromJson).toList(),
    );
    return envelope.data;
  }

  Future<Trip> show(int id) async {
    final envelope = await _client.get<Trip>(
      ApiEndpoints.trip(id),
      parse: (raw) => Trip.fromJson(readMap(raw) ?? {}),
    );
    return envelope.data;
  }

  Future<DashboardSummary> dashboard() async {
    final envelope = await _client.get<DashboardSummary>(
      ApiEndpoints.dashboard,
      parse: (raw) => DashboardSummary.fromJson(readMap(raw) ?? {}),
    );
    return envelope.data;
  }

  Future<Trip> updateStatus(int id, String status) async {
    final envelope = await _client.post<Trip>(
      ApiEndpoints.tripStatus(id),
      data: {'status': status},
      parse: (raw) => Trip.fromJson(readMap(raw) ?? {}),
    );
    return envelope.data;
  }

  Future<Trip> shareLocation({
    required int id,
    required double lat,
    required double lng,
    String? etaAt,
  }) async {
    final envelope = await _client.post<Trip>(
      ApiEndpoints.tripLocation(id),
      data: {
        'lat': lat,
        'lng': lng,
        'eta_at': ?etaAt,
      },
      parse: (raw) => Trip.fromJson(readMap(raw) ?? {}),
    );
    return envelope.data;
  }

  Future<void> submitPod({
    required int id,
    required String receiverName,
    required String otp,
    required double receivedQuantity,
    String? notes,
    double? lat,
    double? lng,
    required List<MultipartFile> photos,
  }) async {
    final form = FormData.fromMap({
      'receiver_name': receiverName,
      'otp': otp,
      'received_quantity': receivedQuantity,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'lat': ?lat,
      'lng': ?lng,
    });
    for (var index = 0; index < photos.length; index++) {
      form.files.add(MapEntry('photos[$index]', photos[index]));
    }
    await _client.post<void>(
      ApiEndpoints.tripPod(id),
      data: form,
      parse: (_) {},
    );
  }
}

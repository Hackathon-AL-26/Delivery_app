import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../../models/journey.dart';
import '../../../models/store.dart';
import '../../../models/truck.dart';
import 'journey_data_source.dart';

class JourneyApiDataSource implements JourneyDataSource {
  final String _baseUrl;
  final http.Client _client;
  final Duration _pollInterval;

  JourneyApiDataSource({
    String baseUrl = 'https://hackathon.enzomoy.fr',
    http.Client? client,
    Duration pollInterval = const Duration(seconds: 10),
  })  : _baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl,
        _client = client ?? http.Client(),
        _pollInterval = pollInterval;


  Future<Map<String, String>> _authHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final token = await user.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Stream<T> _poll<T>(Future<T> Function() fetcher) async* {
    yield await fetcher();
    yield* Stream.periodic(_pollInterval).asyncMap((_) => fetcher());
  }


  Future<Journey?> _fetchMyJourney() async {
    final headers = await _authHeaders();
    final response = await _client.get(_uri('/journeys/me'), headers: headers);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('GET /journeys/me failed: ${response.statusCode}');
    }
    final body = jsonDecode(response.body);
    if (body == null) return null;
    return Journey.fromJson(body as Map<String, dynamic>);
  }


  @override
  Future<Journey?> fetchMyJourney() => _fetchMyJourney();

  @override
  Stream<Journey?> watchMyJourney() => _poll(_fetchMyJourney);

  @override
  Future<void> updateJourneyStatus({
    required String journeyUuid,
    required String newStatus,
  }) async {
    final headers = await _authHeaders();
    final response = await _client.patch(
      _uri('/journeys/$journeyUuid'),
      headers: headers,
      body: jsonEncode({'status': newStatus}),
    );
    if (response.statusCode != 200) {
      throw Exception('PATCH /journeys/$journeyUuid failed: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateJourneyOrderStatus({
    required String journeyUuid,
    required String orderId,
    required String newStatus,
  }) async {
    final headers = await _authHeaders();
    final response = await _client.patch(
      _uri('/journey-orders/$journeyUuid/$orderId/status'),
      headers: headers,
      body: jsonEncode({'status': newStatus}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'PATCH /journey-orders/$journeyUuid/$orderId/status failed: ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> advanceNextStep({
    required Map<String, dynamic> body,
  }) async {
    final headers = await _authHeaders();
    final response = await _client.post(
      _uri('/journeys/me/next-step'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'POST /journeys/me/next-step failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  @override
  Future<void> updateTruckStatus({
    required String truckId,
    required String status,
  }) async {
    final headers = await _authHeaders();
    final response = await _client.patch(
      _uri('/trucks/$truckId/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'PATCH /trucks/$truckId/status failed: ${response.statusCode}',
      );
    }
  }

  @override
  Future<Truck> fetchTruck({required String truckId}) async {
    final headers = await _authHeaders();
    final response = await _client.get(
      _uri('/trucks/$truckId'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('GET /trucks/$truckId failed: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return Truck.fromJson(body);
  }

  @override
  Future<Store> fetchStore({required String storeUuid}) async {
    final headers = await _authHeaders();
    final response = await _client.get(
      _uri('/stores/$storeUuid'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('GET /stores/$storeUuid failed: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return Store.fromJson(body);
  }
}

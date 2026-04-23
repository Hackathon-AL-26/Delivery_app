import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../../models/journey.dart';
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
      _uri('/journeys/$journeyUuid/journey-orders/$orderId'),
      headers: headers,
      body: jsonEncode({'status': newStatus}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'PATCH /journeys/$journeyUuid/journey-orders/$orderId failed: ${response.statusCode}',
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/map_config.dart';
import '../models/enums/journey_order_status.dart';
import '../models/enums/journey_status.dart';
import '../models/journey.dart';
import '../models/journey_order.dart';
import '../models/store.dart';
import '../repository/journey_repository/journey_repository.dart';
import 'detail_delivery_order_screen.dart';

class JourneyDetailScreen extends StatefulWidget {
  final Journey journey;
  final JourneyRepository repository;

  const JourneyDetailScreen({
    super.key,
    required this.journey,
    required this.repository,
  });

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  /// Stores enrichis via GET /stores/{uuid}, indexés par storeUuid.
  final Map<String, Store> _stores = {};
  bool _loadingStores = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchAllStores();
  }

  Future<void> _fetchAllStores() async {
    final orders = widget.journey.journeyOrders;

    // Collecter les storeUuids uniques
    final uuids = <String>{};
    for (final jo in orders) {
      final uuid = jo.order?.storeUuid ?? jo.store?.uuid;
      if (uuid != null) uuids.add(uuid);
    }

    // Fetch en parallèle
    await Future.wait(uuids.map((uuid) async {
      try {
        final store = await widget.repository.fetchStore(storeUuid: uuid);
        _stores[uuid] = store;
      } catch (_) {
        // Fallback sur les données embarquées
      }
    }));

    if (!mounted) return;
    setState(() => _loadingStores = false);
  }

  /// Récupère le Store enrichi ou le fallback embarqué.
  Store? _storeFor(JourneyOrder jo) {
    final uuid = jo.order?.storeUuid ?? jo.store?.uuid;
    if (uuid != null && _stores.containsKey(uuid)) return _stores[uuid];
    return jo.store;
  }

  /// Collecte les LatLng de tous les stops dans l'ordre de livraison.
  List<LatLng> _buildRoutePoints() {
    final sorted = List<JourneyOrder>.from(widget.journey.journeyOrders)
      ..sort((a, b) => (a.deliveryOrder ?? 999).compareTo(b.deliveryOrder ?? 999));

    final points = <LatLng>[];
    for (final jo in sorted) {
      final store = _storeFor(jo);
      if (store?.lat != null && store?.lng != null) {
        points.add(LatLng(store!.lat!, store.lng!));
      }
    }
    return points;
  }

  /// Calcule le centre et le zoom pour englober tous les points.
  LatLngBounds? _buildBounds(List<LatLng> points) {
    if (points.isEmpty) return null;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final journey = widget.journey;
    final sortedOrders = List<JourneyOrder>.from(journey.journeyOrders)
      ..sort((a, b) => (a.deliveryOrder ?? 999).compareTo(b.deliveryOrder ?? 999));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la tournée')),
      body: _loadingStores
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16, 16, 16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              children: [
                _buildMap(context),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.pin_drop, size: 20, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Arrêts (${sortedOrders.length})',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(sortedOrders.length, (index) {
                  final jo = sortedOrders[index];
                  final store = _storeFor(jo);
                  final isDelivered =
                      jo.status == JourneyOrderStatus.delivered;

                  return _StopTile(
                    index: index,
                    total: sortedOrders.length,
                    storeName: store?.name ?? 'Stop ${index + 1}',
                    deliveryHours: store?.deliveryHours,
                    status: jo.status,
                    isDelivered: isDelivered,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailDeliveryOrderScreen(
                            journeyOrder: jo,
                            repository: widget.repository,
                          ),
                        ),
                      );
                    },
                  );
                }),

              ],
            ),
    );
  }

  Widget _buildMap(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final routePoints = _buildRoutePoints();

    if (routePoints.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('Aucune coordonnée disponible pour afficher la carte.'),
          ),
        ),
      );
    }

    final bounds = _buildBounds(routePoints);
    final sortedOrders = List<JourneyOrder>.from(widget.journey.journeyOrders)
      ..sort((a, b) => (a.deliveryOrder ?? 999).compareTo(b.deliveryOrder ?? 999));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.map_outlined, size: 20, color: colors.primary),
            const SizedBox(width: 8),
            Text(
              'Itinéraire',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 320,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCameraFit: bounds != null
                        ? CameraFit.bounds(
                            bounds: bounds,
                            padding: const EdgeInsets.all(40),
                          )
                        : null,
                    initialCenter: routePoints.first,
                    initialZoom: 13,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapConfig.mapboxStyleUrl,
                      userAgentPackageName: 'com.infflux.livreur',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4,
                          color: colors.primary,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: List.generate(routePoints.length, (i) {
                        final jo = sortedOrders[i];
                        final isDelivered =
                            jo.status == JourneyOrderStatus.delivered;
                        final markerColor =
                            isDelivered ? Colors.green : colors.primary;

                        return Marker(
                          point: routePoints[i],
                          width: 36,
                          height: 36,
                          child: Container(
                            decoration: BoxDecoration(
                              color: markerColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isDelivered
                                  ? const Icon(Icons.check,
                                      size: 18, color: Colors.white)
                                  : Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter_journey',
                    onPressed: () {
                      if (bounds != null) {
                        _mapController.fitCamera(
                          CameraFit.bounds(
                            bounds: bounds,
                            padding: const EdgeInsets.all(40),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _fmtDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = (dt.year % 100).toString().padLeft(2, '0');
    final t = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$d/$m/$y à $t';
  }

  String _deliveredSummary(Journey journey) {
    final delivered = journey.journeyOrders
        .where((jo) => jo.status == JourneyOrderStatus.delivered)
        .length;
    return '$delivered / ${journey.journeyOrders.length}';
  }
}

// ── Widgets privés ──

class _JourneyStatusBanner extends StatelessWidget {
  final JourneyStatus status;
  const _JourneyStatusBanner({required this.status});

  Color _color(ColorScheme c) {
    switch (status) {
      case JourneyStatus.planned:
        return c.primary;
      case JourneyStatus.loading:
        return c.tertiary;
      case JourneyStatus.inDelivery:
        return Colors.orange;
      case JourneyStatus.completed:
        return Colors.green;
    }
  }

  String get _label {
    switch (status) {
      case JourneyStatus.planned:
        return 'Planifiée';
      case JourneyStatus.loading:
        return 'Chargement';
      case JourneyStatus.inDelivery:
        return 'En livraison';
      case JourneyStatus.completed:
        return 'Terminée';
    }
  }

  IconData get _icon {
    switch (status) {
      case JourneyStatus.planned:
        return Icons.calendar_today;
      case JourneyStatus.loading:
        return Icons.download;
      case JourneyStatus.inDelivery:
        return Icons.local_shipping;
      case JourneyStatus.completed:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color(Theme.of(context).colorScheme);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            _label.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  final int index;
  final int total;
  final String storeName;
  final String? deliveryHours;
  final JourneyOrderStatus status;
  final bool isDelivered;
  final VoidCallback? onTap;

  const _StopTile({
    required this.index,
    required this.total,
    required this.storeName,
    this.deliveryHours,
    required this.status,
    required this.isDelivered,
    this.onTap,
  });

  Color _statusColor(ColorScheme c) {
    switch (status) {
      case JourneyOrderStatus.planned:
        return c.primary;
      case JourneyOrderStatus.loaded:
        return c.tertiary;
      case JourneyOrderStatus.inDelivery:
        return Colors.orange;
      case JourneyOrderStatus.delivered:
        return Colors.green;
    }
  }

  String get _statusLabel {
    switch (status) {
      case JourneyOrderStatus.planned:
        return 'Planifiée';
      case JourneyOrderStatus.loaded:
        return 'Chargée';
      case JourneyOrderStatus.inDelivery:
        return 'En livraison';
      case JourneyOrderStatus.delivered:
        return 'Livrée';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sc = _statusColor(colors);
    final isLast = index == total - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline verticale ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDelivered ? Colors.green : sc,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: isDelivered
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      color: colors.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── Contenu ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                storeName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (deliveryHours != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.schedule,
                                        size: 14,
                                        color: colors.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      deliveryHours!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color:
                                                  colors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: sc.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: sc,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right,
                            size: 20, color: colors.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/map_config.dart';
import '../models/enums/journey_order_status.dart';
import '../models/journey_order.dart';
import '../models/store.dart';
import '../repository/journey_repository/journey_repository.dart';

class DetailDeliveryOrderScreen extends StatefulWidget {
  final JourneyOrder journeyOrder;
  final JourneyRepository repository;

  const DetailDeliveryOrderScreen({
    super.key,
    required this.journeyOrder,
    required this.repository,
  });

  @override
  State<DetailDeliveryOrderScreen> createState() =>
      _DetailDeliveryOrderScreenState();
}

class _DetailDeliveryOrderScreenState extends State<DetailDeliveryOrderScreen> {
  Store? _store;
  bool _loading = true;
  String? _error;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchStoreDetails();
  }

  Future<void> _fetchStoreDetails() async {
    final storeUuid = widget.journeyOrder.order?.storeUuid ??
        widget.journeyOrder.store?.uuid;
    if (storeUuid == null) {
      if (!mounted) return;
      setState(() {
        _store = widget.journeyOrder.store;
        _loading = false;
      });
      return;
    }
    try {
      final store =
          await widget.repository.fetchStore(storeUuid: storeUuid);
      if (!mounted) return;
      setState(() {
        _store = store;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _store = widget.journeyOrder.store;
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final jo = widget.journeyOrder;
    final order = jo.order;

    return Scaffold(
      appBar: AppBar(
        title: Text(jo.store?.name ?? 'Détail commande'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16, 16, 16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              children: [
                if (_store?.lat != null && _store?.lng != null) ...[
                  _SectionTitle(
                      icon: Icons.map_outlined, label: 'Localisation'),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 280,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter:
                              LatLng(_store!.lat!, _store!.lng!),
                              initialZoom: 15,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.all &
                                ~InteractiveFlag.rotate,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: MapConfig.mapboxStyleUrl,
                                userAgentPackageName: 'com.infflux.livreur',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point:
                                    LatLng(_store!.lat!, _store!.lng!),
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.location_on,
                                      color: colors.error,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: FloatingActionButton.small(
                              heroTag: 'recenter_detail',
                              onPressed: () {
                                _mapController.move(
                                  LatLng(_store!.lat!, _store!.lng!),
                                  15,
                                );
                              },
                              child: const Icon(Icons.my_location),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                _SectionTitle(icon: Icons.storefront, label: 'Magasin'),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _store?.name ?? 'Magasin inconnu',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_store?.email != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.email_outlined,
                                  size: 16, color: colors.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _store!.email!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_store?.deliveryHours != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule,
                                  size: 16, color: colors.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                'Horaires : ${_store!.deliveryHours!}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_store?.lat != null && _store?.lng != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 16, color: colors.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                '${_store!.lat!.toStringAsFixed(4)}, ${_store!.lng!.toStringAsFixed(4)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (order != null) ...[
                  _SectionTitle(
                      icon: Icons.receipt_long, label: 'Commande'),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (order.packageAmount != null)
                            _InfoRow(
                              icon: Icons.inventory_2,
                              label: 'Colis',
                              value: '${order.packageAmount}',
                            ),
                          if (order.deliveryDate != null)
                            _InfoRow(
                              icon: Icons.calendar_month,
                              label: 'Date de livraison',
                              value: order.deliveryDate!,
                            ),
                          if (jo.deliveryOrder != null)
                            _InfoRow(
                              icon: Icons.format_list_numbered,
                              label: 'Ordre de passage',
                              value: '${jo.deliveryOrder}',
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StatusBanner(status: jo.status),

                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Note : données magasin partielles ($_error)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

// ── Widgets privés ──

class _StatusBanner extends StatelessWidget {
  final JourneyOrderStatus status;
  const _StatusBanner({required this.status});

  Color _color(ColorScheme c) {
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

  String get _label {
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

  IconData get _icon {
    switch (status) {
      case JourneyOrderStatus.planned:
        return Icons.schedule;
      case JourneyOrderStatus.loaded:
        return Icons.inventory;
      case JourneyOrderStatus.inDelivery:
        return Icons.local_shipping;
      case JourneyOrderStatus.delivered:
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
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

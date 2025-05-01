import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/order_tracking_model.dart';

class OrderTrackingScreenOSM extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreenOSM({Key? key, required this.orderId})
    : super(key: key);

  @override
  State<OrderTrackingScreenOSM> createState() => _OrderTrackingScreenOSMState();
}

class _OrderTrackingScreenOSMState extends State<OrderTrackingScreenOSM> {
  OrderTrackingModel? _trackingData;
  bool _isLoading = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadTrackingData();
  }

  Future<void> _loadTrackingData() async {
    // محاكاة تأخير الشبكة
    await Future.delayed(const Duration(seconds: 2));

    // في التطبيق الحقيقي، ستقوم بجلب البيانات من API
    // هنا نستخدم بيانات وهمية للتوضيح
    setState(() {
      _trackingData = OrderTrackingModel.getMockData(widget.orderId);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${localizations.translate('track_order')} #${widget.orderId}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // معلومات حالة الطلب
                  _buildOrderStatusCard(localizations),

                  // الخريطة
                  Expanded(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: LatLng(
                          _trackingData!.storeLocation.latitude,
                          _trackingData!.storeLocation.longitude,
                        ),
                        zoom: 13.0,
                        onMapReady: () {
                          _fitBounds();
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app_3mcode_shop',
                        ),
                        PolylineLayer(polylines: _buildPolylines()),
                        MarkerLayer(markers: _buildMarkers()),
                      ],
                    ),
                  ),

                  // معلومات الساعي (إذا كان الطلب قيد التوصيل)
                  if (_trackingData!.status == OrderStatus.inTransit &&
                      _trackingData!.courierName != null)
                    _buildCourierCard(localizations),
                ],
              ),
    );
  }

  Widget _buildOrderStatusCard(AppLocalizations localizations) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${localizations.translate('order_status')}: ${_trackingData!.getStatusText()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '${localizations.translate('estimated_delivery')}: ${_trackingData!.formatDateTime()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildStatusProgress(localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusProgress(AppLocalizations localizations) {
    return Row(
      children: [
        _buildStatusStep(0, localizations.translate('processing')),
        _buildStatusLine(0),
        _buildStatusStep(1, localizations.translate('packed')),
        _buildStatusLine(1),
        _buildStatusStep(2, localizations.translate('shipped')),
        _buildStatusLine(2),
        _buildStatusStep(3, localizations.translate('in_transit')),
        _buildStatusLine(3),
        _buildStatusStep(4, localizations.translate('delivered')),
      ],
    );
  }

  Widget _buildStatusStep(int step, String label) {
    bool isActive = _trackingData!.status.index >= step;
    bool isCurrent = _trackingData!.status.index == step;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : Colors.grey.shade300,
            border:
                isCurrent ? Border.all(color: Colors.green, width: 3) : null,
          ),
          child:
              isActive
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLine(int step) {
    bool isActive = _trackingData!.status.index > step;

    return Expanded(
      child: Container(
        height: 3,
        color: isActive ? Colors.green : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildCourierCard(AppLocalizations localizations) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.delivery_dining, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${localizations.translate('courier')}: ${_trackingData!.courierName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _trackingData!.courierPhone!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: AppColors.primary),
              onPressed: () {
                // تنفيذ الاتصال بالساعي
                // في التطبيق الحقيقي، استخدم url_launcher للاتصال
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.translate('calling_courier')),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // إضافة علامة للمتجر
    markers.add(
      Marker(
        point: LatLng(
          _trackingData!.storeLocation.latitude,
          _trackingData!.storeLocation.longitude,
        ),
        width: 80,
        height: 80,
        builder:
            (context) => Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.store, color: Colors.white, size: 30),
                ),
                const Text(
                  'المتجر',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
      ),
    );

    // إضافة علامة للعميل
    markers.add(
      Marker(
        point: LatLng(
          _trackingData!.customerLocation.latitude,
          _trackingData!.customerLocation.longitude,
        ),
        width: 80,
        height: 80,
        builder:
            (context) => Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.home, color: Colors.white, size: 30),
                ),
                const Text(
                  'موقع التسليم',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
      ),
    );

    // إضافة علامة للساعي (إذا كان متاح)
    if (_trackingData!.currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(
            _trackingData!.currentLocation!.latitude,
            _trackingData!.currentLocation!.longitude,
          ),
          width: 80,
          height: 80,
          builder:
              (context) => Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.delivery_dining,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const Text(
                    'الساعي',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
        ),
      );
    }

    return markers;
  }

  List<Polyline> _buildPolylines() {
    List<Polyline> polylines = [];

    if (_trackingData!.currentLocation != null) {
      // رسم المسار من المتجر إلى الساعي
      polylines.add(
        Polyline(
          points: [
            LatLng(
              _trackingData!.storeLocation.latitude,
              _trackingData!.storeLocation.longitude,
            ),
            LatLng(
              _trackingData!.currentLocation!.latitude,
              _trackingData!.currentLocation!.longitude,
            ),
          ],
          strokeWidth: 4.0,
          color: Colors.blue,
        ),
      );

      // رسم المسار من الساعي إلى العميل (خط متقطع)
      polylines.add(
        Polyline(
          points: [
            LatLng(
              _trackingData!.currentLocation!.latitude,
              _trackingData!.currentLocation!.longitude,
            ),
            LatLng(
              _trackingData!.customerLocation.latitude,
              _trackingData!.customerLocation.longitude,
            ),
          ],
          strokeWidth: 4.0,
          color: Colors.blue.withAlpha(128),
          isDotted: true,
        ),
      );
    } else {
      // رسم مسار مباشر من المتجر إلى العميل
      polylines.add(
        Polyline(
          points: [
            LatLng(
              _trackingData!.storeLocation.latitude,
              _trackingData!.storeLocation.longitude,
            ),
            LatLng(
              _trackingData!.customerLocation.latitude,
              _trackingData!.customerLocation.longitude,
            ),
          ],
          strokeWidth: 4.0,
          color: Colors.blue,
        ),
      );
    }

    return polylines;
  }

  void _fitBounds() {
    // جمع جميع النقاط التي نريد إظهارها في الخريطة
    List<LatLng> points = [
      LatLng(
        _trackingData!.storeLocation.latitude,
        _trackingData!.storeLocation.longitude,
      ),
      LatLng(
        _trackingData!.customerLocation.latitude,
        _trackingData!.customerLocation.longitude,
      ),
    ];

    if (_trackingData!.currentLocation != null) {
      points.add(
        LatLng(
          _trackingData!.currentLocation!.latitude,
          _trackingData!.currentLocation!.longitude,
        ),
      );
    }

    // حساب الحدود
    double minLat = points
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLat = points
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    double minLng = points
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLng = points
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    // إضافة هامش
    double padding = 0.01;

    // تحريك الكاميرا لتشمل جميع النقاط
    _mapController.fitBounds(
      LatLngBounds(
        LatLng(minLat - padding, minLng - padding),
        LatLng(maxLat + padding, maxLng + padding),
      ),
      options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
    );
  }
}

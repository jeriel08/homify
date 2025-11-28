import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class PropertyAddressWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final TextStyle? style;

  const PropertyAddressWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.style,
  });

  @override
  State<PropertyAddressWidget> createState() => _PropertyAddressWidgetState();
}

class _PropertyAddressWidgetState extends State<PropertyAddressWidget> {
  String? _address;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    if (!mounted) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.latitude,
        widget.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        // Construct a readable address
        // e.g., "Taft Ave, Manila" or "Street, City"
        final parts = <String>[];
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          parts.add(place.thoroughfare!);
        } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          parts.add(place.subLocality!);
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          parts.add(place.locality!);
        }

        setState(() {
          _address = parts.join(', ');
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _address = '${widget.latitude}, ${widget.longitude}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
      if (mounted) {
        setState(() {
          _address = '${widget.latitude}, ${widget.longitude}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Text(
        'Loading address...',
        style: widget.style?.copyWith(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text(
      _address ?? '${widget.latitude}, ${widget.longitude}',
      style: widget.style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

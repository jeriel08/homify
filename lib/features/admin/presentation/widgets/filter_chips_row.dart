import 'package:flutter/material.dart';
import 'package:homify/core/entities/property_entity.dart';

class FilterChipsRow extends StatelessWidget {
  final PropertyType? selectedType;
  final ValueChanged<PropertyType?> onSelected;

  const FilterChipsRow({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildChip(context, null, 'All'),
          const SizedBox(width: 8),
          ...PropertyType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(context, type, _formatType(type)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, PropertyType? type, String label) {
    final isSelected = selectedType == type;
    return FilterChip(
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF32190D),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(isSelected ? null : type),
      selectedColor: const Color(0xFF32190D),
      backgroundColor: const Color(0xFFF9E5C5),
      showCheckmark: false,
      side: BorderSide(
        color: isSelected ? const Color(0xFF32190D) : Colors.transparent,
        width: 2,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  String _formatType(PropertyType type) {
    return type.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }
}

import 'package:flutter/material.dart';
import '../models/table_model.dart';

class SectionFilter extends StatelessWidget {
  final TableSection? selectedSection;
  final Function(TableSection?) onSectionChanged;
  
  const SectionFilter({
    super.key,
    required this.selectedSection,
    required this.onSectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(context, null, 'All'),
          ...TableSection.values.map((section) => 
            _buildFilterChip(context, section, section.displayName)
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(BuildContext context, TableSection? section, String label) {
    final isSelected = section == selectedSection;
    
    // Choose a color based on section
    Color chipColor;
    if (section == null) {
      chipColor = Colors.blue;
    } else {
      switch (section) {
        case TableSection.MAIN:
          chipColor = Colors.green;
          break;
        case TableSection.OUTDOOR:
          chipColor = Colors.teal;
          break;
        case TableSection.PRIVATE:
          chipColor = Colors.purple;
          break;
        case TableSection.BAR:
          chipColor = Colors.amber;
          break;
        case TableSection.ROOFTOP:
          chipColor = Colors.red;
          break;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : chipColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        selectedColor: chipColor,
        backgroundColor: chipColor.withOpacity(0.1),
        side: BorderSide(color: chipColor.withOpacity(isSelected ? 0 : 0.5)),
        onSelected: (selected) {
          onSectionChanged(selected ? section : null);
        },
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
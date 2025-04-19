import 'package:flutter/material.dart';
import '../models/table_model.dart';

class StatusBadge extends StatelessWidget {
  final TableStatus status;
  final bool mini;
  
  const StatusBadge({
    super.key,
    required this.status,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mini ? 6 : 12,
        vertical: mini ? 2 : 6,
      ),
      decoration: BoxDecoration(
        color: _getColorForStatus(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getColorForStatus(status).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForStatus(status),
            size: mini ? 10 : 14,
            color: _getColorForStatus(status),
          ),
          SizedBox(width: mini ? 3 : 6),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: mini ? 10 : 12,
              fontWeight: FontWeight.bold,
              color: _getColorForStatus(status),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getColorForStatus(TableStatus status) {
    switch (status) {
      case TableStatus.VACANT:
        return Colors.green;
      case TableStatus.OCCUPIED:
        return Colors.red;
      case TableStatus.RESERVED:
        return Colors.orange;
      case TableStatus.MAINTENANCE:
        return Colors.purple;
      case TableStatus.CLEANING:
        return Colors.blue;
    }
  }
  
  IconData _getIconForStatus(TableStatus status) {
    switch (status) {
      case TableStatus.VACANT:
        return Icons.check_circle;
      case TableStatus.OCCUPIED:
        return Icons.people;
      case TableStatus.RESERVED:
        return Icons.bookmark;
      case TableStatus.MAINTENANCE:
        return Icons.build;
      case TableStatus.CLEANING:
        return Icons.cleaning_services;
    }
  }
}
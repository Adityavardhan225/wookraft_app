import 'package:flutter/material.dart';
import '../models/table_model.dart';
import 'status_badge.dart';

class TableCard extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;
  final bool compact;
  
  const TableCard({
    super.key,
    required this.table,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: _getTableShape(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _getColorForStatus(table.status),
              width: 2,
            ),
          ),
          child: compact ? _buildCompactTable() : _buildDetailedTable(),
        ),
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
  
  ShapeBorder _getTableShape() {
    switch (table.shape) {
      case TableShape.ROUND:
        return const CircleBorder();
      case TableShape.OVAL:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        );
      case TableShape.RECTANGULAR:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        );
      case TableShape.SQUARE:
      default:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        );
    }
  }
  
  Widget _buildCompactTable() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: _getColorForStatus(table.status).withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${table.tableNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${table.capacity} seats',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            StatusBadge(status: table.status, mini: true),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailedTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with table number and section
        Container(
          color: _getColorForStatus(table.status).withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getColorForStatus(table.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${table.tableNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _getColorForStatus(table.status),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                table.section.displayName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Table details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Capacity
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${table.capacity} seats',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // If occupied, show customer count
                if (table.status == TableStatus.OCCUPIED && table.customerCount != null)
                  Row(
                    children: [
                      Icon(Icons.group, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${table.customerCount} customers',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 12),
                
                // Status badge
                StatusBadge(status: table.status),
              ],
            ),
          ),
        ),
        
        // Footer with action hint
        Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Manage',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.blue[700],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
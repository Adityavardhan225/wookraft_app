import 'package:flutter/material.dart';
import '../models/table_model.dart';
import 'table_card.dart';

class TableGrid extends StatelessWidget {
  final List<TableModel> tables;
  final Function(TableModel) onTableTap;
  final bool usePositions;
  
  const TableGrid({
    super.key,
    required this.tables,
    required this.onTableTap,
    this.usePositions = false,
  });

  @override
  Widget build(BuildContext context) {
    if (usePositions) {
      return _buildPositionalLayout(context);
    } else {
      return _buildGridLayout(context);
    }
  }
  
  Widget _buildGridLayout(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120, // Much smaller maximum size
        childAspectRatio: 1.0, // Square aspect ratio
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return TableCard(
          table: table,
          onTap: () => onTableTap(table),
        );
      },
    );
  }
  
  Widget _buildPositionalLayout(BuildContext context) {
    // Get the maximum position values to determine the container size
    double maxX = 0;
    double maxY = 0;
    
    for (final table in tables) {
      if (table.positionX > maxX) maxX = table.positionX;
      if (table.positionY > maxY) maxY = table.positionY;
    }
    
    // Add padding to ensure tables at edges are fully visible
    maxX += 100;
    maxY += 100;
    
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: maxX,
          height: maxY,
          color: Colors.grey[100],
          child: Stack(
            children: tables.map((table) {
              return Positioned(
                left: table.positionX,
                top: table.positionY,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: TableCard(
                    table: table,
                    onTap: () => onTableTap(table),
                    compact: true,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
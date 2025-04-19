import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../../config.dart';

class AppConstants {
  // API endpoints
  static final String apiBaseUrl = Config.baseUrl;
  static final String wsBaseUrl = Config.wsUrl;
  
  // Status colors
  static const Map<TableStatus, Color> tableStatusColors = {
    TableStatus.VACANT: Colors.green,
    TableStatus.OCCUPIED: Colors.red,
    TableStatus.RESERVED: Colors.orange,
    TableStatus.MAINTENANCE: Colors.purple,
    TableStatus.CLEANING: Colors.blue,
  };
  
  // Status icons
  static const Map<TableStatus, IconData> tableStatusIcons = {
    TableStatus.VACANT: Icons.check_circle,
    TableStatus.OCCUPIED: Icons.people,
    TableStatus.RESERVED: Icons.bookmark,
    TableStatus.MAINTENANCE: Icons.build,
    TableStatus.CLEANING: Icons.cleaning_services,
  };
  
  // Section colors
  static const Map<TableSection, Color> sectionColors = {
    TableSection.MAIN: Colors.teal,
    TableSection.OUTDOOR: Colors.green,
    TableSection.PRIVATE: Colors.purple,
    TableSection.BAR: Colors.amber,
    TableSection.ROOFTOP: Colors.red,
  };
  
  // Table shape icons
  static const Map<TableShape, IconData> tableShapeIcons = {
    TableShape.SQUARE: Icons.crop_square,
    TableShape.ROUND: Icons.circle,
    TableShape.RECTANGULAR: Icons.crop_7_5,
    TableShape.OVAL: Icons.panorama_horizontal,
  };
  
  // App theme settings
  static final ThemeData appTheme = ThemeData(
    primarySwatch: Colors.teal,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.teal,
      elevation: 2,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration standardAnimationDuration = Duration(milliseconds: 350);
  
  // Refresh interval
  static const Duration autoRefreshInterval = Duration(minutes: 2);
}
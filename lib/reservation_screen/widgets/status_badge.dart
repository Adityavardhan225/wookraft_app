import 'package:flutter/material.dart';
import '../models/reservation_status.dart';

/// A widget that displays reservation status as a visually styled badge
class StatusBadge extends StatelessWidget {
  /// The reservation status to display
  final ReservationStatus status;

  /// Size can be 'small', 'medium', or 'large'
  final String size;

  /// Whether to display the status text
  final bool showText;
  
  /// Whether to outline the badge rather than fill it
  final bool outlined;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = 'medium',
    this.showText = true,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the icon size based on the specified size
    double iconSize;
    double fontSize;
    EdgeInsets padding;
    
    switch (size) {
      case 'small':
        iconSize = 12;
        fontSize = 10;
        padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
        break;
      case 'large':
        iconSize = 20;
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
      case 'medium':
      default:
        iconSize = 16;
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: outlined ? Colors.white : status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status.color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: iconSize,
            color: status.color,
          ),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              status.displayName,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: status.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
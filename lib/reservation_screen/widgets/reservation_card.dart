import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import './status_badge.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onTap;
  final VoidCallback? onCheckIn;
  final VoidCallback? onCancel;
  final bool showActions;
  final bool isCompact;
  
  const ReservationCard({
    super.key,
    required this.reservation,
    this.onTap,
    this.onCheckIn,
    this.onCancel,
    this.showActions = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('h:mm a');
    final dateFormatter = DateFormat('MMM d');
    
    final isToday = reservation.reservationDate.day == DateTime.now().day &&
                    reservation.reservationDate.month == DateTime.now().month &&
                    reservation.reservationDate.year == DateTime.now().year;
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: isCompact ? 4.0 : 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: reservation.status.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reservation.customerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isCompact ? 14 : 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(
                    status: reservation.status,
                    size: isCompact ? 'small' : 'medium',
                  ),
                ],
              ),
              if (!isCompact) const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeFormatter.format(reservation.reservationDate),
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: isCompact ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isToday 
                              ? 'Today' 
                              : dateFormatter.format(reservation.reservationDate),
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            fontSize: isCompact ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.group,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reservation.partySize} guests',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: isCompact ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (reservation.specialRequests != null &&
                  reservation.specialRequests!.isNotEmpty &&
                  !isCompact)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          reservation.specialRequests!,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (showActions && !isCompact) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onCheckIn != null)
                      TextButton.icon(
                        onPressed: onCheckIn,
                        icon: const Icon(Icons.login, size: 16),
                        label: const Text('CHECK IN'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    if (onCancel != null)
                      TextButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('CANCEL'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
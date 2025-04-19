import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../models/reservation_status.dart';
import './status_badge.dart';

class TimelineView extends StatefulWidget {
  final List<Reservation> reservations;
  final DateTime selectedDate;
  final Function(Reservation)? onReservationTap;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int timeSlotMinutes;

  const TimelineView({
    super.key,
    required this.reservations,
    required this.selectedDate,
    this.onReservationTap,
    this.startTime = const TimeOfDay(hour: 9, minute: 0),
    this.endTime = const TimeOfDay(hour: 23, minute: 0),
    this.timeSlotMinutes = 30,
  });

  @override
  _TimelineViewState createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final ScrollController _scrollController = ScrollController();
  final timeFormatter = DateFormat('h:mm a');
  late List<DateTime> _timeSlots;
  
  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
    
    // Scroll to current time after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void didUpdateWidget(TimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate || 
        oldWidget.startTime != widget.startTime ||
        oldWidget.endTime != widget.endTime ||
        oldWidget.timeSlotMinutes != widget.timeSlotMinutes) {
      _generateTimeSlots();
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateTimeSlots() {
    _timeSlots = [];
    
    // Convert TimeOfDay to DateTime for easier manipulation
    final startDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      widget.startTime.hour,
      widget.startTime.minute,
    );
    
    final endDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      widget.endTime.hour,
      widget.endTime.minute,
    );
    
    // If end time is earlier than start time, assume it's next day
    final Duration timeDiff = endDateTime.isAfter(startDateTime) 
        ? endDateTime.difference(startDateTime)
        : endDateTime.add(const Duration(days: 1)).difference(startDateTime);
    
    // Calculate number of slots
    final int slots = timeDiff.inMinutes ~/ widget.timeSlotMinutes;
    
    // Generate time slots
    for (int i = 0; i <= slots; i++) {
      _timeSlots.add(startDateTime.add(Duration(minutes: i * widget.timeSlotMinutes)));
    }
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    
    // Only scroll if today is selected
    if (widget.selectedDate.day == now.day &&
        widget.selectedDate.month == now.month &&
        widget.selectedDate.year == now.year) {
      
      // Find closest time slot
      int closestIndex = 0;
      int minDiff = 24 * 60; // Max diff in minutes
      
      for (int i = 0; i < _timeSlots.length; i++) {
        final slot = _timeSlots[i];
        final diff = (slot.hour * 60 + slot.minute) - (now.hour * 60 + now.minute);
        if (diff.abs() < minDiff) {
          minDiff = diff.abs();
          closestIndex = i;
        }
      }
      
      // Scroll to position
      if (closestIndex > 0 && _scrollController.hasClients) {
        final double position = (closestIndex * 80.0) - 100; // Adjust as needed based on your item height
        _scrollController.animateTo(
          position > 0 ? position : 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    }
  }

  List<Reservation> _getReservationsForTimeSlot(DateTime slotTime) {
    final slotDuration = Duration(minutes: widget.timeSlotMinutes);
    
    return widget.reservations.where((reservation) {
      // Skip completed, cancelled, or no-show reservations
      if (reservation.status == ReservationStatus.COMPLETED ||
          reservation.status == ReservationStatus.CANCELLED ||
          reservation.status == ReservationStatus.NO_SHOW) {
        return false;
      }
      
      final reservationStart = reservation.reservationDate;
      final reservationEnd = reservationStart.add(
        Duration(minutes: reservation.expectedDurationMinutes),
      );
      
      final slotEnd = slotTime.add(slotDuration);
      
      // Check if reservation overlaps with this time slot
      return (reservationStart.isBefore(slotEnd) && 
             reservationEnd.isAfter(slotTime));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600, // Fixed height or can be made responsive
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _timeSlots.length,
        itemBuilder: (context, index) {
          final timeSlot = _timeSlots[index];
          final reservations = _getReservationsForTimeSlot(timeSlot);
          
          return _buildTimeSlot(timeSlot, reservations);
        },
      ),
    );
  }

  Widget _buildTimeSlot(DateTime timeSlot, List<Reservation> reservations) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time indicator
          SizedBox(
            width: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeFormatter.format(timeSlot),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                if (_isCurrentTimeSlot(timeSlot))
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          
          // Vertical line
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 2,
            height: reservations.isEmpty ? 40 : null,
            color: _isCurrentTimeSlot(timeSlot) 
                ? Colors.red 
                : Colors.grey.shade300,
          ),
          
          // Reservations for this time slot
          if (reservations.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: reservations.map((reservation) => 
                  _buildReservationCard(reservation)
                ).toList(),
              ),
            )
          else
            Expanded(
              child: Container(
                height: 40,
              ),
            ),
        ],
      ),
    );
  }

  bool _isCurrentTimeSlot(DateTime timeSlot) {
    final now = DateTime.now();
    if (widget.selectedDate.day != now.day ||
        widget.selectedDate.month != now.month ||
        widget.selectedDate.year != now.year) {
      return false;
    }
    
    final nextSlot = timeSlot.add(Duration(minutes: widget.timeSlotMinutes));
    return now.isAfter(timeSlot) && now.isBefore(nextSlot);
  }

  Widget _buildReservationCard(Reservation reservation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: reservation.status.color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: reservation.status.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (widget.onReservationTap != null) {
            widget.onReservationTap!(reservation);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reservation.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: reservation.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    '${timeFormatter.format(reservation.reservationDate)} - ${timeFormatter.format(
                      reservation.reservationDate.add(Duration(minutes: reservation.expectedDurationMinutes))
                    )}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.group, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    '${reservation.partySize} guests',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              if (reservation.tableIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.table_bar, size: 14, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Tables: ${reservation.tableIds.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              if (reservation.specialRequests != null && 
                  reservation.specialRequests!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 14, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          reservation.specialRequests!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
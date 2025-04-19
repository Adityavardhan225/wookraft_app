import 'package:flutter/material.dart';

/// Represents the various states a reservation can be in
enum ReservationStatus {
  CONFIRMED,
  CHECKED_IN,
  COMPLETED,
  CANCELLED,
  NO_SHOW;

  /// User-friendly name of the status
  String get displayName {
    switch (this) {
      case ReservationStatus.CONFIRMED:
        return 'Confirmed';
      case ReservationStatus.CHECKED_IN:
        return 'Checked In';
      case ReservationStatus.COMPLETED:
        return 'Completed';
      case ReservationStatus.CANCELLED:
        return 'Cancelled';
      case ReservationStatus.NO_SHOW:
        return 'No Show';
    }
  }

  /// Color associated with this status
  Color get color {
    switch (this) {
      case ReservationStatus.CONFIRMED:
        return Colors.blue;
      case ReservationStatus.CHECKED_IN:
        return Colors.green;
      case ReservationStatus.COMPLETED:
        return Colors.purple;
      case ReservationStatus.CANCELLED:
        return Colors.red;
      case ReservationStatus.NO_SHOW:
        return Colors.orange;
    }
  }

  /// Icon associated with this status
  IconData get icon {
    switch (this) {
      case ReservationStatus.CONFIRMED:
        return Icons.event_available;
      case ReservationStatus.CHECKED_IN:
        return Icons.login;
      case ReservationStatus.COMPLETED:
        return Icons.task_alt;
      case ReservationStatus.CANCELLED:
        return Icons.cancel;
      case ReservationStatus.NO_SHOW:
        return Icons.person_off;
    }
  }

  /// Parse a string to convert to a ReservationStatus enum
  static ReservationStatus fromString(String status) {
    return ReservationStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ReservationStatus.CONFIRMED,
    );
  }
}





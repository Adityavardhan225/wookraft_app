import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../http_client.dart';
import '../models/reservation_model.dart';
import '../models/reservation_status.dart';
import '../services/reservation_service.dart';
import '../services/websocket_service.dart';
import '../widgets/status_badge.dart'; // Assuming you have this widget

class ReservationDetailScreen extends StatefulWidget {
  final String reservationId;
  
  const ReservationDetailScreen({
    super.key, 
    required this.reservationId,
  });

  @override
  _ReservationDetailScreenState createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> with SingleTickerProviderStateMixin {
  late ReservationService _reservationService;
  late ReservationWebSocketService _websocketService;
  late AnimationController _animationController;
  StreamSubscription? _websocketSubscription;
  
  bool _isLoading = true;
  bool _isProcessing = false;
  Reservation? _reservation;
  String? _errorMessage;
  String? _employeeId;
  final List<String> _selectedTableIds = [];
  
  // Key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Text controllers for notes or additional inputs
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _initializeServices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    _websocketSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize WebSocket service
      _websocketService = ReservationWebSocketService();
      await _websocketService.connect();
      
      // Create the reservation service using the websocket service
      _reservationService = ReservationService(_websocketService);
      
      // Get the current employee ID
      _employeeId = await HttpClient.getEmployeeId();

      // Load the reservation data
      await _loadReservation();
      
      // Listen for real-time updates
      _websocketSubscription = _websocketService.messageStream.listen((message) {
        _handleWebSocketMessage(message);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReservation() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final reservation = await _reservationService.getReservationById(widget.reservationId);
      
      if (mounted) {
        setState(() {
          _reservation = reservation;
          _isLoading = false;
          
          // Pre-select tables if any are assigned
          if (reservation.tableIds.isNotEmpty) {
            _selectedTableIds.clear();
            _selectedTableIds.addAll(reservation.tableIds);
          }
        });
      }
      
      _animationController.forward(from: 0.0);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load reservation: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    // Only process if we have a reservation loaded
    if (_reservation == null) return;
    
    switch (message['type']) {
      case 'reservation_updated':
      case 'reservation_checked_in':
      case 'reservation_cancelled':
      case 'reservation_completed':
      case 'reservation_no_show':
        final updatedData = message['data'];
        if (updatedData['id'] == _reservation?.id) {
          // This update is for our current reservation
          final updatedReservation = Reservation.fromJson(updatedData);
          
          if (mounted) {
            setState(() {
              _reservation = updatedReservation;
              
              // Update table selections if needed
              if (updatedReservation.tableIds.isNotEmpty) {
                _selectedTableIds.clear();
                _selectedTableIds.addAll(updatedReservation.tableIds);
              }
            });
          }
          
          // Show a snackbar notification
          final String action = message['type'].toString().split('_')[1].toUpperCase();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reservation was $action'),
              backgroundColor: Colors.blue,
            ),
          );
        }
        break;
    }
  }

  Future<void> _checkInReservation() async {
    if (_selectedTableIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one table'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_employeeId == null || _employeeId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee ID is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final updatedReservation = await _reservationService.checkInReservation(
        _reservation!.id,
        tableIds: _selectedTableIds,
        employeeId: _employeeId!,
      );
      
      setState(() {
        _reservation = updatedReservation;
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guest checked in successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Return true to indicate refresh needed
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to check in: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelReservation() async {
    // Show a dialog to confirm and collect reason
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _buildCancellationDialog(),
    );
    
    if (reason == null) {
      // User cancelled the dialog
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final updatedReservation = await _reservationService.cancelReservation(
        _reservation!.id,
        reason: reason.isNotEmpty ? reason : null,
      );
      
      setState(() {
        _reservation = updatedReservation;
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Return true to indicate refresh needed
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markNoShow() async {
    final bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as No-Show?'),
        content: const Text(
          'Are you sure you want to mark this reservation as a no-show? '
          'This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('MARK AS NO-SHOW'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!confirm) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final updatedReservation = await _reservationService.markNoShow(
        _reservation!.id,
      );
      
      setState(() {
        _reservation = updatedReservation;
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marked as no-show'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Return true to indicate refresh needed
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark as no-show: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Continuing from previous part...

  Future<void> _completeReservation() async {
    final bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Reservation?'),
        content: const Text(
          'Are you sure you want to mark this reservation as completed? '
          'This will release the assigned tables.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('COMPLETE'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!confirm) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final updatedReservation = await _reservationService.completeReservation(
        _reservation!.id,
      );
      
      setState(() {
        _reservation = updatedReservation;
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation completed'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Return true to indicate refresh needed
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete reservation: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendConfirmationEmail() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await _reservationService.sendConfirmationEmail(
        _reservation!.id,
      );
      
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Confirmation email sent successfully' 
                : 'Failed to send confirmation email'
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendReminderEmail() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await _reservationService.sendReminderEmail(
        _reservation!.id,
      );
      
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Reminder email sent successfully' 
                : 'Failed to send reminder email'
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Share reservation details (e.g. via a QR code or message)
  void _shareReservation() {
    // This would typically use a platform-specific sharing mechanism
    final String details = 
        'Reservation for ${_reservation!.customerName}\n'
        'Date: ${_reservation!.formattedDate}\n'
        'Time: ${_reservation!.formattedTime}\n'
        'Party Size: ${_reservation!.partySize} people\n'
        'Code: ${_reservation!.reservationCode}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing: $details')),
    );
    
    // You would implement platform sharing here
  }

  Widget _buildCancellationDialog() {
    final TextEditingController reasonController = TextEditingController();
    
    return AlertDialog(
      title: const Text('Cancel Reservation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Please provide a reason for cancellation:'),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Reason for cancellation (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('BACK'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(reasonController.text),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('CANCEL RESERVATION'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_reservation?.customerName ?? 'Reservation Details'),
        actions: [
          if (_reservation != null && !_isProcessing)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share Reservation',
              onPressed: _shareReservation,
            ),
          if (_reservation != null && !_isProcessing)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: _loadReservation,
            ),
        ],
      ),
      body: _isLoading 
          ? _buildLoadingView() 
          : _errorMessage != null 
              ? _buildErrorView() 
              : _buildReservationDetails(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading reservation details...'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadReservation,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetails() {
    if (_reservation == null) return const SizedBox.shrink();
    
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadReservation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildCustomerInfoCard(),
                  const SizedBox(height: 16),
                  _buildReservationDetailsCard(),
                  const SizedBox(height: 16),
                  if (_reservation!.status == ReservationStatus.CONFIRMED ||
                      _reservation!.status == ReservationStatus.CHECKED_IN)
                    _buildTableAssignmentCard(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final reservation = _reservation!;
    final status = reservation.status;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: status.color.withOpacity(0.5), 
          width: 2
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status.color.withOpacity(0.2),
              ),
              child: Icon(status.icon, color: status.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${status.displayName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Reservation Code: ${reservation.reservationCode}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    final reservation = _reservation!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Customer Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            ListTile(
              title: Text(reservation.customerName),
              subtitle: const Text('Name'),
              leading: const Icon(Icons.person_outline),
              dense: true,
              contentPadding: EdgeInsets.zero,
              trailing: IconButton(
                icon: const Icon(Icons.content_copy),
                tooltip: 'Copy Name',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: reservation.customerName));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name copied to clipboard')),
                  );
                },
              ),
            ),
            ListTile(
              title: Text(reservation.customerPhone),
              subtitle: const Text('Phone Number'),
              leading: const Icon(Icons.phone),
              dense: true,
              contentPadding: EdgeInsets.zero,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.content_copy),
                    tooltip: 'Copy Phone',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: reservation.customerPhone));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Phone copied to clipboard')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.call),
                    tooltip: 'Call Customer',
                    onPressed: () {
                      // Would implement phone call functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling customer...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (reservation.customerEmail != null && reservation.customerEmail!.isNotEmpty)
              ListTile(
                title: Text(reservation.customerEmail!),
                subtitle: const Text('Email'),
                leading: const Icon(Icons.email),
                dense: true,
                contentPadding: EdgeInsets.zero,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.content_copy),
                      tooltip: 'Copy Email',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: reservation.customerEmail!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email copied to clipboard')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.email_outlined),
                      tooltip: 'Email Customer',
                      onPressed: () {
                        // Would implement email functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening email...')),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationDetailsCard() {
    final reservation = _reservation!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Reservation Details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow(
              'Date', 
              reservation.formattedDate,
              Icons.calendar_today,
            ),
            _buildDetailRow(
              'Time', 
              reservation.formattedTime,
              Icons.access_time,
            ),
            _buildDetailRow(
              'Party Size', 
              '${reservation.partySize} people',
              Icons.group,
            ),
            _buildDetailRow(
              'Expected Duration', 
              reservation.durationText,
              Icons.timelapse,
            ),
            if (reservation.specialRequests != null && 
                reservation.specialRequests!.isNotEmpty)
              _buildDetailRow(
                'Special Requests', 
                reservation.specialRequests!,
                Icons.note,
                multiLine: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, 
      {bool multiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: multiLine 
            ? CrossAxisAlignment.start 
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                multiLine 
                    ? Text(value)
                    : Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableAssignmentCard() {
    final reservation = _reservation!;
    final tables = reservation.tables ?? [];
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.table_restaurant, color: Colors.brown),
                const SizedBox(width: 8),
                Text(
                  'Table Assignment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            if (tables.isEmpty && reservation.tableIds.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('No tables assigned yet'),
              )
            else if (tables.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  final table = tables[index];
                  return ListTile(
                    title: Text('Table ${table.tableNumber}'),
                    subtitle: Text('${table.section} - Capacity: ${table.capacity}'),
                    leading: const Icon(Icons.table_bar),
                    dense: true,
                  );
                },
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('${reservation.tableIds.length} tables assigned'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final reservation = _reservation!;
    
    // Different actions based on reservation status
    switch (reservation.status) {
      case ReservationStatus.CONFIRMED:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              'Check In',
              Icons.login,
              Colors.green,
              _checkInReservation,
            ),
            _buildActionButton(
              'Cancel',
              Icons.cancel,
              Colors.red,
              _cancelReservation,
            ),
            _buildActionButton(
              'No Show',
              Icons.person_off,
              Colors.orange,
              _markNoShow,
            ),
          ],
        );
        
      case ReservationStatus.CHECKED_IN:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              'Complete',
              Icons.task_alt,
              Colors.blue,
              _completeReservation,
            ),
            _buildActionButton(
              'Email',
              Icons.email,
              Colors.purple,
              _sendConfirmationEmail,
            ),
          ],
        );
        
      case ReservationStatus.CANCELLED:
      case ReservationStatus.NO_SHOW:
      case ReservationStatus.COMPLETED:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              'Reminder',
              Icons.email,
              Colors.blue,
              _sendReminderEmail,
            ),
          ],
        );
    }
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
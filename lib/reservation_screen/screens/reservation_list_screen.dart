import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../models/reservation_status.dart';
import '../services/reservation_service.dart';
import '../services/websocket_service.dart';
import './reservation_detail_screen.dart';
import './create_reservation_screen.dart';

class ReservationListScreen extends StatefulWidget {
  


  final DateTime initialDate;  // Add this parameter
  
  const ReservationListScreen({
    super.key,
    required this.initialDate,
  });

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  late ReservationService _reservationService;
  late ReservationWebSocketService _websocketService;
  
  DateTime _selectedDate = DateTime.now();
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? _errorMessage;
  ReservationStatus? _statusFilter;
  bool _includeCompleted = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _websocketService.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      _websocketService = ReservationWebSocketService();
      await _websocketService.connect();
      
      _reservationService = ReservationService(_websocketService);
      _loadReservations();

      // Listen for WebSocket updates
      _websocketService.messageStream.listen((message) {
        if (['reservation_created', 'reservation_updated', 
             'reservation_cancelled', 'reservation_checked_in',
             'reservation_completed', 'reservation_no_show'].contains(message['type'])) {
          // Refresh data when any reservation event occurs
          _loadReservations();
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReservations() async {
    if (_searchController.text.isNotEmpty) {
      return _searchReservations();
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reservations = await _reservationService.getReservationsByDate(
        _selectedDate, 
        includeCompleted: _includeCompleted
      );
      
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reservations: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchReservations() async {
    if (_searchController.text.isEmpty) {
      return _loadReservations();
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reservations = await _reservationService.searchReservations(_searchController.text);
      
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterReservations() {
    _loadReservations();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _searchController.clear(); // Clear search when date changes
      });
      _loadReservations();
    }
  }

  Future<void> _createNewReservation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReservationScreen(),
      ),
    );
    
    if (result == true) {
      _loadReservations();
    }
  }

  Future<void> _viewReservationDetails(Reservation reservation) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationDetailScreen(
          reservationId: reservation.id,
        ),
      ),
    );
    
    if (result == true) {
      _loadReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReservations,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, phone, or code',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _loadReservations();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        _loadReservations();
                      }
                    },
                    onSubmitted: (value) => _searchReservations(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildReservationsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewReservation,
        tooltip: 'Create New Reservation',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadReservations,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList() {
    // Filter reservations by status if filter is set
    final filteredReservations = _statusFilter != null
        ? _reservations.where((r) => r.status == _statusFilter).toList()
        : _reservations;

    if (filteredReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No reservations found'
                  : 'No reservations for this date',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try a different search term'
                  : 'Create a new reservation or select a different date',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: () => _selectDate(context),
              ),
              Text(
                '${filteredReservations.length} reservation(s)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredReservations.length,
            itemBuilder: (context, index) {
              final reservation = filteredReservations[index];
              return _buildReservationCard(reservation);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final Color statusColor = reservation.status.color;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () => _viewReservationDetails(reservation),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    reservation.formattedTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Chip(
                    label: Text(
                      reservation.status.displayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: statusColor,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reservation.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        reservation.customerPhone,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Party of ${reservation.partySize}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        reservation.durationText,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  if (reservation.tableIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.table_bar, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Tables: ${reservation.tableIds.join(", ")}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                  if (reservation.specialRequests != null &&
                      reservation.specialRequests!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reservation.specialRequests!,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Divider(height: 0),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: _buildActionButtons(reservation),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(Reservation reservation) {
    final List<Widget> buttons = [];

    switch (reservation.status) {
      case ReservationStatus.CONFIRMED:
        buttons.add(
          TextButton.icon(
            icon: const Icon(Icons.login, size: 16),
            label: const Text('Check In'),
            onPressed: () => _showCheckInBottomSheet(reservation),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),
        );
        buttons.add(
          TextButton.icon(
            icon: const Icon(Icons.cancel, size: 16),
            label: const Text('Cancel'),
            onPressed: () => _confirmCancelReservation(reservation),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        );
        break;
      case ReservationStatus.CHECKED_IN:
        buttons.add(
          TextButton.icon(
            icon: const Icon(Icons.done_all, size: 16),
            label: const Text('Complete'),
            onPressed: () => _confirmCompleteReservation(reservation),
            style: TextButton.styleFrom(
              foregroundColor: Colors.purple,
            ),
          ),
        );
        break;
      case ReservationStatus.CANCELLED:
      case ReservationStatus.COMPLETED:
      case ReservationStatus.NO_SHOW:
        // No actions for these statuses
        break;
    }
    
    // Add View Details button for all statuses
    buttons.add(
      TextButton.icon(
        icon: const Icon(Icons.visibility, size: 16),
        label: const Text('Details'),
        onPressed: () => _viewReservationDetails(reservation),
      ),
    );

    return buttons;
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Reservations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Include Completed:'),
                      const Spacer(),
                      Switch(
                        value: _includeCompleted,
                        onChanged: (value) {
                          setSheetState(() {
                            _includeCompleted = value;
                          });
                          setState(() {
                            _includeCompleted = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Status:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _statusFilter == null,
                        onSelected: (selected) {
                          setSheetState(() {
                            _statusFilter = selected ? null : _statusFilter;
                          });
                          setState(() {
                            _statusFilter = selected ? null : _statusFilter;
                          });
                        },
                      ),
                      ...ReservationStatus.values.map(
                        (status) => FilterChip(
                          label: Text(status.displayName),
                          selected: _statusFilter == status,
                          selectedColor: status.color.withOpacity(0.2),
                          onSelected: (selected) {
                            setSheetState(() {
                              _statusFilter = selected ? status : null;
                            });
                            setState(() {
                              _statusFilter = selected ? status : null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _filterReservations();
                        },
                        child: const Text('Apply Filters'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCheckInBottomSheet(Reservation reservation) async {
    final TextEditingController employeeIdController = TextEditingController();
    final List<String> selectedTableIds = [];

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(16.0).copyWith(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Check In Reservation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: employeeIdController,
                    decoration: const InputDecoration(
                      labelText: 'Employee ID',
                      hintText: 'Enter your employee ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Assign Tables',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Simplified table selection - in a real app, you would fetch actual tables
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      10,
                      (index) {
                        final tableId = (index + 1).toString();
                        final isSelected = selectedTableIds.contains(tableId);
                        
                        return FilterChip(
                          label: Text('Table $tableId'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setSheetState(() {
                              if (selected) {
                                selectedTableIds.add(tableId);
                              } else {
                                selectedTableIds.remove(tableId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (employeeIdController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Employee ID is required'),
                              ),
                            );
                            return;
                          }
                          if (selectedTableIds.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select at least one table'),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context, true);
                        },
                        child: const Text('Check In'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == true) {
      try {
        await _reservationService.checkInReservation(
          reservation.id,
          tableIds: selectedTableIds,
          employeeId: employeeIdController.text,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation checked in successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadReservations();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check in: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmCancelReservation(Reservation reservation) async {
    final TextEditingController reasonController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this reservation?'),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Cancellation',
                hintText: 'Optional',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _reservationService.cancelReservation(
          reservation.id,
          reason: reasonController.text.isNotEmpty ? reasonController.text : null,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation cancelled successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        
        _loadReservations();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmCompleteReservation(Reservation reservation) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Reservation'),
        content: const Text('Mark this reservation as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _reservationService.completeReservation(reservation.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadReservations();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
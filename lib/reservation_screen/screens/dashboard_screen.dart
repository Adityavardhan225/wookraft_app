import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../models/reservation_status.dart';
import '../services/reservation_service.dart';
import '../services/websocket_service.dart';
import './reservation_list_screen.dart';
import './create_reservation_screen.dart';
import './reservation_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ReservationWebSocketService _websocketService;
  late ReservationService _reservationService;
  StreamSubscription? _websocketSubscription;
  final DateTime _selectedDate = DateTime.now();
  
  List<Reservation> _upcomingReservations = [];
  List<Reservation> _todayReservations = [];
  ReservationStats? _stats;
  
  bool _isLoading = true;
  String? _errorMessage;
  
  // Counters for today's reservations by status
  int _confirmedCount = 0;
  int _checkedInCount = 0;
  int _completedCount = 0;
  int _cancelledCount = 0;
  int _noShowCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _websocketSubscription?.cancel();
    _websocketService.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize WebSocket service
      _websocketService = ReservationWebSocketService();
      await _websocketService.connect();
      
      // Create the reservation service using the websocket service
      _reservationService = ReservationService(_websocketService);
      
      // Load data
      await _refreshDashboard();
      
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

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'reservation_created':
      case 'reservation_updated':
      case 'reservation_checked_in':
      case 'reservation_cancelled':
      case 'reservation_completed':
      case 'reservation_no_show':
        // Refresh data when any reservation changes
        _refreshDashboard();
        
        // Show a snackbar notification
        final reservationData = message['data'];
        final String action = message['type'].toString().split('_')[1].toUpperCase();
        final String customerName = reservationData['customer_name'] ?? 'Unknown';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reservation for $customerName was $action'),
            action: SnackBarAction(
              label: 'VIEW',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationDetailScreen(
                      reservationId: reservationData['id'],
                    ),
                  ),
                );
              },
            ),
          ),
        );
        break;
    }
  }

Future<void> _refreshDashboard() async {
  if (mounted) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  try {
    // Load upcoming reservations (next 24 hours)
    final upcomingReservations = await _reservationService.getUpcomingReservations(24);
    
    // Load today's reservations
    final todayReservations = await _reservationService.getReservationsByDate(
      DateTime.now(),
      includeCompleted: true,
    );
    
    // Get stats for the current week - SAFELY WITH ERROR HANDLING
    ReservationStats stats;
    try {
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: now.weekday - 1),
      );
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      stats = await _reservationService.getReservationStats(startOfWeek, endOfWeek);
    } catch (statsError) {
      debugPrint('Error loading stats: $statsError');
      stats = ReservationStats.empty(); // Use empty stats on error
    }
    
    // Calculate counts by status
    int confirmedCount = 0;
    int checkedInCount = 0;
    int completedCount = 0;
    int cancelledCount = 0;
    int noShowCount = 0;
    
    for (var reservation in todayReservations) {
      switch (reservation.status) {
        case ReservationStatus.CONFIRMED:
          confirmedCount++;
          break;
        case ReservationStatus.CHECKED_IN:
          checkedInCount++;
          break;
        case ReservationStatus.COMPLETED:
          completedCount++;
          break;
        case ReservationStatus.CANCELLED:
          cancelledCount++;
          break;
        case ReservationStatus.NO_SHOW:
          noShowCount++;
          break;
      }
    }
    
    if (mounted) {
      setState(() {
        _upcomingReservations = upcomingReservations;
        _todayReservations = todayReservations;
        _stats = stats; // Use the safe version with error handling
        _confirmedCount = confirmedCount;
        _checkedInCount = checkedInCount;
        _completedCount = completedCount;
        _cancelledCount = cancelledCount;
        _noShowCount = noShowCount;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _errorMessage = 'Failed to load dashboard: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}

  void _viewAllReservations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationListScreen(initialDate: _selectedDate),
      ),
    ).then((result) {
      if (result == true) {
        _refreshDashboard();
      }
    });
  }

  void _createNewReservation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateReservationScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _refreshDashboard();
      }
    });
  }

  void _viewReservationDetails(Reservation reservation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationDetailScreen(
          reservationId: reservation.id,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _refreshDashboard();
      }
    });
  }

  Widget _buildStatusCounter(String label, int count, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Filter by status could be implemented here
          _viewAllReservations();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshDashboard,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'View Calendar',
            onPressed: _viewAllReservations,
          ),
        ],
      ),
      body: _isLoading 
          ? _buildLoadingView() 
          : _errorMessage != null 
              ? _buildErrorView() 
              : _buildDashboard(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewReservation,
        icon: const Icon(Icons.add),
        label: const Text('NEW RESERVATION'),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading dashboard...'),
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
            onPressed: _refreshDashboard,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's summary stats
            _buildSectionTitle('Today\'s Reservations'),
            Row(
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: ${_todayReservations.length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status counters
            GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatusCounter(
                  'Confirmed',
                  _confirmedCount,
                  Colors.blue,
                  Icons.event_available,
                ),
                _buildStatusCounter(
                  'Checked In',
                  _checkedInCount,
                  Colors.green,
                  Icons.login,
                ),
                _buildStatusCounter(
                  'Completed',
                  _completedCount,
                  Colors.purple,
                  Icons.task_alt,
                ),
                _buildStatusCounter(
                  'Cancelled',
                  _cancelledCount,
                  Colors.red,
                  Icons.cancel,
                ),
                _buildStatusCounter(
                  'No Show',
                  _noShowCount,
                  Colors.orange,
                  Icons.person_off,
                ),
                _buildStatusCounter(
                  'Total',
                  _todayReservations.length,
                  Colors.grey[700]!,
                  Icons.summarize,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            _buildSectionTitle('Quick Actions'),
            GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildQuickAction(
                  'New Reservation',
                  Icons.add_circle,
                  _createNewReservation,
                ),
                _buildQuickAction(
                  'View All',
                  Icons.calendar_month,
                  _viewAllReservations,
                ),
                _buildQuickAction(
                  'Search',
                  Icons.search,
                  () {
                    // Search functionality would go here
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Upcoming reservations
            _buildSectionTitle('Upcoming Reservations'),
            if (_upcomingReservations.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text('No upcoming reservations'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _upcomingReservations.length > 5 
                    ? 5 
                    : _upcomingReservations.length,
                itemBuilder: (context, index) {
                  final reservation = _upcomingReservations[index];
                  return _buildReservationCard(reservation);
                },
              ),

            if (_upcomingReservations.length > 5)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: TextButton(
                    onPressed: _viewAllReservations,
                    child: Text(
                      'VIEW ALL ${_upcomingReservations.length} RESERVATIONS',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Some space at the bottom for the FloatingActionButton
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final timeFormatter = DateFormat('h:mm a');
    final isToday = reservation.reservationDate.day == DateTime.now().day &&
                    reservation.reservationDate.month == DateTime.now().month &&
                    reservation.reservationDate.year == DateTime.now().year;
                    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: reservation.status.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _viewReservationDetails(reservation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: reservation.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: reservation.status.color,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          reservation.status.icon,
                          size: 14,
                          color: reservation.status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reservation.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: reservation.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
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
                              : DateFormat('MMM d').format(reservation.reservationDate),
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (reservation.specialRequests != null &&
                  reservation.specialRequests!.isNotEmpty)
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(thickness: 1),
        ],
      ),
    );
  }
}
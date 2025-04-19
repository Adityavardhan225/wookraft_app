import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import '../services/websocket_service.dart';
import '../../table_screen/screens/table_selection_screen.dart'; // You may need to adjust this path
import '../../table_screen/models/table_model.dart'; // Import the TableModel class

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  _CreateReservationScreenState createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  late ReservationService _reservationService;
  late ReservationWebSocketService _websocketService;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _partySizeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _specialRequestsController = TextEditingController();
  final TextEditingController _tablePreferenceController = TextEditingController();


  List<TableModel> _selectedTables = [];
List<String> _selectedTableIds = [];
String _tableDisplayText = '';

  // Reservation data
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final int _partySize = 2;
  final int _durationMinutes = 90;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    
    // Set default values
    _partySizeController.text = _partySize.toString();
    _durationController.text = _durationMinutes.toString();
    // _updateDateTimeControllers();
     _dateController.text = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
  }
    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Now it's safe to use context
    _timeController.text = _selectedTime.format(context);
  }
  
  void _updateDateTimeControllers() {
    // Format date for display
    _dateController.text = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
    
    // Only format time if context is available
    if (mounted) {
      _timeController.text = _selectedTime.format(context);
    }
  }


  // Add this method to the _CreateReservationScreenState class
Future<void> _selectTables(BuildContext context) async {
  // Get the reservation date and time for availability checking
  final DateTime reservationDateTime = _getReservationDateTime();
  
  // Get party size for appropriate table selection
  final int partySize = int.tryParse(_partySizeController.text) ?? 2;
  
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TableSelectionScreen(
        selectedDate: reservationDateTime,
        partySize: partySize,
        initialSelectedTableIds: _selectedTableIds,
        selectionMode: true, // This tells the screen to only allow selection
      ),
    ),
  );
  
  if (result != null && result is List<TableModel>) {
    setState(() {
      _selectedTables = result;
      _selectedTableIds = _selectedTables.map((table) => table.id).toList();
      
      // Update display text
      if (_selectedTables.isEmpty) {
        _tableDisplayText = '';
      } else {
        final tableNumbers = _selectedTables
            .map((table) => 'Table ${table.tableNumber}')
            .join(', ');
        _tableDisplayText = tableNumbers;
        
        // Also update the text field value for backward compatibility
        _tablePreferenceController.text = _tableDisplayText;
      }
    });
  }
}


  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _partySizeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _specialRequestsController.dispose();
    _tablePreferenceController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize WebSocket service
      _websocketService = ReservationWebSocketService();
      await _websocketService.connect();
      
      // Create the reservation service using the websocket service
      _reservationService = ReservationService(_websocketService);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: ${e.toString()}';
      });
    }
  }

  // void _updateDateTimeControllers() {
  //   // Format date for display
  //   _dateController.text = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
    
  //   // Format time for display
  //   _timeController.text = _selectedTime.format(context);
  // }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Reservation Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateDateTimeControllers();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Select Reservation Time',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              dayPeriodTextColor: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _updateDateTimeControllers();
      });
    }
  }

  DateTime _getReservationDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  Future<void> _createReservation() async {
    if (!_formKey.currentState!.validate()) {
      // Form validation failed
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parse values to appropriate types
      final int partySize = int.parse(_partySizeController.text);
      final int durationMinutes = int.parse(_durationController.text);
      
      // Create reservation data object
      final reservationData = ReservationCreate(
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        customerEmail: _emailController.text.isNotEmpty ? _emailController.text : null,
        partySize: partySize,
        reservationDate: _getReservationDateTime(),
        expectedDurationMinutes: durationMinutes,
        specialRequests: _specialRequestsController.text.isNotEmpty 
            ? _specialRequestsController.text : null,
        tablePreference: _tablePreferenceController.text.isNotEmpty
            ? _tablePreferenceController.text : null,
      );
      
      // Submit to API
      final createdReservation = await _reservationService.createReservation(reservationData);
      
      setState(() {
        _isLoading = false;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Return to previous screen with refresh flag
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to create reservation: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Reservation'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'SAVE',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _isLoading ? null : _createReservation,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildForm(),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            
            _buildSectionTitle('Customer Information'),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                hintText: 'e.g., +1 555-123-4567',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                hintText: 'example@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Reservation Details'),
            
            InkWell(
              onTap: () => _selectDate(context),
              child: IgnorePointer(
                child: TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            InkWell(
              onTap: () => _selectTime(context),
              child: IgnorePointer(
                child: TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time *',
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a time';
                    }
                    return null;
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _partySizeController,
                    decoration: const InputDecoration(
                      labelText: 'Party Size *',
                      prefixIcon: Icon(Icons.group),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final partySize = int.tryParse(value);
                      if (partySize == null || partySize < 1) {
                        return 'Invalid size';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (mins)',
                      prefixIcon: Icon(Icons.timelapse),
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 90',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final duration = int.tryParse(value);
                      if (duration == null || duration < 15) {
                        return 'Min 15 mins';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Additional Information'),
            
            TextFormField(
              controller: _specialRequestsController,
              decoration: const InputDecoration(
                labelText: 'Special Requests (Optional)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
                hintText: 'e.g., High chair needed, Birthday celebration',
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // TextFormField(
            //   controller: _tablePreferenceController,
            //   decoration: const InputDecoration(
            //     labelText: 'Table Preference (Optional)',
            //     prefixIcon: Icon(Icons.table_bar),
            //     border: OutlineInputBorder(),
            //     hintText: 'e.g., Window seat, Outdoor patio',
            //   ),
            // ),


            InkWell(
  onTap: () => _selectTables(context),
  child: InputDecorator(
    decoration: InputDecoration(
      labelText: 'Select Tables',
      prefixIcon: Icon(Icons.table_bar),
      border: OutlineInputBorder(),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedTables.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedTables = [];
                  _selectedTableIds = [];
                  _tableDisplayText = '';
                  _tablePreferenceController.text = '';
                });
              },
              tooltip: 'Clear selection',
            ),
          Icon(Icons.arrow_drop_down),
        ],
      ),
    ),
    child: _tableDisplayText.isEmpty
        ? Text('Tap to select tables', style: TextStyle(color: Colors.grey))
        : Text(_tableDisplayText),
  ),
),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createReservation,
                icon: const Icon(Icons.save),
                label: const Text('CREATE RESERVATION'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
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
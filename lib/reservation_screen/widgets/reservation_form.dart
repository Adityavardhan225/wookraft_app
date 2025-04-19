import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';

class ReservationForm extends StatefulWidget {
  final Reservation? initialReservation; // For editing (null for new reservation)
  final Function(ReservationCreate) onSubmitCreate; // For creating new reservations
  final Function(String, ReservationUpdate)? onSubmitUpdate; // For updating existing
  final VoidCallback? onCancel;
  
  const ReservationForm({
    super.key, 
    this.initialReservation,
    required this.onSubmitCreate,
    this.onSubmitUpdate,
    this.onCancel,
  });

  @override
  _ReservationFormState createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _partySizeController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _durationController;
  late TextEditingController _specialRequestsController;
  late TextEditingController _tablePreferenceController;

  // Reservation data
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _partySize;
  late int _durationMinutes;
  
  bool get isEditMode => widget.initialReservation != null;

  @override
  void initState() {
    super.initState();
    
    if (isEditMode) {
      // Editing existing reservation
      final reservation = widget.initialReservation!;
      
      _selectedDate = reservation.reservationDate;
      _selectedTime = TimeOfDay(
        hour: reservation.reservationDate.hour,
        minute: reservation.reservationDate.minute,
      );
      _partySize = reservation.partySize;
      _durationMinutes = reservation.expectedDurationMinutes;
      
      _nameController = TextEditingController(text: reservation.customerName);
      _phoneController = TextEditingController(text: reservation.customerPhone);
      _emailController = TextEditingController(text: reservation.customerEmail ?? '');
      _partySizeController = TextEditingController(text: reservation.partySize.toString());
      _durationController = TextEditingController(text: reservation.expectedDurationMinutes.toString());
      _specialRequestsController = TextEditingController(text: reservation.specialRequests ?? '');
      _tablePreferenceController = TextEditingController(text: ''); // No field for this in the model
    } else {
      // Creating new reservation
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _partySize = 2;
      _durationMinutes = 90;
      
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _emailController = TextEditingController();
      _partySizeController = TextEditingController(text: _partySize.toString());
      _durationController = TextEditingController(text: _durationMinutes.toString());
      _specialRequestsController = TextEditingController();
      _tablePreferenceController = TextEditingController();
    }
    
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    
    // Update display values
    _updateDateTimeControllers();
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

  void _updateDateTimeControllers() {
    // Format date for display
    _dateController.text = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
    
    // Format time for display
    _timeController.text = _selectedTime.format(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: isEditMode ? DateTime(2020) : DateTime.now(),
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      // Form validation failed
      return;
    }

    if (isEditMode) {
      // Create an update object with only changed values
      final originalReservation = widget.initialReservation!;
      final Map<String, dynamic> changes = {};
      
      if (_nameController.text != originalReservation.customerName) {
        changes['customerName'] = _nameController.text;
      }
      
      if (_phoneController.text != originalReservation.customerPhone) {
        changes['customerPhone'] = _phoneController.text;
      }
      
      if (_emailController.text != (originalReservation.customerEmail ?? '')) {
        changes['customerEmail'] = _emailController.text.isEmpty ? null : _emailController.text;
      }
      
      if (int.parse(_partySizeController.text) != originalReservation.partySize) {
        changes['partySize'] = int.parse(_partySizeController.text);
      }
      
      final newDateTime = _getReservationDateTime();
      if (newDateTime != originalReservation.reservationDate) {
        changes['reservationDate'] = newDateTime;
      }
      
      if (int.parse(_durationController.text) != originalReservation.expectedDurationMinutes) {
        changes['expectedDurationMinutes'] = int.parse(_durationController.text);
      }
      
      if (_specialRequestsController.text != (originalReservation.specialRequests ?? '')) {
        changes['specialRequests'] = _specialRequestsController.text.isEmpty ? null : _specialRequestsController.text;
      }
      
      // Only call update if there are changes
      if (changes.isNotEmpty && widget.onSubmitUpdate != null) {
        final update = ReservationUpdate(
          customerName: changes['customerName'],
          customerPhone: changes['customerPhone'],
          customerEmail: changes['customerEmail'],
          partySize: changes['partySize'],
          reservationDate: changes['reservationDate'],
          expectedDurationMinutes: changes['expectedDurationMinutes'],
          specialRequests: changes['specialRequests'],
        );
        
        widget.onSubmitUpdate!(originalReservation.id, update);
      }
    } else {
      // Create new reservation
      final reservationData = ReservationCreate(
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        customerEmail: _emailController.text.isEmpty ? null : _emailController.text,
        partySize: int.parse(_partySizeController.text),
        reservationDate: _getReservationDateTime(),
        expectedDurationMinutes: int.parse(_durationController.text),
        specialRequests: _specialRequestsController.text.isEmpty 
            ? null : _specialRequestsController.text,
        tablePreference: _tablePreferenceController.text.isEmpty
            ? null : _tablePreferenceController.text,
      );
      
      widget.onSubmitCreate(reservationData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            
            TextFormField(
              controller: _tablePreferenceController,
              decoration: const InputDecoration(
                labelText: 'Table Preference (Optional)',
                prefixIcon: Icon(Icons.table_bar),
                border: OutlineInputBorder(),
                hintText: 'e.g., Window seat, Outdoor patio',
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                if (widget.onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('CANCEL'),
                    ),
                  ),
                if (widget.onCancel != null)
                  const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(isEditMode ? 'UPDATE' : 'CREATE'),
                  ),
                ),
              ],
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
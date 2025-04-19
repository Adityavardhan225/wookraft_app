// import 'package:flutter/material.dart';
// import '../models/table_model.dart';
// import '../models/table_status_update.dart';
// import '../services/table_service.dart';
// import '../services/api_service.dart';
// import '../services/websocket_service.dart';

// class TableManagementScreen extends StatefulWidget {
//   final String tableId;
  
//   const TableManagementScreen({
//     Key? key, 
//     required this.tableId,
//   }) : super(key: key);

//   @override
//   _TableManagementScreenState createState() => _TableManagementScreenState();
// }

// class _TableManagementScreenState extends State<TableManagementScreen> {
//   late TableService _tableService;
//   late WebSocketService _websocketService;
  
//   bool _isLoading = true;
//   TableModel? _table;
//   String? _errorMessage;
//   bool _isSaving = false;
  
//   // Form controllers
//   final _employeeIdController = TextEditingController();
//   final _customerCountController = TextEditingController();
//   final _orderIdController = TextEditingController();
//   final _notesController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();
//   }

//   @override
//   void dispose() {
//     _employeeIdController.dispose();
//     _customerCountController.dispose();
//     _orderIdController.dispose();
//     _notesController.dispose();
//     _websocketService.dispose();
//     super.dispose();
//   }
  
//   Future<void> _initializeServices() async {
//     final apiService = ApiService();
//     _websocketService = WebSocketService();
    
//     try {
//       await _websocketService.connect();
      
//       _tableService = TableService(_websocketService);
//       await _loadTable();
      
//       // Listen for WebSocket updates for this specific table
//       _websocketService.messageStream.listen((message) {
//         if (message['type'] == 'table_status_updated') {
//           final updatedTable = TableModel.fromJson(message['data']);
//           if (updatedTable.id == widget.tableId) {
//             setState(() {
//               _table = updatedTable;
//               _populateFormFields();
//             });
//           }
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to initialize: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadTable() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       final table = await _tableService.getTableById(widget.tableId);
      
//       setState(() {
//         _table = table;
//         _isLoading = false;
//         _populateFormFields();
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load table: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }
  
//   void _populateFormFields() {
//     if (_table != null) {
//       _employeeIdController.text = _table!.employeeId ?? '';
//       _customerCountController.text = _table!.customerCount?.toString() ?? '';
//       _orderIdController.text = _table!.orderId ?? '';
//       _notesController.text = _table!.notes ?? '';
//     }
//   }

//   Future<void> _updateTableStatus(TableStatus newStatus) async {
//     // Validate fields based on the new status
//     if (newStatus == TableStatus.OCCUPIED) {
//       if (_employeeIdController.text.isEmpty) {
//         _showErrorSnackbar('Employee ID is required for occupied tables');
//         return;
//       }
//       if (_customerCountController.text.isEmpty) {
//         _showErrorSnackbar('Customer count is required for occupied tables');
//         return;
//       }
//     } else if (newStatus == TableStatus.RESERVED && _employeeIdController.text.isEmpty) {
//       _showErrorSnackbar('Employee ID is required for reserved tables');
//       return;
//     }

//     try {
//       setState(() {
//         _isSaving = true;
//       });

//       // Create status update based on the form fields
//       final statusUpdate = TableStatusUpdate(
//         status: newStatus,
//         employeeId: _employeeIdController.text.isEmpty ? null : _employeeIdController.text,
//         customerCount: _customerCountController.text.isEmpty
//             ? null
//             : int.tryParse(_customerCountController.text),
//         orderId: _orderIdController.text.isEmpty ? null : _orderIdController.text,
//         notes: _notesController.text.isEmpty ? null : _notesController.text,
//       );

//      _tableService.updateTableStatus(widget.tableId, statusUpdate);
      
//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Table status updated to ${newStatus.displayName}'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       setState(() {
//         _isSaving = false;
//       });
      
//       // Go back to previous screen after successful update
//       Navigator.pop(context);
//     } catch (e) {
//       setState(() {
//         _isSaving = false;
//       });
//       _showErrorSnackbar('Failed to update table status: ${e.toString()}');
//     }
//   }
  
//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: _table == null 
//             ? const Text('Table Management') 
//             : Text('Table ${_table!.tableNumber}'),
//       ),
//       body: _isLoading 
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//               ? _buildErrorView()
//               : _buildTableManagementForm(),
//     );
//   }

//   Widget _buildErrorView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
//           const SizedBox(height: 16),
//           const Text(
//             'Error',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32),
//             child: Text(
//               _errorMessage!,
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.grey),
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.refresh),
//             label: const Text('Retry'),
//             onPressed: _loadTable,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTableManagementForm() {
//     if (_table == null) return const SizedBox.shrink();
    
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Table info card
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Table number and status
//                   Row(
//                     children: [
//                       Text(
//                         'Table ${_table!.tableNumber}',
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Spacer(),
//                       _buildStatusBadge(_table!.status),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
                  
//                   // Table details in a grid
//                   Wrap(
//                     spacing: 16,
//                     runSpacing: 16,
//                     children: [
//                       _buildDetailItem('Capacity', '${_table!.capacity} people', Icons.people),
//                       _buildDetailItem('Section', _table!.section.displayName, Icons.category),
//                       _buildDetailItem('Shape', _table!.shape.displayName, Icons.square_foot),
//                     ],
//                   ),
                  
//                   // Table description if available
//                   if (_table!.description != null && _table!.description!.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 16),
//                       child: Text(
//                         _table!.description!,
//                         style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
          
//           const SizedBox(height: 24),
//           const Text(
//             'Update Table Status',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
          
//           // Status update form
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextFormField(
//                     controller: _employeeIdController,
//                     decoration: const InputDecoration(
//                       labelText: 'Employee ID',
//                       hintText: 'Enter employee ID',
//                       prefixIcon: Icon(Icons.badge),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _customerCountController,
//                     decoration: const InputDecoration(
//                       labelText: 'Customer Count',
//                       hintText: 'Number of customers',
//                       prefixIcon: Icon(Icons.people),
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _orderIdController,
//                     decoration: const InputDecoration(
//                       labelText: 'Order ID',
//                       hintText: 'Optional order ID',
//                       prefixIcon: Icon(Icons.receipt_long),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _notesController,
//                     decoration: const InputDecoration(
//                       labelText: 'Notes',
//                       hintText: 'Any additional information',
//                       prefixIcon: Icon(Icons.note),
//                     ),
//                     maxLines: 3,
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           const SizedBox(height: 24),
//           const Text(
//             'Select New Status',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
          
//           // Status action buttons
//           if (_isSaving)
//             const Center(child: CircularProgressIndicator())
//           else
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 _buildStatusButton(
//                   status: TableStatus.VACANT, 
//                   icon: Icons.check_circle_outline,
//                   color: Colors.green,
//                 ),
//                 _buildStatusButton(
//                   status: TableStatus.OCCUPIED,
//                   icon: Icons.people,
//                   color: Colors.red,
//                 ),
//                 _buildStatusButton(
//                   status: TableStatus.RESERVED,
//                   icon: Icons.bookmark,
//                   color: Colors.orange,
//                 ),
//                 _buildStatusButton(
//                   status: TableStatus.CLEANING,
//                   icon: Icons.cleaning_services,
//                   color: Colors.blue,
//                 ),
//                 _buildStatusButton(
//                   status: TableStatus.MAINTENANCE,
//                   icon: Icons.build,
//                   color: Colors.purple,
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildDetailItem(String label, String value, IconData icon) {
//     return Container(
//       width: 150,
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.grey[600]),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//                 Text(
//                   value,
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildStatusBadge(TableStatus status) {
//     Color color;
//     switch (status) {
//       case TableStatus.VACANT:
//         color = Colors.green;
//         break;
//       case TableStatus.OCCUPIED:
//         color = Colors.red;
//         break;
//       case TableStatus.RESERVED:
//         color = Colors.orange;
//         break;
//       case TableStatus.CLEANING:
//         color = Colors.blue;
//         break;
//       case TableStatus.MAINTENANCE:
//         color = Colors.purple;
//         break;
//     }
    
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color),
//       ),
//       child: Text(
//         status.displayName,
//         style: TextStyle(
//           color: color,
//           fontWeight: FontWeight.bold,
//           fontSize: 13,
//         ),
//       ),
//     );
//   }
  
//   Widget _buildStatusButton({
//     required TableStatus status,
//     required IconData icon,
//     required Color color,
//   }) {
//     final isCurrentStatus = _table?.status == status;
    
//     return ElevatedButton.icon(
//       icon: Icon(icon),
//       label: Text(status.displayName),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: isCurrentStatus ? color : color.withOpacity(0.1),
//         foregroundColor: isCurrentStatus ? Colors.white : color,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         side: BorderSide(color: color),
//       ),
//       onPressed: isCurrentStatus ? null : () => _updateTableStatus(status),
//     );
//   }
// }







































import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/table_status_update.dart';
import '../services/table_service.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../../http_client.dart';

class TableManagementScreen extends StatefulWidget {
  final String tableId;
  
  const TableManagementScreen({
    super.key, 
    required this.tableId,
  });

  @override
  _TableManagementScreenState createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> with SingleTickerProviderStateMixin {
  late TableService _tableService;
  late WebSocketService _websocketService;
  late AnimationController _animationController;
  
  bool _isLoading = true;
  TableModel? _table;
  String? _errorMessage;
  bool _isSaving = false;
  
  // Form controllers
  final _employeeIdController = TextEditingController();
  final _customerCountController = TextEditingController();
  final _orderIdController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _initializeServices();
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _customerCountController.dispose();
    _orderIdController.dispose();
    _notesController.dispose();
    _websocketService.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeServices() async {
    final apiService = ApiService();
    _websocketService = WebSocketService();
    
    try {
      await _websocketService.connect();
      
      _tableService = TableService(_websocketService);
      await _loadTable();
      
      // Listen for WebSocket updates for this specific table
      _websocketService.messageStream.listen((message) {
        if (message['type'] == 'table_status_updated') {
          final updatedTable = TableModel.fromJson(message['data']);
          if (updatedTable.id == widget.tableId) {
            setState(() {
              _table = updatedTable;
              _populateFormFields();
            });
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Future<void> _loadTable() async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //       _errorMessage = null;
  //     });

  //     final table = await _tableService.getTableById(widget.tableId);
      
  //     setState(() {
  //       _table = table;
  //       _isLoading = false;
  //       _populateFormFields();
  //     });
      
  //     _animationController.forward(from: 0.0);
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'Failed to load table: ${e.toString()}';
  //       _isLoading = false;
  //     });
  //   }
  // }



  // Update in _loadTable() method - around line 138
// Add after setting state with loaded table

Future<void> _loadTable() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final table = await _tableService.getTableById(widget.tableId);
    
    setState(() {
      _table = table;
      _isLoading = false;
      _populateFormFields();
    });
    
    _animationController.forward(from: 0.0);
    _prefillEmployeeId(); // Add this line here
  } catch (e) {
    setState(() {
      _errorMessage = 'Failed to load table: ${e.toString()}';
      _isLoading = false;
    });
  }
}


  
  void _populateFormFields() {
    if (_table != null) {
      _employeeIdController.text = _table!.employeeId ?? '';
      _customerCountController.text = _table!.customerCount?.toString() ?? '';
      _orderIdController.text = _table!.orderId ?? '';
      _notesController.text = _table!.notes ?? '';
    }
  }


  // Add after _populateFormFields() method

Future<void> _prefillEmployeeId() async {
  // Only prefill if the field is empty
  if (_employeeIdController.text.isEmpty) {
    try {
      // Get employee ID directly from HttpClient
      final employeeId = await HttpClient.getEmployeeId();
      if (employeeId != null && employeeId.isNotEmpty && mounted) {
        setState(() {
          _employeeIdController.text = employeeId;
        });
      }
    } catch (e) {
      print('Error pre-filling employee ID: $e');
    }
  }
}

  Future<void> _updateTableStatus(TableStatus newStatus) async {
    // Validate fields based on the new status
    if (newStatus == TableStatus.OCCUPIED) {
      if (_employeeIdController.text.isEmpty) {
        _showErrorSnackbar('Employee ID is required for occupied tables');
        return;
      }
      if (_customerCountController.text.isEmpty) {
        _showErrorSnackbar('Customer count is required for occupied tables');
        return;
      }
    } else if (newStatus == TableStatus.RESERVED && _employeeIdController.text.isEmpty) {
      _showErrorSnackbar('Employee ID is required for reserved tables');
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      // Create status update based on the form fields
      final statusUpdate = TableStatusUpdate(
        status: newStatus,
        employeeId: _employeeIdController.text.isEmpty ? null : _employeeIdController.text,
        customerCount: _customerCountController.text.isEmpty
            ? null
            : int.tryParse(_customerCountController.text),
        orderId: _orderIdController.text.isEmpty ? null : _orderIdController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

     _tableService.updateTableStatus(widget.tableId, statusUpdate);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Table status updated to ${newStatus.displayName}'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isSaving = false;
      });
      
      // Go back to previous screen after successful update
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorSnackbar('Failed to update table status: ${e.toString()}');
    }
  }
  
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _table == null 
            ? const Text('Table Management') 
            : Text('Table ${_table!.tableNumber}'),
        elevation: 0,
      ),
      body: _isLoading 
          ? _buildLoadingView()
          : _errorMessage != null
              ? _buildErrorView()
              : _buildTableManagementForm(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Loading table details...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _loadTable,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableManagementForm() {
    if (_table == null) return const SizedBox.shrink();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _animationController.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced table info card
                    _buildTableInfoCard(isWideScreen),
                    
                    const SizedBox(height: 24),
                    
                    // Form section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Update Table Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: isWideScreen
                                ? _buildWideFormLayout()
                                : _buildNarrowFormLayout(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Status selection section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Change Table Status',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Status buttons
                          if (_isSaving)
                            const Center(child: CircularProgressIndicator())
                          else
                            isWideScreen
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: _buildStatusButtons(),
                                  )
                                : Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: _buildStatusButtons(),
                                  ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }
  
  Widget _buildTableInfoCard(bool isWideScreen) {
    final Color statusColor = _getStatusColor(_table!.status);
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              statusColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header with table number and status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withOpacity(0.2),
                      border: Border.all(color: statusColor, width: 2),
                    ),
                    child: Text(
                      '${_table!.tableNumber}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Table',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_table!.tableNumber}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _table!.section.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildEnhancedStatusBadge(_table!.status),
                ],
              ),
            ),
            
            // Table details
            Padding(
              padding: const EdgeInsets.all(24),
              child: isWideScreen
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _buildTableDetailItems(),
                    )
                  : Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: _buildTableDetailItems(),
                    ),
            ),
            
            // Table description if available
            if (_table!.description != null && _table!.description!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _table!.description!,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTableDetailItems() {
    return [
      _buildDetailItem(
        'Capacity',
        '${_table!.capacity} people',
        Icons.people,
        Colors.blue,
      ),
      _buildDetailItem(
        'Section',
        _table!.section.displayName,
        Icons.category,
        Colors.purple,
      ),
      _buildDetailItem(
        'Shape',
        _table!.shape.displayName,
        Icons.square_foot,
        Colors.orange,
      ),
      if (_table!.customerCount != null && _table!.customerCount! > 0)
        _buildDetailItem(
          'Guests',
          '${_table!.customerCount}',
          Icons.person,
          Colors.green,
        ),
      if (_table!.employeeId != null && _table!.employeeId!.isNotEmpty)
        _buildDetailItem(
          'Employee',
          _table!.employeeId!,
          Icons.badge,
          Colors.indigo,
        ),
    ];
  }

  Widget _buildWideFormLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _employeeIdController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  hintText: 'Enter employee ID',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _customerCountController,
                decoration: const InputDecoration(
                  labelText: 'Customer Count',
                  hintText: 'Number of customers',
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _orderIdController,
                decoration: const InputDecoration(
                  labelText: 'Order ID',
                  hintText: 'Optional order ID',
                  prefixIcon: Icon(Icons.receipt_long),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Any additional information',
            prefixIcon: Icon(Icons.note),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildNarrowFormLayout() {
    return Column(
      children: [
        TextFormField(
          controller: _employeeIdController,
          decoration: const InputDecoration(
            labelText: 'Employee ID',
            hintText: 'Enter employee ID',
            prefixIcon: Icon(Icons.badge),
              helperText: 'Required for occupied tables',
  helperStyle: TextStyle(color: Color.fromARGB(255, 180, 44, 44), fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _customerCountController,
          decoration: const InputDecoration(
            labelText: 'Customer Count',
            hintText: 'Number of customers',
            prefixIcon: Icon(Icons.people),
              helperText: 'Required for occupied tables',
  helperStyle: TextStyle(color: Color.fromARGB(255, 141, 27, 27), fontSize: 12),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _orderIdController,
          decoration: const InputDecoration(
            labelText: 'Order ID',
            hintText: 'Optional order ID',
            prefixIcon: Icon(Icons.receipt_long),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Any additional information',
            prefixIcon: Icon(Icons.note),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
  
  List<Widget> _buildStatusButtons() {
    return [
      _buildEnhancedStatusButton(
        status: TableStatus.VACANT, 
        icon: Icons.check_circle_outline,
        color: Colors.green,
      ),
      _buildEnhancedStatusButton(
        status: TableStatus.OCCUPIED,
        icon: Icons.people,
        color: Colors.red,
      ),
      _buildEnhancedStatusButton(
        status: TableStatus.RESERVED,
        icon: Icons.bookmark,
        color: Colors.orange,
      ),
      _buildEnhancedStatusButton(
        status: TableStatus.CLEANING,
        icon: Icons.cleaning_services,
        color: Colors.blue,
      ),
      _buildEnhancedStatusButton(
        status: TableStatus.MAINTENANCE,
        icon: Icons.build,
        color: Colors.purple,
      ),
    ];
  }
  
  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEnhancedStatusBadge(TableStatus status) {
    final color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEnhancedStatusButton({
    required TableStatus status,
    required IconData icon,
    required Color color,
  }) {
    final isCurrentStatus = _table?.status == status;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 64,
            width: 64,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isCurrentStatus ? color : color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: isCurrentStatus ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: IconButton(
              icon: Icon(
                icon,
                color: isCurrentStatus ? Colors.white : color,
                size: 28,
              ),
              onPressed: isCurrentStatus ? null : () => _updateTableStatus(status),
            ),
          ),
          Text(
            status.displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isCurrentStatus ? color : Colors.grey[800],
              fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.VACANT:
        return Colors.green;
      case TableStatus.OCCUPIED:
        return Colors.red;
      case TableStatus.RESERVED:
        return Colors.orange;
      case TableStatus.CLEANING:
        return Colors.blue;
      case TableStatus.MAINTENANCE:
        return Colors.purple;
    }
  }
  
  IconData _getStatusIcon(TableStatus status) {
    switch (status) {
      case TableStatus.VACANT:
        return Icons.check_circle_outline;
      case TableStatus.OCCUPIED:
        return Icons.people;
      case TableStatus.RESERVED:
        return Icons.bookmark;
      case TableStatus.CLEANING:
        return Icons.cleaning_services;
      case TableStatus.MAINTENANCE:
        return Icons.build;
    }
  }
}
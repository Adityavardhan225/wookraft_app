import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:uuid/uuid.dart';
import '../../config.dart';
import '../../http_client.dart';

class WebSocketService {
  final String baseUrl;
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  final String clientId;
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  // Use Config.wsUrl by default
  WebSocketService({String? baseUrl}) 
      : baseUrl = baseUrl ?? Config.wsUrl,
        clientId = const Uuid().v4();

  



  // Replace the connect method with this improved version:

Future<void> connect() async {
  if (_isConnected) return;
  
  try {
    // Get token from existing HttpClient
    final token = await HttpClient.getToken();
    final employeeId = await HttpClient.getEmployeeId();
    
    // Ensure the base URL uses WebSocket protocol
    String wsUrl = baseUrl;
    if (wsUrl.startsWith('http://')) {
      wsUrl = wsUrl.replaceFirst('http://', 'ws://');
    } else if (wsUrl.startsWith('https://')) {
      wsUrl = wsUrl.replaceFirst('https://', 'wss://');
    } else if (!wsUrl.startsWith('ws://') && !wsUrl.startsWith('wss://')) {
      wsUrl = 'wss://$wsUrl';
    }
    
    // Format URL properly and avoid Uri.toString() conversion issues
    final urlString = '$wsUrl/tables/$employeeId';
    debugPrint('Connecting to WebSocket at: $urlString');

    // Create connection with headers for auth - using string URL to avoid # fragment
    _channel = IOWebSocketChannel.connect(
      urlString,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    
    // Reset reconnect attempts on successful connection
    _reconnectAttempts = 0;
    _isConnected = true;

    // Listen for messages
    _channel!.stream.listen(
      (dynamic message) {
        try {
          final data = json.decode(message as String);
          _messageController.add(data);
        } catch (e) {
          debugPrint('WebSocket message parsing error: $e');
        }
      },
      onDone: () {
        debugPrint('WebSocket connection closed');
        _isConnected = false;
        _cleanupConnection();
        _attemptReconnect();
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
        _isConnected = false;
        _channel?.sink.close(status.goingAway);
        _cleanupConnection();
        _attemptReconnect();
      },
    );

    // Start heartbeat ping timer
    _startPingTimer();
  } catch (e) {
    _isConnected = false;
    debugPrint('WebSocket connection error: $e');
    _attemptReconnect();
    throw Exception('Failed to connect to WebSocket: $e');
  }
}

  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnection attempts reached');
      return;
    }
    
    _reconnectTimer?.cancel();
    
    // Exponential backoff for reconnect
    final reconnectDelay = Duration(milliseconds: 1000 * (1 << _reconnectAttempts));
    debugPrint('Attempting to reconnect in ${reconnectDelay.inSeconds} seconds');
    
    _reconnectTimer = Timer(reconnectDelay, () {
      _reconnectAttempts++;
      connect().catchError((e) {
        debugPrint('Reconnection failed: $e');
      });
    });
  }

  // Send a message to the server
  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(json.encode(message));
      } catch (e) {
        debugPrint('Error sending WebSocket message: $e');
      }
    } else {
      debugPrint('Cannot send message: WebSocket not connected');
    }
  }

  // Request table status update
  void updateTableStatus(String tableId, Map<String, dynamic> statusData) {
    sendMessage({
      'type': 'update_table_status',
      'table_id': tableId,
      'status_data': statusData,
    });
  }

  // Request refresh of all data
  void requestRefresh() {
    sendMessage({
      'type': 'request_refresh',
    });
  }

  // Ping server to keep connection alive
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        sendMessage({'type': 'ping'});
      }
    });
  }

  // Cleanup resources
  void _cleanupConnection() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  // Disconnect from WebSocket
  void disconnect() {
    _reconnectTimer?.cancel();
    _cleanupConnection();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }

  // Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
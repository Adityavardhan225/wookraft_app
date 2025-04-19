

import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

class WebSocketService {
  final String url;
  final String token;
  WebSocketChannel? _channel;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 10;
  final int _baseReconnectInterval = 1000; // 1 second

  final _messageController = StreamController<String>();
  bool _isConnected = false; // Track connection state

  WebSocketService({required this.url, required this.token});

  Stream<String> get onMessage => _messageController.stream;

  void connect() {
    final fullUrl = '$url?token=$token'; // Append token to URL
    print(fullUrl);
    _channel = WebSocketChannel.connect(Uri.parse(fullUrl));

    _channel!.stream.listen(
      (message) {
        if (!_messageController.isClosed) {
          _messageController.add(message);
        }
      },
      onDone: () {
        print('WebSocket is closed now. Reconnecting...');
        _isConnected = false;
        _reconnect();
      },
      onError: (error) {
        print('WebSocket error: $error');
        _isConnected = false;
        _channel!.sink.close(status.goingAway);
        _reconnect();
      },
    );

    _isConnected = true; // Set connection state to true
  }

  void _reconnect() {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      final reconnectInterval = _baseReconnectInterval * (1 << _reconnectAttempts);
      Timer(Duration(milliseconds: reconnectInterval), () {
        _reconnectAttempts++;
        connect();
      });
    } else {
      print('Max reconnection attempts reached. Giving up.');
    }
  }

  void sendMessage(String message) {
    if (_isConnected && _channel != null && _channel!.closeCode == null) {
      _channel!.sink.add(message);
    } else {
      print('WebSocket is closed or not initialized.');
    }
  }

  void dispose() {
    _isConnected = false;
    _channel?.sink.close();
    _messageController.close();
  }

  // New Methods for Order Management and KDS Acknowledgment

  void updateOrder(String orderId, Map<String, dynamic> updates) {
    _sendMessage({
      'type': 'update_order',
      'order_id': orderId,
      'updates': updates,
    });
  }

  void requestItemCancellation(String orderId, String itemName, String reason) {
    _sendMessage({
      'type': 'cancel_item',
      'order_id': orderId,
      'item_name': itemName,
      'reason': reason,
    });
  }

  void addItemsToOrder(String orderId, List<Map<String, dynamic>> items) {
    _sendMessage({
      'type': 'add_items',
      'order_id': orderId,
      'items': items,
    });
  }

  void acknowledgeOrder(String orderId) {
    _sendMessage({
      'type': 'acknowledge_order',
      'order_id': orderId,
    });
  }

  void approveCancellation(String orderId, String itemName) {
    _sendMessage({
      'type': 'approve_cancellation',
      'order_id': orderId,
      'item_name': itemName,
    });
  }

  void rejectCancellation(String orderId, String itemName, String reason) {
    _sendMessage({
      'type': 'reject_cancellation',
      'order_id': orderId,
      'item_name': itemName,
      'reason': reason,
    });
  }

  void updateFilters(List<String> foodTypes, List<String> foodCategories) {
    _sendMessage({
      'type': 'filter',
      'food_types': foodTypes,
      'food_categories': foodCategories,
    });
  }

  void searchTableOrders(String tableNo) {
    _sendMessage({
      'type': 'search_table',
      'table_no': tableNo,
    });
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null && _channel!.closeCode == null) {
      try {
        print('Sending WebSocket message: $message'); // Debug log
        _channel!.sink.add(json.encode(message));
      } catch (e) {
        print('Error sending message: $e');
      }
    } else {
      print('WebSocket is closed or not initialized.');
    }
  }
}
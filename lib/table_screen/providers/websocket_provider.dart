import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class WebSocketProvider extends ChangeNotifier {
  final WebSocketService _webSocketService;
  bool _isConnected = false;
  String? _errorMessage;

  WebSocketProvider({required WebSocketService webSocketService}) 
      : _webSocketService = webSocketService {
    _initializeWebSocket();
  }

  // Getters
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;
  WebSocketService get webSocketService => _webSocketService;

  // Initialize WebSocket connection
  Future<void> _initializeWebSocket() async {
    try {
      await _webSocketService.connect();
      _isConnected = true;
      _errorMessage = null;
      notifyListeners();
      
      // Listen to WebSocket connection status changes
      _webSocketService.messageStream.listen((_) {
        // Connection is working if we receive messages
        if (!_isConnected) {
          _isConnected = true;
          _errorMessage = null;
          notifyListeners();
        }
      }, onError: (error) {
        _isConnected = false;
        _errorMessage = 'WebSocket error: $error';
        notifyListeners();
        
        // Try to reconnect
        _reconnect();
      }, onDone: () {
        _isConnected = false;
        _errorMessage = 'WebSocket connection closed';
        notifyListeners();
        
        // Try to reconnect
        _reconnect();
      });
    } catch (e) {
      _isConnected = false;
      _errorMessage = 'Failed to connect: $e';
      notifyListeners();
      
      // Try to reconnect
      _reconnect();
    }
  }
  
  // Reconnect if connection is lost
  Future<void> _reconnect() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!_isConnected) {
      _initializeWebSocket();
    }
  }
  
  // Manually reconnect
  Future<void> reconnect() async {
    _webSocketService.disconnect();
    await _initializeWebSocket();
  }
  
  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}
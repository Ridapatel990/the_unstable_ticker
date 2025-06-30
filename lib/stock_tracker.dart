import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:the_unstable_ticker/stock_provider.dart';

class StockTracker {
  final String url;
  WebSocket? _socket;
  bool _shouldReconnect = true;

  final ValueNotifier<bool> isConnected = ValueNotifier(false);
  final ValueNotifier<ConnectionStatus> statusNotifier = ValueNotifier(
    ConnectionStatus.connecting,
  );

  final Map<String, double> _latestPrices = {};
  final Map<String, double> _previousPrices = {};

  final void Function(Map<String, double>) onPricesUpdated;

  StockTracker(this.url, this.onPricesUpdated);

  void start() {
    _shouldReconnect = true;
    _connect();
  }

  void stop() {
    _shouldReconnect = false;
    _socket?.close();
  }

  void _connect() async {
    statusNotifier.value = ConnectionStatus.connecting;
    debugPrint('[StockTracker] Connecting to $url');

    try {
      _socket = await WebSocket.connect(url);
      debugPrint('[StockTracker] Connected!');
      isConnected.value = true;

      statusNotifier.value = ConnectionStatus.connecting;
      statusNotifier.value = ConnectionStatus.connected;

      _socket!.listen(
        _onMessage,
        onDone: _handleDone,
        onError: _handleError,
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('[StockTracker] Connect error: $e');
      statusNotifier.value = ConnectionStatus.disconnected;
      _handleConnectionFailure();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      if (data is List) {
        for (var item in data) {
          final ticker = item['ticker'];
          final price = double.tryParse(item['price'] ?? '');
          if (ticker == null || price == null) continue;

          final prev = _previousPrices[ticker] ?? price;
          if (price <= 0) {
            debugPrint('[StockTracker] Invalid price for $ticker: $price');
            continue;
          }
          if (price < prev * 0.5) {
            debugPrint('[StockTracker] Anomalous drop for $ticker: $price');
            continue;
          }

          _previousPrices[ticker] = _latestPrices[ticker] ?? price;
          _latestPrices[ticker] = price;
        }
        onPricesUpdated(Map<String, double>.from(_latestPrices));
      }
    } catch (e) {
      debugPrint('[StockTracker] Malformed data: $message');
    }
  }

  void _handleDone() {
    debugPrint('[StockTracker] Connection closed.');
    isConnected.value = false;
    statusNotifier.value = ConnectionStatus.reconnecting;
    _scheduleReconnect();
  }

  void _handleError(error) {
    debugPrint('[StockTracker] Connection error: $error');
    isConnected.value = false;
    statusNotifier.value = ConnectionStatus.reconnecting;
    _scheduleReconnect();
  }

  void _handleConnectionFailure() {
    isConnected.value = false;
    statusNotifier.value = ConnectionStatus.reconnecting;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_shouldReconnect) {
      debugPrint('[StockTracker] Reconnecting in 3 seconds...');
      statusNotifier.value = ConnectionStatus.disconnected;
      Future.delayed(const Duration(seconds: 3), _connect);
    }
  }
}

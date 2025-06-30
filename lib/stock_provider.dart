import 'package:flutter/foundation.dart';

import 'stock_tracker.dart';

//Enum
enum ConnectionStatus { connecting, connected, reconnecting, disconnected }

class StockProvider extends ChangeNotifier {
  late StockTracker _tracker;
  Map<String, double> stocks = {};
  ConnectionStatus status = ConnectionStatus.connecting;

  StockProvider() {
    _tracker = StockTracker('ws://127.0.0.1:8080/ws', (updatedPrices) {
      stocks = updatedPrices;
      notifyListeners();
    });

    _tracker.statusNotifier.addListener(() {
      status = _tracker.statusNotifier.value;
      debugPrint('[StockProvider] New status: $status');
      notifyListeners();
    });

    _tracker.start();
  }

  @override
  void dispose() {
    _tracker.stop();
    super.dispose();
  }
}

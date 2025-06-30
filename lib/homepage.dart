import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_unstable_ticker/stock_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final stocks = provider.stocks;
    final status = provider.status;
    // final isConnected = provider.isConnected;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case ConnectionStatus.connecting:
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        statusText = 'Connecting...';
        break;
      case ConnectionStatus.connected:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Connected';
        break;
      case ConnectionStatus.reconnecting:
        statusColor = Colors.orange;
        statusIcon = Icons.autorenew;
        statusText = 'Reconnecting...';
        break;
      case ConnectionStatus.disconnected:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Disconnected';
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('📈 Stock Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              // color: isConnected ? Colors.green : Colors.red,
              color: statusColor,
              child: Row(
                children: [
                  // Icon(isConnected ? Icons.check_circle : Icons.error),
                  Icon(statusIcon, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    // isConnected ? 'Connected' : 'Disconnected',
                    statusText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16),
                itemCount: stocks.length,
                itemBuilder: (_, index) {
                  final ticker = stocks.keys.elementAt(index);
                  final price = stocks[ticker]!;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    title: Text(ticker),
                    trailing: Text('\$${price.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

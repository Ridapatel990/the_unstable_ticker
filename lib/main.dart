import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_unstable_ticker/homepage.dart';

import 'stock_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => StockProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

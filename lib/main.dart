import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- добавлено
import 'package:flutter_application_1/widgets/bottom.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <-- добавлено
  await initializeDateFormatting('ru', null); // <-- добавлено

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Bottom(),
    );
  }
}

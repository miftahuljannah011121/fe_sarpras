import 'package:flutter/material.dart';
import 'package:fe_sarpras/pages/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(  // HILANGKAN const disini
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

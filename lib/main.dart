import 'package:codigo6_maps/pages/home_page.dart';
import 'package:codigo6_maps/pages/permission_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PermissionPage(),
    );
  }
}

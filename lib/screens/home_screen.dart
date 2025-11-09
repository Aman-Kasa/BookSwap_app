import 'package:flutter/material.dart';
import '../widgets/shared_layout.dart';

class HomeScreen extends StatelessWidget {
  final int initialIndex;
  
  const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SharedLayout(initialIndex: initialIndex);
  }
}
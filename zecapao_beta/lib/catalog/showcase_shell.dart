import 'package:flutter/material.dart';
import 'showcase_home.dart';

class ShowcaseShellPage extends StatelessWidget {
  final String customerName;
  final String phone;
  const ShowcaseShellPage({super.key,required this.customerName,required this.phone});

  @override
  Widget build(BuildContext context){
    return ShowcaseHomePage(customerName:customerName,phone:phone);
  }
}

import 'package:flutter/material.dart';
import 'showcase_home.dart';
import 'pousada_demo.dart';

class ShowcaseShellPage extends StatelessWidget {
  final String customerName;
  final String phone;
  const ShowcaseShellPage({super.key,required this.customerName,required this.phone});

  @override
  Widget build(BuildContext context){
    return Stack(children:[
      ShowcaseHomePage(customerName:customerName,phone:phone),
      Positioned(
        right:14,
        bottom:82,
        child:SafeArea(
          child:Material(
            color:Colors.transparent,
            child:InkWell(
              onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const PousadaDemoPage())),
              borderRadius:BorderRadius.circular(18),
              child:Container(
                padding:const EdgeInsets.symmetric(horizontal:13,vertical:10),
                decoration:BoxDecoration(color:const Color(0xFF0C6B5C),borderRadius:BorderRadius.circular(18),boxShadow:const [BoxShadow(color:Color(0x33000000),blurRadius:16,offset:Offset(0,7))]),
                child:const Row(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.hotel_rounded,color:Colors.white,size:18),SizedBox(width:7),Text('POUSADA DEMO',style:TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:.5))]),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

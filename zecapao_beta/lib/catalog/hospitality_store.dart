import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core.dart';

class HospitalityStorePage extends StatelessWidget{
  final Store store;
  const HospitalityStorePage({super.key,required this.store});

  Future<void> _open(BuildContext context) async {
    final raw=store.ctaUrl.isNotEmpty?store.ctaUrl:(store.bookingWhatsapp.isNotEmpty?'https://wa.me/${store.bookingWhatsapp.replaceAll(RegExp(r'\D'),'')}':'');
    if(raw.isEmpty)return;
    final ok=await launchUrl(Uri.parse(raw),mode:LaunchMode.externalApplication);
    if(!ok&&context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Não foi possível abrir a reserva.')));
  }

  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:appBg,
    body:CustomScrollView(slivers:[
      SliverAppBar(expandedHeight:320,pinned:true,foregroundColor:Colors.white,backgroundColor:brandNavy,flexibleSpace:FlexibleSpaceBar(background:Stack(fit:StackFit.expand,children:[
        store.coverUrl.isNotEmpty?Image.network(store.coverUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:brandNavy)):Container(color:brandNavy),
        const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(colors:[Color(0x22000000),Color(0xC9000000)],begin:Alignment.topCenter,end:Alignment.bottomCenter))),
        Positioned(left:22,right:22,bottom:24,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          if(store.logoUrl.isNotEmpty)CircleAvatar(radius:37,backgroundColor:Colors.white,backgroundImage:NetworkImage(store.logoUrl)),
          const SizedBox(height:12),Text(store.name,style:const TextStyle(color:Colors.white,fontSize:30,fontWeight:FontWeight.w900)),
          if(store.address.isNotEmpty)Text(store.address,style:const TextStyle(color:Colors.white70,fontSize:11.5,fontWeight:FontWeight.w700)),
        ]))
      ]))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(18,22,18,120),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        if(store.priceRange.isNotEmpty)Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),child:Text(store.priceRange,style:const TextStyle(fontWeight:FontWeight.w900))),
        const SizedBox(height:18),Text(store.description.isEmpty?'Hospede-se no Vale e viva a Chapada por inteiro.':store.description,style:const TextStyle(color:brandMuted,fontSize:13,height:1.55)),
        if(store.amenities.isNotEmpty)...[const SizedBox(height:24),const Text('Comodidades',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:10),Wrap(spacing:8,runSpacing:8,children:store.amenities.map((x)=>Chip(avatar:const Icon(Icons.check_circle_outline_rounded,size:17),label:Text(x))).toList())],
        if(store.galleryUrls.isNotEmpty)...[const SizedBox(height:26),const Text('Conheça o espaço',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:12),SizedBox(height:180,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:store.galleryUrls.length,separatorBuilder:(_,__)=>const SizedBox(width:10),itemBuilder:(_,i)=>ClipRRect(borderRadius:BorderRadius.circular(22),child:Image.network(store.galleryUrls[i],width:260,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(width:260,color:Colors.white))))],
      ])))
    ]),
    bottomNavigationBar:(store.ctaUrl.isEmpty&&store.bookingWhatsapp.isEmpty)?null:SafeArea(child:Container(color:Colors.white,padding:const EdgeInsets.fromLTRB(16,10,16,12),child:FilledButton.icon(onPressed:()=>_open(context),icon:const Icon(Icons.calendar_month_rounded),label:Text(store.ctaLabel.isEmpty?'FAZER RESERVA':store.ctaLabel.toUpperCase()))))
  );
}

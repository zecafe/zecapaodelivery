import 'package:flutter/material.dart';
import 'core.dart';

class PousadaDemoPage extends StatelessWidget {
  const PousadaDemoPage({super.key});

  Widget _pill(IconData icon,String text)=>Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.92),borderRadius:BorderRadius.circular(16)),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:16,color:const Color(0xFF0C6B5C)),const SizedBox(width:6),Text(text,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w800))]));

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:appBg,
      body:CustomScrollView(slivers:[
        SliverAppBar(
          expandedHeight:330,
          pinned:true,
          backgroundColor:const Color(0xFF0B5C53),
          foregroundColor:Colors.white,
          flexibleSpace:FlexibleSpaceBar(background:Stack(fit:StackFit.expand,children:[
            const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF4FA9C9),Color(0xFF87C8C4),Color(0xFF1E6D55)],begin:Alignment.topCenter,end:Alignment.bottomCenter))),
            Positioned(left:-40,bottom:0,child:Icon(Icons.landscape_rounded,size:330,color:const Color(0xFF184F3F).withValues(alpha:.88))),
            Positioned(right:-30,bottom:-10,child:Icon(Icons.landscape_rounded,size:260,color:const Color(0xFF2F7654).withValues(alpha:.86))),
            Positioned(left:24,right:24,bottom:28,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Container(width:92,height:92,padding:const EdgeInsets.all(5),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(28),boxShadow:const [BoxShadow(color:Color(0x33000000),blurRadius:20,offset:Offset(0,8))]),child:ClipRRect(borderRadius:BorderRadius.circular(23),child:Image.asset('Ativos/Marca/pousada_logo_demo.jpg',fit:BoxFit.cover,errorBuilder:(_,__,___)=>const Icon(Icons.hotel_rounded,size:52,color:Color(0xFF0C6B5C))))),
              const SizedBox(height:14),
              const Text('Pousada do Capão',style:TextStyle(color:Colors.white,fontSize:32,fontWeight:FontWeight.w900)),
              const SizedBox(height:4),
              const Text('Chapada Diamantina • Vale do Capão',style:TextStyle(color:Colors.white70,fontSize:12,fontWeight:FontWeight.w700)),
            ])),
          ])),
        ),
        SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(18,22,18,120),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Wrap(spacing:8,runSpacing:8,children:[_pill(Icons.star_rounded,'4,9'),_pill(Icons.park_rounded,'Imersa na natureza'),_pill(Icons.local_cafe_rounded,'Café da manhã'),_pill(Icons.wifi_rounded,'Wi‑Fi')]),
          const SizedBox(height:24),
          const Text('Hospedar também é viver o destino',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900)),
          const SizedBox(height:8),
          const Text('Uma experiência de hospedagem integrada à paisagem do Vale do Capão, com jardins, silêncio, montanhas e acesso às experiências locais.',style:TextStyle(color:brandMuted,fontSize:13,height:1.55)),
          const SizedBox(height:26),
          const Text('Escolha sua experiência',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
          const SizedBox(height:12),
          SizedBox(height:190,child:ListView(scrollDirection:Axis.horizontal,children:[
            _experienceCard('Suíte Jardim','Acorde cercado de verde.',Icons.local_florist_rounded,const [Color(0xFF1B6E56),Color(0xFF66A577)]),
            const SizedBox(width:12),
            _experienceCard('Refúgio da Serra','Silêncio, descanso e montanha.',Icons.landscape_rounded,const [Color(0xFF7A5B39),Color(0xFFC4955E)]),
            const SizedBox(width:12),
            _experienceCard('Fim de semana no Vale','Hospedagem + experiências locais.',Icons.hiking_rounded,const [Color(0xFF315B78),Color(0xFF63A7B8)]),
          ])),
          const SizedBox(height:28),
          Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:const Color(0xFFE8F3ED),borderRadius:BorderRadius.circular(24)),child:const Row(children:[CircleAvatar(backgroundColor:Color(0xFF0C6B5C),child:Icon(Icons.savings_rounded,color:Colors.white)),SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('ValeCoin em hospedagens',style:TextStyle(fontWeight:FontWeight.w900)),SizedBox(height:3),Text('Modelo de benefício para parceiros do turismo.',style:TextStyle(color:brandMuted,fontSize:11))]))])),
        ]))),
      ]),
      bottomNavigationBar:SafeArea(child:Container(color:Colors.white,padding:const EdgeInsets.fromLTRB(16,10,16,12),child:FilledButton.icon(onPressed:(){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Fluxo de reserva demonstrativo do MVP')));},icon:const Icon(Icons.calendar_month_rounded),label:const Text('VER DISPONIBILIDADE')))),
    );
  }

  static Widget _experienceCard(String title,String subtitle,IconData icon,List<Color> colors)=>Container(width:240,padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:LinearGradient(colors:colors,begin:Alignment.topLeft,end:Alignment.bottomRight),borderRadius:BorderRadius.circular(25),boxShadow:const [BoxShadow(color:Color(0x18000000),blurRadius:16,offset:Offset(0,8))]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.end,children:[Icon(icon,color:Colors.white,size:46),const Spacer(),Text(title,style:const TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(subtitle,style:const TextStyle(color:Colors.white70,fontSize:10.5))]));
}

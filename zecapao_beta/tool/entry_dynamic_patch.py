from pathlib import Path

p=Path('lib/catalog/signup_required.dart')
p.write_text(r'''import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core.dart';
import 'showcase_shell.dart';

class RequiredSignupPage extends StatefulWidget {
  const RequiredSignupPage({super.key});
  @override State<RequiredSignupPage> createState()=>_RequiredSignupPageState();
}

class _RequiredSignupPageState extends State<RequiredSignupPage>{
  final name=TextEditingController(),phone=TextEditingController();
  bool terms=false,loading=true,revealLogin=false;
  String? error;
  Map<String,dynamic>? cfg;
  Timer? timer;

  @override void initState(){super.initState();_load();}
  @override void dispose(){timer?.cancel();name.dispose();phone.dispose();super.dispose();}

  Future<void> _load() async {
    try{
      final rows=await Supabase.instance.client.from('app_entry_config').select().eq('is_active',true).order('sort_order').limit(1);
      if(rows.isNotEmpty){
        cfg=Map<String,dynamic>.from(rows.first);
        if((cfg?['mode']??'')=='media_then_login'){
          final secs=(cfg?['media_duration_seconds']??5) as int;
          timer=Timer(Duration(seconds:secs.clamp(1,30)),(){if(mounted)setState(()=>revealLogin=true);});
        }
      }
    }catch(_){ }
    if(mounted)setState(()=>loading=false);
  }

  String digits(String v)=>v.replaceAll(RegExp(r'\D'),'');
  void enter(){
    final showName=cfg?['show_name_field']??true;
    final showPhone=cfg?['show_phone_field']??true;
    final showTerms=cfg?['show_terms']??true;
    final n=name.text.trim(),p=digits(phone.text);
    if(showName&&n.length<2){setState(()=>error='Informe seu nome para continuar.');return;}
    if(showPhone&&(p.length<10||p.length>11)){setState(()=>error='Informe um celular válido com DDD.');return;}
    if(showTerms&&!terms){setState(()=>error='Aceite os termos e a política de privacidade.');return;}
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>ShowcaseShellPage(customerName:n.isEmpty?'Cliente':n,phone:p)));
  }

  @override Widget build(BuildContext context){
    if(loading)return const Scaffold(backgroundColor:brandRed,body:Center(child:CircularProgressIndicator(color:Colors.white)));
    final mode=(cfg?['mode']??'login').toString();
    final media=(cfg?['media_url']??'').toString();
    final title=(cfg?['title']??'Tudo que Vale,\nperto de você.').toString();
    final subtitle=(cfg?['subtitle']??'Comida, compras, serviços e experiências do Vale do Capão.').toString();
    final cta=(cfg?['primary_cta_label']??'ENTRAR NO ZÉ CAPÃO').toString();
    final showName=cfg?['show_name_field']??true;
    final showPhone=cfg?['show_phone_field']??true;
    final showTerms=cfg?['show_terms']??true;
    final mediaOnly=mode=='media_fullscreen';
    final timed=mode=='media_then_login';
    final showForm=!mediaOnly&&(!timed||revealLogin);
    final showMedia=media.startsWith('http')&&(mode=='login_campaign'||mediaOnly||timed);

    return Scaffold(backgroundColor:brandRed,body:Stack(children:[
      if(showMedia)Positioned.fill(child:Image.network(media,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:brandRed))),
      if(showMedia&&!mediaOnly)Positioned.fill(child:Container(color:Colors.black.withValues(alpha:.38))),
      if(mediaOnly)Positioned.fill(child:GestureDetector(onTap:enter,child:Container(color:Colors.transparent))),
      if(mediaOnly)SafeArea(child:Align(alignment:Alignment.bottomCenter,child:Padding(padding:const EdgeInsets.all(22),child:FilledButton(onPressed:enter,child:SizedBox(width:double.infinity,child:Text(cta,textAlign:TextAlign.center)))))),
      if(showForm)SafeArea(child:ListView(padding:const EdgeInsets.all(24),children:[
        const SizedBox(height:28),
        Center(child:Container(width:112,height:112,padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(30)),child:ClipRRect(borderRadius:BorderRadius.circular(22),child:Image.asset('Ativos/Marca/zecapao_app_icon.png',fit:BoxFit.cover)))),
        const SizedBox(height:28),
        Text(title,style:const TextStyle(color:Colors.white,fontSize:34,height:1.02,fontWeight:FontWeight.w900)),
        const SizedBox(height:8),
        Text(subtitle,style:const TextStyle(color:Colors.white70,fontSize:14,height:1.4)),
        const SizedBox(height:24),
        Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:appBg.withValues(alpha:.96),borderRadius:BorderRadius.circular(28)),child:Column(children:[
          if(showName)...[TextField(controller:name,textCapitalization:TextCapitalization.words,decoration:const InputDecoration(labelText:'Seu nome *',prefixIcon:Icon(Icons.person_outline_rounded))),const SizedBox(height:12)],
          if(showPhone)...[TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'Celular com DDD *',hintText:'(75) 99999-9999',prefixIcon:Icon(Icons.phone_outlined))),const SizedBox(height:4)],
          if(showTerms)CheckboxListTile(contentPadding:EdgeInsets.zero,value:terms,activeColor:brandRed,onChanged:(v)=>setState((){terms=v??false;error=null;}),title:const Text('Aceito os termos e a política de privacidade',style:TextStyle(fontSize:12))),
          if(error!=null)...[Container(width:double.infinity,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:brandRedSoft,borderRadius:BorderRadius.circular(14)),child:Text(error!,style:const TextStyle(color:brandRed,fontSize:12,fontWeight:FontWeight.w700))),const SizedBox(height:12)],
          FilledButton(onPressed:enter,child:SizedBox(width:double.infinity,child:Text(cta,textAlign:TextAlign.center))),
        ]))
      ])),
      if(timed&&!revealLogin)SafeArea(child:Align(alignment:Alignment.bottomCenter,child:Padding(padding:const EdgeInsets.all(20),child:Text('Abrindo em ${cfg?['media_duration_seconds']??5}s',style:const TextStyle(color:Colors.white70,fontWeight:FontWeight.w700))))),
    ]));
  }
}
''')
print('Dynamic entry patch applied')

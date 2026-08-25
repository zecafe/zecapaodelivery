from pathlib import Path

p=Path('lib/catalog/signup_required.dart')
p.write_text(r'''import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'core.dart';
import 'showcase_shell.dart';

class RequiredSignupPage extends StatefulWidget {
  const RequiredSignupPage({super.key});
  @override State<RequiredSignupPage> createState()=>_RequiredSignupPageState();
}

class _RequiredSignupPageState extends State<RequiredSignupPage>{
  final name=TextEditingController(),phone=TextEditingController();
  bool terms=false,loading=true,revealLogin=false,knownCustomer=false,locating=false;
  String? error,locationLabel;
  Map<String,dynamic>? cfg;
  Timer? timer;

  @override void initState(){super.initState();_load();}
  @override void dispose(){timer?.cancel();name.dispose();phone.dispose();super.dispose();}

  Future<void> _load() async {
    try{
      final prefs=await SharedPreferences.getInstance();
      final savedName=prefs.getString('zecapao_customer_name')??'';
      final savedPhone=prefs.getString('zecapao_customer_phone')??'';
      if(savedName.trim().length>=2&&savedPhone.trim().length>=10){
        name.text=savedName; phone.text=savedPhone; knownCustomer=true; terms=true;
      }
      final rows=await Supabase.instance.client.from('app_entry_config').select().eq('is_active',true).order('sort_order').limit(1);
      if(rows.isNotEmpty){
        cfg=Map<String,dynamic>.from(rows.first);
        if((cfg?['mode']??'')=='media_then_login'){
          final secs=int.tryParse('${cfg?['media_duration_seconds']??5}')??5;
          timer=Timer(Duration(seconds:secs.clamp(1,30)),(){if(mounted)setState(()=>revealLogin=true);});
        }
      }
    }catch(_){ }
    if(mounted)setState(()=>loading=false);
  }

  String digits(String v)=>v.replaceAll(RegExp(r'\D'),'');

  Future<Position?> _ensureLocation() async {
    if(locating)return null;
    setState(()=>locating=true);
    try{
      if(!await Geolocator.isLocationServiceEnabled()){
        if(mounted)setState(()=>locationLabel='Ative a localização do aparelho para ver o que está perto.');
        return null;
      }
      var permission=await Geolocator.checkPermission();
      if(permission==LocationPermission.denied){permission=await Geolocator.requestPermission();}
      if(permission==LocationPermission.denied||permission==LocationPermission.deniedForever){
        if(mounted)setState(()=>locationLabel='Localização não autorizada. Você pode continuar e ativar depois.');
        return null;
      }
      final pos=await Geolocator.getCurrentPosition(locationSettings:const LocationSettings(accuracy:LocationAccuracy.high,timeLimit:Duration(seconds:12)));
      final prefs=await SharedPreferences.getInstance();
      await prefs.setDouble('zecapao_latitude',pos.latitude);
      await prefs.setDouble('zecapao_longitude',pos.longitude);
      await prefs.setInt('zecapao_location_at',DateTime.now().millisecondsSinceEpoch);
      if(mounted)setState(()=>locationLabel='Localização atualizada ✓');
      return pos;
    }catch(_){
      if(mounted)setState(()=>locationLabel='Não foi possível atualizar a localização agora.');
      return null;
    }finally{if(mounted)setState(()=>locating=false);}
  }

  Future<void> _finishEntry() async {
    final n=name.text.trim(),p=digits(phone.text);
    final prefs=await SharedPreferences.getInstance();
    await prefs.setString('zecapao_customer_name',n.isEmpty?'Cliente':n);
    await prefs.setString('zecapao_customer_phone',p);
    await prefs.setBool('zecapao_terms_accepted',true);
    await _ensureLocation();
    if(!mounted)return;
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>ShowcaseShellPage(customerName:n.isEmpty?'Cliente':n,phone:p)));
  }

  Future<void> enter() async {
    final showName=cfg?['show_name_field']??true;
    final showPhone=cfg?['show_phone_field']??true;
    final showTerms=cfg?['show_terms']??true;
    final n=name.text.trim(),p=digits(phone.text);
    if(knownCustomer){await _finishEntry();return;}
    if(showName&&n.length<2){setState(()=>error='Informe seu nome para continuar.');return;}
    if(showPhone&&(p.length<10||p.length>11)){setState(()=>error='Informe um celular válido com DDD.');return;}
    if(showTerms&&!terms){setState(()=>error='Aceite os termos e a política de privacidade.');return;}
    await _finishEntry();
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
      if(showMedia)Positioned.fill(child:_EntryMedia(url:media)),
      if(showMedia&&!mediaOnly)Positioned.fill(child:Container(color:Colors.black.withValues(alpha:.38))),
      if(mediaOnly)Positioned.fill(child:GestureDetector(onTap:enter,child:Container(color:Colors.transparent))),
      if(mediaOnly)SafeArea(child:Align(alignment:Alignment.bottomCenter,child:Padding(padding:const EdgeInsets.all(22),child:FilledButton(onPressed:enter,child:SizedBox(width:double.infinity,child:Text(knownCustomer?'CONTINUAR':cta,textAlign:TextAlign.center)))))),
      if(showForm)SafeArea(child:ListView(padding:const EdgeInsets.all(24),children:[
        const SizedBox(height:28),
        Center(child:Container(width:112,height:112,padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(30)),child:ClipRRect(borderRadius:BorderRadius.circular(22),child:Image.asset('Ativos/Marca/zecapao_app_icon.png',fit:BoxFit.cover)))),
        const SizedBox(height:28),
        Text(title,style:const TextStyle(color:Colors.white,fontSize:34,height:1.02,fontWeight:FontWeight.w900)),
        const SizedBox(height:8),
        Text(knownCustomer?'Bem-vindo de volta, ${name.text.split(' ').first}. Vamos atualizar sua localização e seguir.':subtitle,style:const TextStyle(color:Colors.white70,fontSize:14,height:1.4)),
        const SizedBox(height:24),
        Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:appBg.withValues(alpha:.96),borderRadius:BorderRadius.circular(28)),child:Column(children:[
          if(!knownCustomer&&showName)...[TextField(controller:name,textCapitalization:TextCapitalization.words,decoration:const InputDecoration(labelText:'Seu nome *',prefixIcon:Icon(Icons.person_outline_rounded))),const SizedBox(height:12)],
          if(!knownCustomer&&showPhone)...[TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'Celular com DDD *',hintText:'(75) 99999-9999',prefixIcon:Icon(Icons.phone_outlined))),const SizedBox(height:4)],
          if(!knownCustomer&&showTerms)CheckboxListTile(contentPadding:EdgeInsets.zero,value:terms,activeColor:brandRed,onChanged:(v)=>setState((){terms=v??false;error=null;}),title:const Text('Aceito os termos e a política de privacidade',style:TextStyle(fontSize:12))),
          if(knownCustomer)Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(children:[const Icon(Icons.location_on_rounded,color:brandRed),const SizedBox(width:10),Expanded(child:Text(locationLabel??'Usaremos sua localização para priorizar estabelecimentos próximos.',style:const TextStyle(fontSize:11.5,color:brandMuted)))])),
          if(error!=null)...[const SizedBox(height:10),Container(width:double.infinity,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:brandRedSoft,borderRadius:BorderRadius.circular(14)),child:Text(error!,style:const TextStyle(color:brandRed,fontSize:12,fontWeight:FontWeight.w700)))],
          const SizedBox(height:12),
          FilledButton(onPressed:locating?null:enter,child:SizedBox(width:double.infinity,child:Text(locating?'ATUALIZANDO LOCALIZAÇÃO...':knownCustomer?'CONTINUAR':'${cta.toUpperCase()} + LOCALIZAÇÃO',textAlign:TextAlign.center))),
        ]))
      ])),
      if(timed&&!revealLogin)SafeArea(child:Align(alignment:Alignment.bottomCenter,child:Padding(padding:const EdgeInsets.fromLTRB(20,20,20,28),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Abrindo em ${cfg?['media_duration_seconds']??5}s',style:const TextStyle(color:Colors.white70,fontWeight:FontWeight.w700)),TextButton(onPressed:()=>setState(()=>revealLogin=true),child:const Text('PULAR',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900)))])))),
    ]));
  }
}

class _EntryMedia extends StatefulWidget{
  final String url; const _EntryMedia({required this.url});
  @override State<_EntryMedia> createState()=>_EntryMediaState();
}
class _EntryMediaState extends State<_EntryMedia>{
  VideoPlayerController? controller;
  bool get isVideo{final u=widget.url.toLowerCase().split('?').first;return u.endsWith('.mp4')||u.endsWith('.mov')||u.endsWith('.m4v')||u.endsWith('.webm');}
  @override void initState(){super.initState();if(isVideo){controller=VideoPlayerController.networkUrl(Uri.parse(widget.url))..initialize().then((_){controller?.setLooping(true);controller?.setVolume(0);controller?.play();if(mounted)setState((){});});}}
  @override void dispose(){controller?.dispose();super.dispose();}
  @override Widget build(BuildContext context){if(isVideo){final c=controller;if(c!=null&&c.value.isInitialized)return FittedBox(fit:BoxFit.cover,child:SizedBox(width:c.value.size.width,height:c.value.size.height,child:VideoPlayer(c)));return Container(color:brandRed,alignment:Alignment.center,child:const CircularProgressIndicator(color:Colors.white));}return Image.network(widget.url,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:brandRed));}
}
''')
print('Dynamic entry patch applied: persistent customer + location + image/GIF/video')

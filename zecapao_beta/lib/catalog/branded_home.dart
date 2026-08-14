import 'package:flutter/material.dart';
import 'core.dart';
import 'branded_store.dart';
import 'wallet.dart';

class BrandedSignupPage extends StatefulWidget {
  const BrandedSignupPage({super.key});
  @override State<BrandedSignupPage> createState()=>_BrandedSignupPageState();
}

class _BrandedSignupPageState extends State<BrandedSignupPage>{
  final name=TextEditingController();
  final phone=TextEditingController();
  bool terms=false;
  @override void dispose(){name.dispose();phone.dispose();super.dispose();}

  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:brandRed,
    body:SafeArea(child:Stack(children:[
      Positioned(top:-70,right:-70,child:Container(width:220,height:220,decoration:BoxDecoration(color:brandYellow.withValues(alpha:.18),shape:BoxShape.circle))),
      Positioned(bottom:-100,left:-80,child:Container(width:260,height:260,decoration:BoxDecoration(color:brandInk.withValues(alpha:.12),shape:BoxShape.circle))),
      ListView(padding:const EdgeInsets.fromLTRB(24,34,24,24),children:[
        Center(child:Container(width:128,height:128,padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(32),boxShadow:const [BoxShadow(color:Color(0x33000000),blurRadius:28,offset:Offset(0,12))]),child:ClipRRect(borderRadius:BorderRadius.circular(24),child:Image.asset('Ativos/Marca/zecapao_app_icon.png',fit:BoxFit.cover)))),
        const SizedBox(height:28),
        const Text('O Capão chegou.',style:TextStyle(color:Colors.white,fontSize:34,fontWeight:FontWeight.w900,height:1.02)),
        const SizedBox(height:9),
        const Text('Comida, cafés, mercados, eventos e experiências do Vale em um só lugar.',style:TextStyle(color:Colors.white70,height:1.45,fontSize:14)),
        const SizedBox(height:24),
        Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:appBg,borderRadius:BorderRadius.circular(26),boxShadow:const [BoxShadow(color:Color(0x26000000),blurRadius:24,offset:Offset(0,10))]),child:Column(children:[
          TextField(controller:name,decoration:const InputDecoration(labelText:'Como podemos te chamar?',prefixIcon:Icon(Icons.person_outline_rounded))),
          const SizedBox(height:12),
          TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'Seu WhatsApp',prefixIcon:Icon(Icons.phone_outlined))),
          const SizedBox(height:4),
          CheckboxListTile(contentPadding:EdgeInsets.zero,value:terms,activeColor:brandRed,onChanged:(v)=>setState(()=>terms=v??false),title:const Text('Aceito os termos e a política de privacidade',style:TextStyle(fontSize:12))),
          const SizedBox(height:4),
          FilledButton(onPressed:terms?()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>BrandedHomePage(customerName:name.text.trim().isEmpty?'Capão':name.text.trim(),phone:phone.text.trim()))):null,child:const SizedBox(width:double.infinity,child:Text('ENTRAR NO ZÉ CAPÃO',textAlign:TextAlign.center))),
        ])),
      ])
    ])),
  );
}

class BrandedHomePage extends StatefulWidget{
  final String customerName,phone;
  const BrandedHomePage({super.key,required this.customerName,required this.phone});
  @override State<BrandedHomePage> createState()=>_BrandedHomePageState();
}

class _BrandedHomePageState extends State<BrandedHomePage>{
  final repo=Repo();
  final search=TextEditingController();
  late Future<List<Store>> storesFuture;
  late Future<List<CampaignBanner>> bannersFuture;
  late Future<ValeCoinBalance> walletFuture;
  int tab=0;

  @override void initState(){super.initState();storesFuture=repo.stores();bannersFuture=repo.banners();walletFuture=repo.valecoinBalance(widget.phone);}
  @override void dispose(){search.dispose();super.dispose();}

  Future<void> refreshAll() async{
    final s=repo.stores(); final b=repo.banners(); final w=repo.valecoinBalance(widget.phone);
    setState((){storesFuture=s;bannersFuture=b;walletFuture=w;});
    await Future.wait([s,b,w]);
  }

  Widget safeAsset(String asset,{double? width,double? height,BoxFit fit=BoxFit.contain})=>Image.asset(asset,width:width,height:height,fit:fit,errorBuilder:(_,__,___)=>Container(width:width,height:height,color:brandBeige,child:const Icon(Icons.storefront_rounded,color:brandRed)));
  Widget logo(Store store,{double size=58}){
    final fallback=safeAsset(store.localLogo,width:size,height:size);
    if(store.logoUrl.isEmpty)return fallback;
    return Image.network(store.logoUrl,width:size,height:size,fit:BoxFit.contain,errorBuilder:(_,__,___)=>fallback);
  }

  Future<void> openStore(Store store)async{
    if(!store.isOpen)return;
    await Navigator.push(context,MaterialPageRoute(builder:(_)=>BrandedStorePage(store:store,customerName:widget.customerName,phone:widget.phone,repo:repo)));
    if(mounted)setState(()=>walletFuture=repo.valecoinBalance(widget.phone));
  }

  Widget header()=>Padding(padding:const EdgeInsets.fromLTRB(16,8,16,12),child:Row(children:[
    Container(width:44,height:44,padding:const EdgeInsets.all(3),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14)),child:ClipRRect(borderRadius:BorderRadius.circular(11),child:safeAsset('Ativos/Marca/zecapao_app_icon.png',fit:BoxFit.cover))),
    const SizedBox(width:11),
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Salve, ${widget.customerName}!',style:const TextStyle(fontSize:13,color:brandMuted,fontWeight:FontWeight.w600)),const Row(children:[Icon(Icons.location_on_rounded,size:16,color:brandRed),SizedBox(width:3),Text('Vale do Capão • BA',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900))])])),
    Container(width:42,height:42,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14)),child:IconButton(onPressed:(){},icon:const Icon(Icons.notifications_none_rounded))),
  ]));

  Widget categoryStrip(){
    const items=[('Comer & Beber',Icons.restaurant_rounded,brandRed),('Mercados',Icons.shopping_cart_outlined,brandGreen),('Lojas',Icons.shopping_bag_outlined,Color(0xFFF2994A)),('Hospedagem',Icons.bed_outlined,Color(0xFF9B51E0)),('Experiências',Icons.landscape_outlined,Color(0xFF299E91)),('Serviços',Icons.work_outline_rounded,Color(0xFF2F80ED)),('Eventos',Icons.local_activity_outlined,Color(0xFFEB4D8B))];
    return SizedBox(height:104,child:ListView.separated(padding:const EdgeInsets.symmetric(horizontal:16),scrollDirection:Axis.horizontal,itemCount:items.length,separatorBuilder:(_,__)=>const SizedBox(width:11),itemBuilder:(_,i){final item=items[i];return InkWell(onTap:()=>setState(()=>tab=item.$1=='Eventos'?3:1),borderRadius:BorderRadius.circular(20),child:SizedBox(width:76,child:Column(children:[Container(width:62,height:62,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20),boxShadow:const [BoxShadow(color:Color(0x0C000000),blurRadius:14,offset:Offset(0,5))]),child:Icon(item.$2,color:item.$3,size:28)),const SizedBox(height:7),Text(item.$1,maxLines:2,textAlign:TextAlign.center,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w700,height:1.05))]))); }));
  }

  Widget campaignBanners(List<Store> stores)=>FutureBuilder<List<CampaignBanner>>(future:bannersFuture,builder:(_,snap){
    final items=snap.data??[]; if(items.isEmpty)return const SizedBox.shrink();
    return SizedBox(height:188,child:PageView.builder(controller:PageController(viewportFraction:.93),itemCount:items.length,itemBuilder:(_,i){final b=items[i];final fg=hexColor(b.textHex,Colors.white);final bg=hexColor(b.backgroundHex,brandRed);return InkWell(borderRadius:BorderRadius.circular(28),onTap:(){if(b.targetType=='store'&&b.targetValue.isNotEmpty){final found=stores.where((s)=>s.id==b.targetValue).toList();if(found.isNotEmpty)openStore(found.first);}else if(b.title.toLowerCase().contains('valecoin')){Navigator.push(context,MaterialPageRoute(builder:(_)=>ValeCoinWalletPage(phone:widget.phone,repo:repo)));}},child:Container(margin:const EdgeInsets.only(right:10),clipBehavior:Clip.antiAlias,decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(28),boxShadow:const [BoxShadow(color:Color(0x12000000),blurRadius:22,offset:Offset(0,9))]),child:Stack(fit:StackFit.expand,children:[
      if(b.imageUrl.isNotEmpty)Image.network(b.imageUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const SizedBox.shrink()),
      if(b.imageUrl.isNotEmpty)Container(decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.centerRight,end:Alignment.centerLeft,colors:[Color(0x22000000),Color(0xAA000000)]))),
      Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Text(b.title,maxLines:2,style:TextStyle(color:fg,fontSize:27,fontWeight:FontWeight.w900,height:1.02)),if(b.subtitle.isNotEmpty)...[const SizedBox(height:8),SizedBox(width:260,child:Text(b.subtitle,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(color:fg.withValues(alpha:.88),fontSize:13,height:1.35)))],if(b.ctaLabel.isNotEmpty)...[const SizedBox(height:14),Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),decoration:BoxDecoration(color:brandYellow,borderRadius:BorderRadius.circular(14)),child:Text(b.ctaLabel,style:const TextStyle(color:brandInk,fontSize:10,fontWeight:FontWeight.w900)))]]))
    ]))));}));
  });

  Widget walletCard()=>FutureBuilder<ValeCoinBalance>(future:walletFuture,builder:(_,snap){final wallet=snap.data??ValeCoinBalance.zero();return InkWell(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ValeCoinWalletPage(phone:widget.phone,repo:repo))),borderRadius:BorderRadius.circular(22),child:Container(margin:const EdgeInsets.symmetric(horizontal:16),padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:brandNavy,borderRadius:BorderRadius.circular(22)),child:Row(children:[Container(width:48,height:48,alignment:Alignment.center,decoration:const BoxDecoration(color:brandYellow,shape:BoxShape.circle),child:const Text('V',style:TextStyle(color:brandInk,fontSize:24,fontWeight:FontWeight.w900))),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('VALECOIN',style:TextStyle(color:Colors.white70,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1)),Text('${wallet.balanceCoins} VC',style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),Text('${valecoinMoney(wallet.balanceCoins)} em benefícios',style:const TextStyle(color:Colors.white60,fontSize:11))])),const Icon(Icons.chevron_right_rounded,color:Colors.white70)]))));});

  Widget storeCard(Store store,{bool horizontal=false})=>InkWell(onTap:()=>openStore(store),borderRadius:BorderRadius.circular(22),child:Container(width:horizontal?230:null,margin:horizontal?EdgeInsets.zero:const EdgeInsets.only(bottom:14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),boxShadow:const [BoxShadow(color:Color(0x0D000000),blurRadius:18,offset:Offset(0,7))]),clipBehavior:Clip.antiAlias,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    if(store.coverUrl.isNotEmpty)SizedBox(height:horizontal?94:118,width:double.infinity,child:Image.network(store.coverUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:brandBeige))),
    Padding(padding:const EdgeInsets.all(12),child:Row(children:[Container(width:58,height:58,padding:const EdgeInsets.all(5),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0x11000000))),child:ClipRRect(borderRadius:BorderRadius.circular(11),child:logo(store,size:48))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(store.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:15.5,fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(store.description,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:brandMuted,fontSize:10.5)),const SizedBox(height:6),Row(children:[const Icon(Icons.star_rounded,size:14,color:brandYellow),const SizedBox(width:2),const Text('4,9',style:TextStyle(fontSize:10,fontWeight:FontWeight.w800)),const SizedBox(width:8),Text('${store.estimatedMinutes} min',style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700)),const Spacer(),Text(store.isOpen?'Aberto':'Fechado',style:TextStyle(fontSize:9,fontWeight:FontWeight.w900,color:store.isOpen?brandGreen:brandRed))])]))]))
  ])));

  Widget homeTab(List<Store> stores)=>RefreshIndicator(onRefresh:refreshAll,child:ListView(padding:EdgeInsets.zero,children:[
    header(),
    Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:GestureDetector(onTap:()=>setState(()=>tab=1),child:AbsorbPointer(child:TextField(decoration:InputDecoration(hintText:'Buscar produtos, lojas, serviços...',prefixIcon:const Icon(Icons.search_rounded,color:brandInk),suffixIcon:Container(margin:const EdgeInsets.all(6),decoration:BoxDecoration(color:brandYellow,borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.tune_rounded,size:19,color:brandInk)))))),
    const SizedBox(height:16),campaignBanners(stores),
    const Padding(padding:EdgeInsets.fromLTRB(16,22,16,10),child:Text('O que você precisa hoje?',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900))),categoryStrip(),
    const SizedBox(height:8),walletCard(),
    const Padding(padding:EdgeInsets.fromLTRB(16,24,16,10),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Perto de você',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),Text('Ver todos',style:TextStyle(color:brandRed,fontSize:12,fontWeight:FontWeight.w800))])),
    SizedBox(height:160,child:ListView.separated(padding:const EdgeInsets.symmetric(horizontal:16),scrollDirection:Axis.horizontal,itemCount:stores.length,separatorBuilder:(_,__)=>const SizedBox(width:12),itemBuilder:(_,i)=>storeCard(stores[i],horizontal:true))),
    const Padding(padding:EdgeInsets.fromLTRB(16,26,16,10),child:Text('Parceiros do Capão',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900))),
    Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Column(children:stores.map(storeCard).toList())),
    Container(margin:const EdgeInsets.fromLTRB(16,10,16,28),padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:brandInk,borderRadius:BorderRadius.circular(24)),child:const Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Descubra o Vale do Capão',style:TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),SizedBox(height:6),Text('Eventos, hospedagem, trilhas, cultura e serviços locais.',style:TextStyle(color:Colors.white70,fontSize:12,height:1.4))])),SizedBox(width:10),CircleAvatar(radius:26,backgroundColor:brandYellow,child:Icon(Icons.landscape_rounded,color:brandInk))]))
  ]));

  Widget searchTab(List<Store> stores){final q=search.text.trim().toLowerCase();final filtered=q.isEmpty?stores:stores.where((s)=>s.name.toLowerCase().contains(q)||s.description.toLowerCase().contains(q)).toList();return ListView(padding:const EdgeInsets.all(16),children:[const Text('Buscar no Vale',style:TextStyle(fontSize:26,fontWeight:FontWeight.w900)),const SizedBox(height:12),TextField(controller:search,autofocus:true,onChanged:(_)=>setState((){}),decoration:InputDecoration(hintText:'Café, pizza, mercado...',prefixIcon:const Icon(Icons.search_rounded),suffixIcon:search.text.isEmpty?null:IconButton(onPressed:(){search.clear();setState((){});},icon:const Icon(Icons.close_rounded)))),const SizedBox(height:18),...filtered.map(storeCard)]);}

  Widget ordersTab()=>ListView(padding:const EdgeInsets.all(16),children:[const Text('Meus pedidos',style:TextStyle(fontSize:26,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('Seus pedidos em andamento e recentes aparecem aqui.',style:TextStyle(color:brandMuted)),const SizedBox(height:24),Container(padding:const EdgeInsets.all(24),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(24)),child:const Column(children:[CircleAvatar(radius:32,backgroundColor:brandBeige,child:Icon(Icons.receipt_long_rounded,color:brandRed,size:32)),SizedBox(height:14),Text('Nenhum pedido por aqui ainda',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900)),SizedBox(height:5),Text('Quando a fome chamar, a gente registra tudo aqui.',textAlign:TextAlign.center,style:TextStyle(color:brandMuted))]))]);

  Widget eventsTab()=>ListView(padding:const EdgeInsets.all(16),children:[const Text('Eventos no Vale',style:TextStyle(fontSize:26,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('Agenda, cultura e experiências para viver o Capão.',style:TextStyle(color:brandMuted)),const SizedBox(height:20),Container(height:180,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(color:brandNavy,borderRadius:BorderRadius.circular(26)),child:Stack(children:[Positioned.fill(child:Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[brandRed,brandNavy],begin:Alignment.topLeft,end:Alignment.bottomRight)))),const Positioned(left:20,top:20,child:Container(padding:EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:brandYellow,borderRadius:BorderRadius.all(Radius.circular(12))),child:Text('AGENDA DO VALE',style:TextStyle(fontSize:9,fontWeight:FontWeight.w900)))),const Positioned(left:20,right:20,bottom:20,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Capão Reggae Vale',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w900)),SizedBox(height:5),Text('Música, encontro e Chapada.',style:TextStyle(color:Colors.white70))]))]))]);

  Widget profileTab()=>ListView(padding:const EdgeInsets.all(16),children:[Row(children:[Container(width:68,height:68,padding:const EdgeInsets.all(4),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22)),child:ClipRRect(borderRadius:BorderRadius.circular(17),child:safeAsset('Ativos/Marca/zecapao_app_icon.png',fit:BoxFit.cover))),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.customerName,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),Text(widget.phone.isEmpty?'WhatsApp não informado':widget.phone,style:const TextStyle(color:brandMuted))]))]),const SizedBox(height:22),walletCard(),const SizedBox(height:18),...[(Icons.location_on_outlined,'Endereços'),(Icons.credit_card_outlined,'Formas de pagamento'),(Icons.discount_outlined,'Cupons'),(Icons.help_outline_rounded,'Ajuda'),(Icons.settings_outlined,'Configurações')].map((e)=>Container(margin:const EdgeInsets.only(bottom:8),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18)),child:ListTile(leading:Icon(e.$1,color:brandRed),title:Text(e.$2,style:const TextStyle(fontWeight:FontWeight.w700)),trailing:const Icon(Icons.chevron_right_rounded))))]);

  @override Widget build(BuildContext context)=>FutureBuilder<List<Store>>(future:storesFuture,builder:(_,snap){
    final stores=snap.data??[];
    Widget body;
    if(snap.connectionState==ConnectionState.waiting&&stores.isEmpty){body=const Center(child:CircularProgressIndicator());}
    else if(snap.hasError){body=Center(child:Padding(padding:const EdgeInsets.all(24),child:Text('Não foi possível carregar o Vale agora.\n${snap.error}',textAlign:TextAlign.center)));}
    else{body=[homeTab(stores),searchTab(stores),ordersTab(),eventsTab(),profileTab()][tab];}
    return Scaffold(backgroundColor:appBg,body:SafeArea(child:body),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const [NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home_rounded),label:'Início'),NavigationDestination(icon:Icon(Icons.search_rounded),label:'Busca'),NavigationDestination(icon:Icon(Icons.receipt_long_outlined),selectedIcon:Icon(Icons.receipt_long_rounded),label:'Pedidos'),NavigationDestination(icon:Icon(Icons.local_activity_outlined),selectedIcon:Icon(Icons.local_activity_rounded),label:'Eventos'),NavigationDestination(icon:Icon(Icons.person_outline_rounded),selectedIcon:Icon(Icons.person_rounded),label:'Conta')]));
  });
}

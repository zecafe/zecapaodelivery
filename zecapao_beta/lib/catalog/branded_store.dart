import 'package:flutter/material.dart';
import 'core.dart';
import 'checkout.dart';

class BrandedStorePage extends StatefulWidget {
  final Store store;
  final String customerName, phone;
  final Repo repo;
  const BrandedStorePage({super.key,required this.store,required this.customerName,required this.phone,required this.repo});
  @override State<BrandedStorePage> createState()=>_BrandedStorePageState();
}

class _BrandedStorePageState extends State<BrandedStorePage>{
  late Future<List<Product>> future;
  final cart=<String,CartLine>{};
  String category='Todos';
  @override void initState(){super.initState();future=widget.repo.products(widget.store.id);}
  double get subtotal=>cart.values.fold(0.0,(s,e)=>s+e.total);
  int get count=>cart.values.fold(0,(s,e)=>s+e.quantity);

  Widget logo({double size=72}){
    Widget fallback=Image.asset(widget.store.localLogo,width:size,height:size,fit:BoxFit.contain,errorBuilder:(_,__,___)=>Container(color:brandBeige,child:const Icon(Icons.storefront,color:brandRed)));
    if(widget.store.logoUrl.isEmpty)return fallback;
    return Image.network(widget.store.logoUrl,width:size,height:size,fit:BoxFit.contain,errorBuilder:(_,__,___)=>fallback);
  }

  Widget productImage(Product p,{double size=108}){
    if(p.imageUrl.isEmpty){
      return Container(width:size,height:size,decoration:BoxDecoration(color:brandBeige,borderRadius:BorderRadius.circular(18)),child:const Icon(Icons.restaurant,color:brandRed,size:34));
    }
    return ClipRRect(borderRadius:BorderRadius.circular(18),child:Image.network(p.imageUrl,width:size,height:size,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(width:size,height:size,color:brandBeige,child:const Icon(Icons.restaurant,color:brandRed))));
  }

  void add(Product p){setState(()=>cart.update(p.id,(e){e.quantity++;return e;},ifAbsent:()=>CartLine(p)));}

  Widget hero(){
    return Stack(children:[
      Container(height:205,color:brandInk),
      if(widget.store.coverUrl.isNotEmpty) SizedBox(height:205,width:double.infinity,child:Image.network(widget.store.coverUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const SizedBox.shrink())),
      Container(height:205,decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0x22000000),Color(0xCC000000)]))),
      Positioned(left:18,right:18,bottom:18,child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:[
        Container(width:78,height:78,padding:const EdgeInsets.all(7),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20),boxShadow:const [BoxShadow(color:Color(0x33000000),blurRadius:18,offset:Offset(0,8))]),child:ClipRRect(borderRadius:BorderRadius.circular(14),child:logo(size:64))),
        const SizedBox(width:13),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(widget.store.name,style:const TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.w900)),
          const SizedBox(height:3),
          Text('${widget.store.estimatedMinutes} min  •  Frete ${money(widget.store.deliveryFee)}',style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.w700)),
        ])),
        Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:widget.store.isOpen?brandGreen:brandRed,borderRadius:BorderRadius.circular(20)),child:Text(widget.store.isOpen?'ABERTO':'FECHADO',style:const TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.w900))),
      ])),
    ]);
  }

  Widget emptyCatalog()=>Padding(padding:const EdgeInsets.fromLTRB(16,24,16,100),child:Container(padding:const EdgeInsets.all(28),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(26),boxShadow:const [BoxShadow(color:Color(0x0D000000),blurRadius:20,offset:Offset(0,8))]),child:const Column(children:[
    CircleAvatar(radius:34,backgroundColor:brandBeige,child:Icon(Icons.menu_book_rounded,size:34,color:brandRed)),SizedBox(height:16),Text('Cardápio em preparação',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),SizedBox(height:7),Text('Este parceiro já faz parte do Zé Capão. O cardápio completo entra em breve.',textAlign:TextAlign.center,style:TextStyle(color:brandMuted,height:1.45)),
  ])));

  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:appBg,
    appBar:AppBar(title:Text(widget.store.name),actions:[IconButton(onPressed:(){},icon:const Icon(Icons.favorite_border_rounded))]),
    bottomNavigationBar:cart.isEmpty?null:SafeArea(child:Container(padding:const EdgeInsets.fromLTRB(14,10,14,12),decoration:const BoxDecoration(color:Colors.white,boxShadow:[BoxShadow(color:Color(0x16000000),blurRadius:20,offset:Offset(0,-4))]),child:FilledButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>CheckoutPage(store:widget.store,customerName:widget.customerName,phone:widget.phone,repo:widget.repo,items:cart.values.toList()))),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Container(width:28,height:28,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.white.withValues(alpha:.2),borderRadius:BorderRadius.circular(9)),child:Text('$count',style:const TextStyle(fontWeight:FontWeight.w900))),const Text('VER CARRINHO'),Text(money(subtotal),style:const TextStyle(fontWeight:FontWeight.w900))])))),
    body:FutureBuilder<List<Product>>(future:future,builder:(_,snap){
      if(snap.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
      if(snap.hasError)return Center(child:Padding(padding:const EdgeInsets.all(24),child:Text('Não foi possível carregar o cardápio.\n${snap.error}',textAlign:TextAlign.center)));
      final products=snap.data??[];
      final categories=['Todos',...{for(final p in products)if(p.category.isNotEmpty)p.category}];
      final filtered=category=='Todos'?products:products.where((p)=>p.category==category).toList();
      final featured=products.where((p)=>p.featured).toList();
      return ListView(children:[
        hero(),
        Padding(padding:const EdgeInsets.fromLTRB(16,16,16,0),child:Text(widget.store.description,style:const TextStyle(color:brandMuted,height:1.45))),
        if(products.isEmpty) emptyCatalog() else ...[
          if(featured.isNotEmpty)...[
            const Padding(padding:EdgeInsets.fromLTRB(16,24,16,10),child:Text('Favoritos da casa',style:TextStyle(fontSize:22,fontWeight:FontWeight.w900))),
            SizedBox(height:214,child:ListView.separated(padding:const EdgeInsets.symmetric(horizontal:16),scrollDirection:Axis.horizontal,itemCount:featured.length,separatorBuilder:(_,__)=>const SizedBox(width:12),itemBuilder:(_,i){final p=featured[i];return InkWell(onTap:()=>add(p),borderRadius:BorderRadius.circular(22),child:Container(width:166,padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),boxShadow:const [BoxShadow(color:Color(0x0D000000),blurRadius:18,offset:Offset(0,7))]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:SizedBox(width:double.infinity,child:productImage(p,size:146))),const SizedBox(height:8),if(p.badge.isNotEmpty)Text(p.badge.toUpperCase(),style:const TextStyle(color:brandRed,fontSize:9,fontWeight:FontWeight.w900)),Text(p.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w800)),Text(money(p.price),style:const TextStyle(color:brandInk,fontWeight:FontWeight.w900))])));})) ,
          ],
          const Padding(padding:EdgeInsets.fromLTRB(16,24,16,8),child:Text('Cardápio',style:TextStyle(fontSize:22,fontWeight:FontWeight.w900))),
          SizedBox(height:46,child:ListView.separated(padding:const EdgeInsets.symmetric(horizontal:16),scrollDirection:Axis.horizontal,itemCount:categories.length,separatorBuilder:(_,__)=>const SizedBox(width:8),itemBuilder:(_,i){final c=categories[i];final selected=category==c;return ChoiceChip(label:Text(c),selected:selected,onSelected:(_)=>setState(()=>category=c),labelStyle:TextStyle(color:selected?Colors.white:brandInk,fontWeight:FontWeight.w700));})),
          const SizedBox(height:14),
          ...filtered.map((p)=>Container(margin:const EdgeInsets.fromLTRB(16,0,16,12),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),boxShadow:const [BoxShadow(color:Color(0x0B000000),blurRadius:16,offset:Offset(0,6))]),child:Row(children:[
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[if(p.badge.isNotEmpty)Container(margin:const EdgeInsets.only(bottom:6),padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:brandYellow,borderRadius:BorderRadius.circular(10)),child:Text(p.badge.toUpperCase(),style:const TextStyle(fontSize:8,fontWeight:FontWeight.w900,color:brandInk))),Text(p.name,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(p.description,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(color:brandMuted,fontSize:12,height:1.35)),const SizedBox(height:10),Text(money(p.price),style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900))])),
            const SizedBox(width:10),Stack(alignment:Alignment.bottomRight,children:[productImage(p),Padding(padding:const EdgeInsets.all(5),child:IconButton.filled(style:IconButton.styleFrom(backgroundColor:brandRed,foregroundColor:Colors.white),onPressed:()=>add(p),icon:const Icon(Icons.add_rounded)))])
          ]))),
          const SizedBox(height:96),
        ]
      ]);
    }),
  );
}

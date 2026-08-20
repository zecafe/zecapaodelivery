import 'package:flutter/material.dart';
import 'core.dart';
import 'checkout.dart';

class MerchantStoreV2Page extends StatefulWidget {
  final Store store;
  final String customerName;
  final String phone;
  final Repo repo;
  const MerchantStoreV2Page({super.key,required this.store,required this.customerName,required this.phone,required this.repo});
  @override State<MerchantStoreV2Page> createState()=>_MerchantStoreV2PageState();
}

class _MerchantStoreV2PageState extends State<MerchantStoreV2Page>{
  late Future<List<Product>> future; final cart=<String,CartLine>{}; String category='Todos';
  bool get isZecafe=>widget.store.slug=='zecafe';
  @override void initState(){super.initState();future=widget.repo.products(widget.store.id);}
  double get subtotal=>cart.values.fold(0.0,(s,l)=>s+l.total); int get count=>cart.values.fold(0,(s,l)=>s+l.quantity);

  Widget merchantLogo({double size=76}){
    final local=Image.asset(widget.store.localLogo,width:size,height:size,fit:BoxFit.contain,errorBuilder:(_,__,___)=>const Icon(Icons.storefront_rounded,color:brandRed));
    if(isZecafe||widget.store.logoUrl.isEmpty)return local;
    return Image.network(widget.store.logoUrl,width:size,height:size,fit:BoxFit.contain,errorBuilder:(_,__,___)=>local);
  }
  Widget placeholderHero()=>Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[brandRed,Color(0xFFFF8A2B)],begin:Alignment.topLeft,end:Alignment.bottomRight)),child:Stack(children:[Positioned(right:-30,top:10,child:Icon(Icons.landscape_rounded,size:190,color:Colors.white24)),Positioned(left:24,bottom:28,child:Text(widget.store.name,style:const TextStyle(color:Colors.white,fontSize:28,fontWeight:FontWeight.w900)))]));
  Widget zecafeHero()=>Container(
    color: const Color(0xFF715441),
    child: Stack(children:[
      Positioned.fill(child:Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF6A4D3B),Color(0xFF8C6A50)],begin:Alignment.centerLeft,end:Alignment.centerRight)))),
      Positioned(right:-10,bottom:-12,child:Opacity(opacity:.96,child:Image.asset('Ativos/Marca/zecafe_products/banoffee.webp',width:210,height:185,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const SizedBox.shrink()))),
      Positioned(right:132,top:14,child:Opacity(opacity:.9,child:Image.asset('Ativos/Marca/zecafe_products/capuccino.webp',width:92,height:92,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const SizedBox.shrink()))),
      Positioned(left:22,top:42,right:185,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('RESPIRA...\nVOCÊ CHEGOU!',style:TextStyle(color:Colors.white,fontSize:21,height:1.0,fontWeight:FontWeight.w900,letterSpacing:.2)),
        const SizedBox(height:12),
        Image.asset('Ativos/Marca/zecafe_logo_oficial.jpg',height:62,fit:BoxFit.contain,alignment:Alignment.centerLeft,errorBuilder:(_,__,___)=>const Text('Zecafé',style:TextStyle(color:Color(0xFFF3E3C7),fontSize:34,fontWeight:FontWeight.w900))),
        const SizedBox(height:8),
        const Text('Café • afeto • Vale do Capão',style:TextStyle(color:Color(0xFFF3E3C7),fontSize:11,fontWeight:FontWeight.w700)),
      ])),
    ]),
  );
  Widget merchantHero(){
    if(isZecafe)return zecafeHero();
    if(widget.store.coverUrl.isEmpty)return placeholderHero();
    return Image.network(widget.store.coverUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>placeholderHero());
  }
  Widget productFallback(double w,double h,BorderRadius b)=>Container(width:w,height:h,decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFFFFEFE7),brandBeige]),borderRadius:b),child:const Icon(Icons.restaurant_menu_rounded,color:brandRed,size:38));
  Widget productImage(Product p,{double width=132,double height=118,BorderRadius? radius}){
    final b=radius??BorderRadius.circular(22);
    if(isZecafe&&p.localImage.isNotEmpty)return ClipRRect(borderRadius:b,child:Image.asset(p.localImage,width:width,height:height,fit:BoxFit.cover,errorBuilder:(_,__,___)=>productFallback(width,height,b)));
    if(p.imageUrl.isEmpty)return productFallback(width,height,b);
    return ClipRRect(borderRadius:b,child:Image.network(p.imageUrl,width:width,height:height,fit:BoxFit.cover,errorBuilder:(_,__,___)=>p.localImage.isNotEmpty?Image.asset(p.localImage,width:width,height:height,fit:BoxFit.cover,errorBuilder:(_,__,___)=>productFallback(width,height,b)):productFallback(width,height,b)));
  }
  void add(Product p){setState(()=>cart.update(p.id,(l){l.quantity++;return l;},ifAbsent:()=>CartLine(p)));}
  Widget pill(IconData i,String t)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),decoration:BoxDecoration(color:appBg,borderRadius:BorderRadius.circular(14)),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(i,size:15,color:brandInk),const SizedBox(width:5),Text(t,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w700))]));
  Widget headerCard()=>Transform.translate(offset:const Offset(0,-38),child:Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Container(padding:const EdgeInsets.fromLTRB(18,0,18,18),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(30),boxShadow:const [BoxShadow(color:Color(0x17000000),blurRadius:24,offset:Offset(0,10))]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Align(alignment:Alignment.topCenter,child:Transform.translate(offset:const Offset(0,-34),child:Container(width:82,height:82,padding:const EdgeInsets.all(7),decoration:BoxDecoration(color:Colors.white,shape:BoxShape.circle,boxShadow:const [BoxShadow(color:Color(0x22000000),blurRadius:16,offset:Offset(0,7))]),child:ClipOval(child:merchantLogo(size:68))))),Transform.translate(offset:const Offset(0,-22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(widget.store.name,style:const TextStyle(fontSize:26,fontWeight:FontWeight.w900))),Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:widget.store.isOpen?const Color(0xFFE6F7ED):brandRedSoft,borderRadius:BorderRadius.circular(16)),child:Text(widget.store.isOpen?'ABERTO':'FECHADO',style:TextStyle(fontSize:9,fontWeight:FontWeight.w900,color:widget.store.isOpen?brandGreen:brandRed)))]),const SizedBox(height:4),Text(widget.store.description.isEmpty?'Parceiro local do Vale do Capão.':widget.store.description,style:const TextStyle(color:brandMuted,fontSize:12,height:1.4)),const SizedBox(height:14),Wrap(spacing:8,runSpacing:8,children:[pill(Icons.star_rounded,'4,9'),pill(Icons.schedule_rounded,'${widget.store.estimatedMinutes} min'),pill(Icons.delivery_dining_rounded,'Frete ${money(widget.store.deliveryFee)}')])]))]))));
  Widget benefits()=>Padding(padding:const EdgeInsets.fromLTRB(16,0,16,22),child:Row(children:[Expanded(child:_benefit(Icons.savings_rounded,'VALECOIN','1% a 3% de volta',brandYellow,brandInk)),const SizedBox(width:10),Expanded(child:_benefit(Icons.local_offer_rounded,'BENEFÍCIO','Ofertas do parceiro',const Color(0xFFE6F7ED),brandGreen))]));
  Widget _benefit(IconData i,String a,String b,Color bg,Color fg)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(20)),child:Row(children:[Icon(i,color:fg),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a,style:TextStyle(fontSize:9,color:fg,fontWeight:FontWeight.w900)),Text(b,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w700))]))]));
  Widget highlights(List<Product> f){if(f.isEmpty)return const SizedBox.shrink();return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Padding(padding:EdgeInsets.symmetric(horizontal:16),child:Text('Destaques',style:TextStyle(fontSize:23,fontWeight:FontWeight.w900))),const SizedBox(height:12),SizedBox(height:228,child:ListView.separated(padding:const EdgeInsets.symmetric(horizontal:16),scrollDirection:Axis.horizontal,itemCount:f.length,separatorBuilder:(_,__)=>const SizedBox(width:12),itemBuilder:(_,i){final p=f[i];return InkWell(onTap:()=>add(p),borderRadius:BorderRadius.circular(24),child:SizedBox(width:172,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[productImage(p,width:172,height:154),const SizedBox(height:8),Text(money(p.price),style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900)),Text(p.name,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12.5,height:1.2))])));}))]);}
  Widget categoryRail(List<String> cs)=>SizedBox(height:48,child:ListView.separated(padding:const EdgeInsets.symmetric(horizontal:16),scrollDirection:Axis.horizontal,itemCount:cs.length,separatorBuilder:(_,__)=>const SizedBox(width:8),itemBuilder:(_,i){final c=cs[i],sel=c==category;return ChoiceChip(label:Text(c),selected:sel,onSelected:(_)=>setState(()=>category=c),labelStyle:TextStyle(color:sel?Colors.white:brandInk,fontWeight:FontWeight.w800));}));
  Widget productRow(Product p)=>InkWell(onTap:()=>add(p),child:Padding(padding:const EdgeInsets.fromLTRB(16,10,16,10),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[if(p.badge.isNotEmpty)...[Text(p.badge.toUpperCase(),style:const TextStyle(color:brandRed,fontSize:9,fontWeight:FontWeight.w900)),const SizedBox(height:5)],Text(p.name,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900)),const SizedBox(height:5),Text(p.description.isEmpty?'Produto do parceiro.':p.description,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(color:brandMuted,fontSize:11.5,height:1.35)),const SizedBox(height:10),Text(money(p.price),style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900))])),const SizedBox(width:12),Stack(alignment:Alignment.bottomRight,children:[productImage(p,width:118,height:104,radius:BorderRadius.circular(20)),Padding(padding:const EdgeInsets.all(6),child:IconButton.filled(style:IconButton.styleFrom(backgroundColor:Colors.white,foregroundColor:brandRed),onPressed:()=>add(p),icon:const Icon(Icons.add_rounded)))])])));
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:appBg,bottomNavigationBar:cart.isEmpty?null:SafeArea(child:Container(padding:const EdgeInsets.fromLTRB(14,10,14,12),color:Colors.white,child:FilledButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>CheckoutPage(store:widget.store,customerName:widget.customerName,phone:widget.phone,repo:widget.repo,items:cart.values.toList()))),child:Row(children:[Container(width:28,height:28,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.white24,borderRadius:BorderRadius.circular(8)),child:Text('$count')),const SizedBox(width:12),const Expanded(child:Text('VER CARRINHO')),Text(money(subtotal),style:const TextStyle(fontWeight:FontWeight.w900))])))),body:FutureBuilder<List<Product>>(future:future,builder:(_,snap){if(snap.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());if(snap.hasError)return Center(child:Text('Não foi possível carregar o cardápio.\n${snap.error}',textAlign:TextAlign.center));final ps=snap.data??[],cs=['Todos',...{for(final p in ps)if(p.category.isNotEmpty)p.category}],filtered=category=='Todos'?ps:ps.where((p)=>p.category==category).toList(),featured=ps.where((p)=>p.featured).toList();return CustomScrollView(slivers:[SliverAppBar(expandedHeight:245,pinned:true,backgroundColor:brandInk,foregroundColor:Colors.white,actions:[IconButton(onPressed:(){},icon:const Icon(Icons.search_rounded)),IconButton(onPressed:(){},icon:const Icon(Icons.favorite_border_rounded))],flexibleSpace:FlexibleSpaceBar(background:merchantHero())),SliverToBoxAdapter(child:headerCard()),SliverToBoxAdapter(child:benefits()),if(featured.isNotEmpty)SliverToBoxAdapter(child:highlights(featured)),if(ps.isNotEmpty)SliverToBoxAdapter(child:categoryRail(cs)),SliverList(delegate:SliverChildBuilderDelegate((_,i)=>productRow(filtered[i]),childCount:filtered.length)),const SliverToBoxAdapter(child:SizedBox(height:100))]);}));
}
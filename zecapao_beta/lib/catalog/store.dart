import 'package:flutter/material.dart';
import 'core.dart';
import 'checkout.dart';

class StorePage extends StatefulWidget {
  final Store store;
  final String customerName, phone;
  final Repo repo;
  const StorePage({super.key,required this.store,required this.customerName,required this.phone,required this.repo});
  @override State<StorePage> createState()=>_StorePageState();
}

class _StorePageState extends State<StorePage>{
  late Future<List<Product>> future;
  final cart=<String,CartLine>{};
  @override void initState(){super.initState();future=widget.repo.products(widget.store.id);}
  double get subtotal=>cart.values.fold(0,(s,e)=>s+e.total);
  int get count=>cart.values.fold(0,(s,e)=>s+e.quantity);
  void add(Product p){setState(()=>cart.update(p.id,(e){e.quantity++;return e;},ifAbsent:()=>CartLine(p)));}
  @override Widget build(BuildContext c){return Scaffold(
    appBar:AppBar(title:Text(widget.store.name)),
    bottomNavigationBar:cart.isEmpty?null:SafeArea(child:Padding(padding:const EdgeInsets.all(12),child:FilledButton(
      onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>CheckoutPage(store:widget.store,customerName:widget.customerName,phone:widget.phone,repo:widget.repo,items:cart.values.toList()))),
      child:Text('CARRINHO • $count • ${money(subtotal)}')))),
    body:FutureBuilder<List<Product>>(future:future,builder:(_,s){
      if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
      if(s.hasError)return Center(child:Text('Erro: ${s.error}'));
      final products=s.data??[];
      return ListView(padding:const EdgeInsets.all(16),children:[
        Row(children:[Image.asset(widget.store.logo,width:72,height:72,fit:BoxFit.contain),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.store.name,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),Text('${widget.store.estimatedMinutes} min • ${money(widget.store.deliveryFee)} entrega')]))]),
        const SizedBox(height:18),const Text('Cardápio',style:TextStyle(fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:8),
        ...products.map((p)=>Card(child:ListTile(title:Text(p.name,style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('${p.description}\n${money(p.price)}'),isThreeLine:true,trailing:IconButton.filled(onPressed:()=>add(p),icon:const Icon(Icons.add)))))
      ]);
    })
  );}
}

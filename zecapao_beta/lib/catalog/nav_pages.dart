import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core.dart';
import 'category_hub.dart';

class OrdersPage extends StatefulWidget {
  final String phone;
  const OrdersPage({super.key, required this.phone});
  @override State<OrdersPage> createState()=>_OrdersPageState();
}
class _OrdersPageState extends State<OrdersPage>{
  late Future<List<Map<String,dynamic>>> future;
  @override void initState(){super.initState();future=_load();}
  Future<List<Map<String,dynamic>>> _load() async {
    final rows=await Supabase.instance.client.rpc('get_guest_orders_by_phone',params:{'p_phone':widget.phone});
    return (rows as List).map((e)=>Map<String,dynamic>.from(e)).toList();
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Meus pedidos')),body:FutureBuilder<List<Map<String,dynamic>>>(future:future,builder:(_,snap){
    if(snap.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
    final items=snap.data??[];
    if(items.isEmpty)return const Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.receipt_long_outlined,size:54,color:brandMuted),SizedBox(height:12),Text('Você ainda não tem pedidos por aqui.',style:TextStyle(color:brandMuted,fontWeight:FontWeight.w700))]));
    return RefreshIndicator(onRefresh:()async=>setState(()=>future=_load()),child:ListView.separated(padding:const EdgeInsets.all(16),itemCount:items.length,separatorBuilder:(_,__)=>const SizedBox(height:10),itemBuilder:(_,i){final o=items[i];return Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18)),child:Row(children:[CircleAvatar(backgroundColor:brandRedSoft,child:const Icon(Icons.shopping_bag_rounded,color:brandRed)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${o['store_name']??'Parceiro'}',style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:4),Text('${o['status']??'pending'} • ${money(double.tryParse('${o['total']??0}')??0)}',style:const TextStyle(color:brandMuted,fontSize:12))])),const Icon(Icons.chevron_right_rounded)]));}));
  }));
}

class ExplorePage extends StatelessWidget {
  final String customerName,phone; final Repo repo;
  const ExplorePage({super.key,required this.customerName,required this.phone,required this.repo});
  @override Widget build(BuildContext context){
    const items=[('Comida',Icons.restaurant_rounded),('Cafés',Icons.coffee_rounded),('Pizzas',Icons.local_pizza_rounded),('Pousadas',Icons.hotel_rounded),('Experiências',Icons.hiking_rounded),('Eventos',Icons.local_activity_rounded),('Serviços',Icons.miscellaneous_services_rounded)];
    return Scaffold(appBar:AppBar(title:const Text('Explorar o Vale')),body:GridView.builder(padding:const EdgeInsets.all(16),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:1.2),itemCount:items.length,itemBuilder:(_,i){final x=items[i];return InkWell(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>CategoryHubPage(category:x.$1,customerName:customerName,phone:phone,repo:repo))),borderRadius:BorderRadius.circular(22),child:Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(x.$2,size:40,color:brandRed),const SizedBox(height:10),Text(x.$1,style:const TextStyle(fontWeight:FontWeight.w900))]))); }));
  }
}

class AccountPage extends StatefulWidget {
  final String customerName,phone;
  const AccountPage({super.key,required this.customerName,required this.phone});
  @override State<AccountPage> createState()=>_AccountPageState();
}
class _AccountPageState extends State<AccountPage>{
  String location='Localização salva no dispositivo';
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{final p=await SharedPreferences.getInstance();final lat=p.getDouble('zecapao_latitude'),lng=p.getDouble('zecapao_longitude');if(mounted&&lat!=null&&lng!=null)setState(()=>location='${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}');}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Minha conta')),body:ListView(padding:const EdgeInsets.all(18),children:[Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22)),child:Row(children:[CircleAvatar(radius:28,backgroundColor:brandRedSoft,child:Text(widget.customerName.isEmpty?'Z':widget.customerName[0].toUpperCase(),style:const TextStyle(color:brandRed,fontSize:22,fontWeight:FontWeight.w900))),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.customerName,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),Text(widget.phone,style:const TextStyle(color:brandMuted))]))])),const SizedBox(height:12),ListTile(tileColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),leading:const Icon(Icons.location_on_rounded,color:brandRed),title:const Text('Minha localização'),subtitle:Text(location)),const SizedBox(height:12),ListTile(tileColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),leading:const Icon(Icons.support_agent_rounded,color:brandRed),title:const Text('Ajuda e suporte'),subtitle:const Text('Área preparada para o suporte do Zé Capão'))]));
}

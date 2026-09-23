import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl='https://yovjbqtazkreruvxoawf.supabase.co';
const supabaseAnonKey='sb_publishable_0bNYhr66x-Jxfqa43gZxvw_gq3FjcmL';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url:supabaseUrl,anonKey:supabaseAnonKey);
  runApp(const ZeEntregadorApp());
}
String money(num v)=>'R\$ ${v.toStringAsFixed(2).replaceAll('.',',')}';
double driverFare(double km,{double base=6,double includedKm=2,double extraPerKm=1.5})=>base+((km-includedKm).clamp(0,double.infinity)*extraPerKm);

class ZeEntregadorApp extends StatelessWidget{
 const ZeEntregadorApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Zé Entregador',theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:const Color(0xFFF6F0E4),colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFFF4C430),primary:const Color(0xFF171717))),home:const HomePage());
}
class ZeActionButton extends StatelessWidget{
 final String label; final IconData icon; final VoidCallback? onPressed;
 const ZeActionButton({super.key,required this.label,required this.icon,required this.onPressed});
 @override Widget build(BuildContext context)=>Material(color:Colors.transparent,child:InkWell(onTap:onPressed,borderRadius:BorderRadius.circular(16),child:Ink(decoration:BoxDecoration(color:onPressed==null?const Color(0xFFBDB7AA):const Color(0xFFF4C430),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFF171717),width:2)),child:Container(height:62,padding:const EdgeInsets.symmetric(horizontal:18),child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon),const SizedBox(width:10),Flexible(child:Text(label,textAlign:TextAlign.center,style:const TextStyle(fontSize:14,fontWeight:FontWeight.w900,letterSpacing:1.1)))])))));
}
class HomePage extends StatefulWidget{const HomePage({super.key});@override State<HomePage> createState()=>_HomePageState();}
class _HomePageState extends State<HomePage>{
 bool online=false,busy=false; Map<String,dynamic>? offer; String? deliveryStatus; final name=TextEditingController(text:'Zé Entregador');
 @override void dispose(){name.dispose();super.dispose();}
 Future<void> toggle()async{setState(()=>online=!online);if(online)await loadOffer();else setState(()=>offer=null);}
 Future<void> loadOffer()async{if(!online)return;try{final data=await Supabase.instance.client.rpc('get_ready_delivery_offer');final rows=data as List;if(mounted)setState(()=>offer=rows.isEmpty?null:Map<String,dynamic>.from(rows.first as Map));}catch(_){if(mounted)setState(()=>offer=null);}}
 Future<void> accept()async{if(offer==null)return;setState(()=>busy=true);try{await Supabase.instance.client.rpc('driver_accept_delivery',params:{'p_order_id':offer!['order_id'],'p_driver_name':name.text.trim()});if(mounted)setState(()=>deliveryStatus='accepted');}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Esta entrega não está mais disponível.')));}finally{if(mounted)setState(()=>busy=false);}}
 Future<void> advance()async{if(offer==null||deliveryStatus==null)return;final next=deliveryStatus=='accepted'?'picked_up':deliveryStatus=='picked_up'?'delivered':null;if(next==null)return;setState(()=>busy=true);try{await Supabase.instance.client.rpc('driver_advance_delivery',params:{'p_order_id':offer!['order_id'],'p_status':next});if(mounted)setState(()=>deliveryStatus=next);}finally{if(mounted)setState(()=>busy=false);}}
 @override Widget build(BuildContext context){
  final store=offer?['store_name']?.toString()??'';
  final customer=offer?['customer_name']?.toString()??'';
  final address=offer?['delivery_address']?.toString()??'';
  final id=offer?['order_id']?.toString()??'';
  final short=id.length>8?id.substring(0,8).toUpperCase():id.toUpperCase();
  final action=deliveryStatus==null?'ACEITAR ENTREGA':deliveryStatus=='accepted'?'RETIREI O PEDIDO':deliveryStatus=='picked_up'?'CONFIRMAR ENTREGA':'ENTREGA CONCLUÍDA';
  return Scaffold(appBar:AppBar(backgroundColor:const Color(0xFF171717),foregroundColor:Colors.white,title:const Row(children:[CircleAvatar(backgroundColor:Color(0xFFF4C430),child:Icon(Icons.sports_motorsports,color:Color(0xFF171717))),SizedBox(width:12),Text('Zé Entregador',style:TextStyle(fontWeight:FontWeight.w900))])),body:SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
   const Text('Zé Capão • Entregador',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const SizedBox(height:16),
   Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:online?const Color(0xFFF4C430):const Color(0xFF171717),borderRadius:BorderRadius.circular(26)),child:Column(children:[Icon(online?Icons.delivery_dining:Icons.power_settings_new,size:54,color:online?const Color(0xFF171717):const Color(0xFFF4C430)),Text(online?'ONLINE':'OFFLINE',style:TextStyle(color:online?const Color(0xFF171717):Colors.white,fontSize:23,fontWeight:FontWeight.w900)),const SizedBox(height:10),ZeActionButton(label:online?'ENCERRAR TURNO':'INICIAR TURNO',icon:online?Icons.pause_circle:Icons.play_circle,onPressed:toggle)])),
   if(online)...[const SizedBox(height:14),TextField(controller:name,decoration:const InputDecoration(labelText:'Nome do entregador',border:OutlineInputBorder())),const SizedBox(height:14),
    if(offer==null)Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(children:[const Text('Nenhuma entrega disponível agora.',style:TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:10),TextButton.icon(onPressed:loadOffer,icon:const Icon(Icons.refresh),label:const Text('ATUALIZAR'))])))
    else Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:const Color(0xFF171717),borderRadius:BorderRadius.circular(26)),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text(deliveryStatus==null?'NOVA ENTREGA':'ENTREGA #$short',style:const TextStyle(color:Color(0xFFF4C430),fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:10),
      Text('$store\nCliente: $customer\nDestino: $address',style:const TextStyle(color:Colors.white,fontSize:16,height:1.5)),const SizedBox(height:12),
      Text('Você recebe a partir de ${money(driverFare(2))}',style:const TextStyle(color:Colors.white70)),const SizedBox(height:16),
      ZeActionButton(label:busy?'AGUARDE...':action,icon:deliveryStatus=='picked_up'?Icons.check_circle:Icons.navigation_rounded,onPressed:busy||deliveryStatus=='delivered'?null:(deliveryStatus==null?accept:advance))
    ]))
   ],const SizedBox(height:18),const Text('Fluxo real conectado ao Zé Parceiro',textAlign:TextAlign.center,style:TextStyle(color:Colors.black45))
  ])));
 }
}
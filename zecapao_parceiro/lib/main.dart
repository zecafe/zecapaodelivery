import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const supabaseUrl='https://yovjbqtazkreruvxoawf.supabase.co';
const supabasePublishableKey='sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor';
Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await Supabase.initialize(url:supabaseUrl,publishableKey:supabasePublishableKey); runApp(const ZeParceiro()); }
const y=Color(0xFFF4C430), dark=Color(0xFF171717), cream=Color(0xFFF6F0E4);
class ZeParceiro extends StatelessWidget{const ZeParceiro({super.key});@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Zé Parceiro',theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:cream,colorScheme:ColorScheme.fromSeed(seedColor:y,primary:dark)),home:const Home());}
class Home extends StatefulWidget{const Home({super.key});@override State<Home> createState()=>_Home();}
class _Home extends State<Home>{
bool pending=true; int tab=0; RealtimeChannel? channel;
 @override void initState(){super.initState();_listenOrders();}
 void _listenOrders(){channel=Supabase.instance.client.channel('ze-parceiro-orders').onPostgresChanges(event:PostgresChangeEvent.insert,schema:'public',table:'orders',callback:(payload){if(mounted)setState(()=>pending=true);}).subscribe();}
 @override void dispose(){if(channel!=null)Supabase.instance.client.removeChannel(channel!);super.dispose();}
 void decide(bool accept){setState(()=>pending=false);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(accept?'Pedido aceito • preparar agora':'Pedido recusado')));}
 Widget operation()=>ListView(padding:const EdgeInsets.all(18),children:[
  const Text('Operação',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),const Text('Zé Parceiro • Vale do Capão',style:TextStyle(color:Colors.black54)),const SizedBox(height:18),
  if(pending) Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:dark,borderRadius:BorderRadius.circular(28)),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
   const Row(children:[Icon(Icons.notifications_active,color:y),SizedBox(width:10),Text('NOVO PEDIDO',style:TextStyle(color:y,fontWeight:FontWeight.w900,letterSpacing:1.3))]),const SizedBox(height:14),
   const Text('#1042 • Zecafé da Vila',style:TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.w900)),
   const Text('2 itens • R\$ 47,00 • Pix',style:TextStyle(color:Colors.white70)),const SizedBox(height:8),
   const Text('TUM-TIM  •  “Zé chegou!”',style:TextStyle(color:y,fontWeight:FontWeight.bold)),const SizedBox(height:20),
   FilledButton(style:FilledButton.styleFrom(backgroundColor:y,foregroundColor:dark,minimumSize:const Size.fromHeight(58)),onPressed:()=>decide(true),child:const Text('ACEITAR PEDIDO',style:TextStyle(fontWeight:FontWeight.w900))),
   const SizedBox(height:8),OutlinedButton(style:OutlinedButton.styleFrom(foregroundColor:Colors.white,side:const BorderSide(color:Colors.white30),minimumSize:const Size.fromHeight(52)),onPressed:()=>decide(false),child:const Text('RECUSAR')),
  ]) else const Card(child:Padding(padding:EdgeInsets.all(24),child:Column(children:[Icon(Icons.check_circle,size:48,color:Colors.green),SizedBox(height:10),Text('Nenhum pedido aguardando decisão',style:TextStyle(fontWeight:FontWeight.w800))]))),
  const SizedBox(height:18),const Row(children:[Expanded(child:Stat('0','Em preparo')),SizedBox(width:10),Expanded(child:Stat('0','Prontos'))]),
 ]);
 Widget management()=>ListView(padding:const EdgeInsets.all(18),children:[const Text('Gestão',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),const SizedBox(height:18),const Card(child:ListTile(leading:CircleAvatar(backgroundColor:y,child:Icon(Icons.calculate,color:dark)),title:Text('CMV e fichas técnicas',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Insumos, custos, margem e preço ideal'),trailing:Icon(Icons.chevron_right))),const Card(child:ListTile(leading:CircleAvatar(backgroundColor:y,child:Icon(Icons.inventory_2,color:dark)),title:Text('Estoque',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Entradas, consumo e alertas'),trailing:Icon(Icons.chevron_right)))]);
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(backgroundColor:dark,foregroundColor:Colors.white,title:const Row(children:[CircleAvatar(backgroundColor:y,child:Icon(Icons.storefront,color:dark)),SizedBox(width:10),Text('Zé Parceiro',style:TextStyle(fontWeight:FontWeight.w900))])),body:SafeArea(child:tab==0?operation():management()),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const[NavigationDestination(icon:Icon(Icons.receipt_long),label:'Pedidos'),NavigationDestination(icon:Icon(Icons.analytics_outlined),label:'Gestão')]));
}}
class Stat extends StatelessWidget{final String n,l;const Stat(this.n,this.l,{super.key});@override Widget build(BuildContext c)=>Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(children:[Text(n,style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900)),Text(l)])));}

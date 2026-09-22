import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const supabaseUrl='https://yovjbqtazkreruvxoawf.supabase.co';
const supabasePublishableKey='sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor';
Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await Supabase.initialize(url:supabaseUrl,publishableKey:supabasePublishableKey); runApp(const ZeParceiro()); }
const y=Color(0xFFF4C430), dark=Color(0xFF171717), cream=Color(0xFFF6F0E4);
class ZeParceiro extends StatelessWidget{const ZeParceiro({super.key});@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Zé Parceiro',theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:cream,colorScheme:ColorScheme.fromSeed(seedColor:y,primary:dark)),home:const AuthGate());}
class AuthGate extends StatefulWidget{const AuthGate({super.key});@override State<AuthGate> createState()=>_AuthGate();}
class _AuthGate extends State<AuthGate>{late final Stream<AuthState> auth;@override void initState(){super.initState();auth=Supabase.instance.client.auth.onAuthStateChange;}@override Widget build(BuildContext c)=>StreamBuilder<AuthState>(stream:auth,builder:(c,s)=>Supabase.instance.client.auth.currentUser==null?const LoginPage():const Home());}
class LoginPage extends StatefulWidget{const LoginPage({super.key});@override State<LoginPage> createState()=>_LoginPage();}
class _LoginPage extends State<LoginPage>{final email=TextEditingController(text:'jcasjunior@hotmail.com'),password=TextEditingController();bool busy=false;String? error;@override void dispose(){email.dispose();password.dispose();super.dispose();}Future<void> login()async{setState((){busy=true;error=null;});try{await Supabase.instance.client.auth.signInWithPassword(email:email.text.trim(),password:password.text);if(mounted)setState(()=>busy=false);}on AuthException catch(e){if(mounted)setState((){busy=false;error=e.message;});}catch(_){if(mounted)setState((){busy=false;error='Não foi possível entrar agora.';});}}@override Widget build(BuildContext c)=>Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:460),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const CircleAvatar(radius:34,backgroundColor:y,child:Icon(Icons.storefront,color:dark,size:34)),const SizedBox(height:20),const Text('Zé Parceiro',textAlign:TextAlign.center,style:TextStyle(fontSize:32,fontWeight:FontWeight.w900)),const SizedBox(height:6),const Text('Entre com a conta vinculada ao seu estabelecimento.',textAlign:TextAlign.center),const SizedBox(height:26),TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'E-mail',border:OutlineInputBorder())),const SizedBox(height:12),TextField(controller:password,obscureText:true,onSubmitted:(_){if(!busy)login();},decoration:const InputDecoration(labelText:'Senha',border:OutlineInputBorder())),if(error!=null)...[const SizedBox(height:10),Text(error!,style:const TextStyle(color:Colors.red,fontWeight:FontWeight.w700))],const SizedBox(height:16),ZePartnerButton(label:busy?'ENTRANDO...':'ENTRAR',icon:Icons.login_rounded,onTap:busy?null:login)]))))));}}

class ZePartnerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool danger;
  const ZePartnerButton({super.key,required this.label,required this.icon,required this.onTap,this.danger=false});
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button:true,
      enabled:onTap!=null,
      label:label,
      child:Material(
        color:Colors.transparent,
        child:InkWell(
          onTap:onTap,
          borderRadius:BorderRadius.circular(16),
          child:Ink(
            height:60,
            decoration:BoxDecoration(
              color:danger?Colors.transparent:y,
              borderRadius:BorderRadius.circular(16),
              border:Border.all(color:danger?Colors.white54:dark,width:2),
            ),
            child:Row(
              mainAxisAlignment:MainAxisAlignment.center,
              children:[
                Icon(icon,color:danger?Colors.white:dark),
                const SizedBox(width:10),
                Text(label,style:TextStyle(color:danger?Colors.white:dark,fontWeight:FontWeight.w900,letterSpacing:1.1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class Home extends StatefulWidget{const Home({super.key});@override State<Home> createState()=>_Home();}
class _Home extends State<Home>{
bool pending=false,loading=true; int tab=0; String? accessError; RealtimeChannel? channel; Map<String,dynamic>? order; String? storeId,storeName;
 @override void initState(){super.initState();_boot();}
 Future<void> _boot()async{final sb=Supabase.instance.client;final user=sb.auth.currentUser;if(user==null){if(mounted)setState(()=>loading=false);return;}final member=await sb.from('store_members').select('store_id,stores(name)').eq('user_id',user.id).limit(1).maybeSingle();storeId=member?['store_id']?.toString();storeName=(member?['stores'] as Map?)?['name']?.toString();if(storeId!=null){await _loadPending();_listenOrders();}else{accessError='Esta conta ainda não está vinculada a um estabelecimento.';}if(mounted)setState(()=>loading=false);}
 Future<void> _loadPending()async{if(storeId==null)return;final data=await Supabase.instance.client.from('orders').select('*,order_items(*)').eq('store_id',storeId!).eq('status','pending').order('created_at').limit(1).maybeSingle();if(mounted)setState((){order=data;pending=data!=null;});}
 void _listenOrders(){channel=Supabase.instance.client.channel('ze-parceiro-$storeId').onPostgresChanges(event:PostgresChangeEvent.all,schema:'public',table:'orders',filter:PostgresChangeFilter(type:PostgresChangeFilterType.eq,column:'store_id',value:storeId!),callback:(payload)=>_loadPending()).subscribe();}
 @override void dispose(){if(channel!=null)Supabase.instance.client.removeChannel(channel!);super.dispose();}
 Future<void> decide(bool accept)async{if(order==null)return;final status=accept?'accepted':'cancelled';final id=order!['id'];final result=await Supabase.instance.client.from('orders').update({'status':status,'updated_at':DateTime.now().toIso8601String()}).eq('id',id).select();if(!mounted)return;if(result.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Não foi possível atualizar o pedido')));return;}setState((){pending=false;order=null;});ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(accept?'Pedido aceito • preparar agora':'Pedido recusado')));await _loadPending();}
 Widget operation() {
  final items=(order?['order_items'] as List?)??const [];
  final rawId=order?['id']?.toString()??'PEDIDO';
  final shortId=rawId.length>8?rawId.substring(0,8):rawId;
  final total=((order?['total'] as num?)??0).toStringAsFixed(2).replaceAll('.',',');
  final payment=order?['payment_method']?.toString()??'';
  return ListView(
   padding:const EdgeInsets.all(18),
   children:[
    const Text('Operação',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),
    Text(storeName!=null?'$storeName • Vale do Capão':'Zé Parceiro • Vale do Capão',style:const TextStyle(color:Colors.black54)),
    if(accessError!=null)...[const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(16),child:Text(accessError!,style:const TextStyle(fontWeight:FontWeight.w800))))],
    const SizedBox(height:18),
    if(pending)
     Container(
      padding:const EdgeInsets.all(22),
      decoration:BoxDecoration(color:dark,borderRadius:BorderRadius.circular(28)),
      child:Column(
       crossAxisAlignment:CrossAxisAlignment.stretch,
       children:[
        const Row(children:[
         Icon(Icons.notifications_active,color:y),
         SizedBox(width:10),
         Text('NOVO PEDIDO',style:TextStyle(color:y,fontWeight:FontWeight.w900,letterSpacing:1.3)),
        ]),
        const SizedBox(height:14),
        Text('#${shortId.toUpperCase()} • ${storeName??'Minha loja'}',style:const TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.w900)),
        Text('${items.length} itens • R\$ $total • $payment',style:const TextStyle(color:Colors.white70)),
        const SizedBox(height:8),
        const Text('TUM-TIM  •  “Zé chegou!”',style:TextStyle(color:y,fontWeight:FontWeight.bold)),
        const SizedBox(height:20),
        ZePartnerButton(label:'ACEITAR PEDIDO',icon:Icons.check_circle_rounded,onTap:()=>decide(true)),
        const SizedBox(height:8),
        ZePartnerButton(label:'RECUSAR',icon:Icons.close_rounded,onTap:()=>decide(false),danger:true),
       ],
      ),
     )
    else
     const Card(child:Padding(padding:EdgeInsets.all(24),child:Column(children:[
      Icon(Icons.check_circle,size:48,color:Colors.green),
      SizedBox(height:10),
      Text('Nenhum pedido aguardando decisão',style:TextStyle(fontWeight:FontWeight.w800)),
     ]))),
    const SizedBox(height:18),
    const Row(children:[
     Expanded(child:Stat('0','Em preparo')),
     SizedBox(width:10),
     Expanded(child:Stat('0','Prontos')),
    ]),
   ],
  );
 }

 Widget management()=>ListView(padding:const EdgeInsets.all(18),children:[const Text('Gestão',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),const SizedBox(height:18),const Card(child:ListTile(leading:CircleAvatar(backgroundColor:y,child:Icon(Icons.calculate,color:dark)),title:Text('CMV e fichas técnicas',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Insumos, custos, margem e preço ideal'),trailing:Icon(Icons.chevron_right))),const Card(child:ListTile(leading:CircleAvatar(backgroundColor:y,child:Icon(Icons.inventory_2,color:dark)),title:Text('Estoque',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Entradas, consumo e alertas'),trailing:Icon(Icons.chevron_right)))]);
 @override Widget build(BuildContext c){if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));return Scaffold(appBar:AppBar(backgroundColor:dark,foregroundColor:Colors.white,title:const Row(children:[CircleAvatar(backgroundColor:y,child:Icon(Icons.storefront,color:dark)),SizedBox(width:10),Text('Zé Parceiro',style:TextStyle(fontWeight:FontWeight.w900))])),body:SafeArea(child:tab==0?operation():management()),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const[NavigationDestination(icon:Icon(Icons.receipt_long),label:'Pedidos'),NavigationDestination(icon:Icon(Icons.analytics_outlined),label:'Gestão')]));}
}
class Stat extends StatelessWidget {
  final String n;
  final String l;
  const Stat(this.n, this.l, {super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(n, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            Text(l),
          ],
        ),
      ),
    );
  }
}

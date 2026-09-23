import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
const supabaseUrl='https://yovjbqtazkreruvxoawf.supabase.co';
const supabasePublishableKey='sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor';
Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await Supabase.initialize(url:supabaseUrl,publishableKey:supabasePublishableKey); runApp(const ZeParceiro()); }
const y=Color(0xFFF4C430), dark=Color(0xFF171717), cream=Color(0xFFF6F0E4);
class ZeParceiro extends StatelessWidget{const ZeParceiro({super.key});@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Zé Parceiro',theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:cream,colorScheme:ColorScheme.fromSeed(seedColor:y,primary:dark)),home:const AuthGate());}
class AuthGate extends StatefulWidget{const AuthGate({super.key});@override State<AuthGate> createState()=>_AuthGate();}
class _AuthGate extends State<AuthGate> {
  late final Stream<AuthState> auth;
  bool recovery = false;

  @override
  void initState() {
    super.initState();
    auth = Supabase.instance.client.auth.onAuthStateChange;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: auth,
      builder: (context, snapshot) {
        final event = snapshot.data?.event;
        if (event == AuthChangeEvent.passwordRecovery) recovery = true;
        if (recovery) return ResetPasswordPage(onDone: () => setState(() => recovery = false));
        return Supabase.instance.client.auth.currentUser == null
            ? const LoginPage()
            : const Home();
      },
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  final VoidCallback onDone;
  const ResetPasswordPage({super.key, required this.onDone});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (password.text.length < 6) {
      setState(() => error = 'Use uma senha com pelo menos 6 caracteres.');
      return;
    }
    if (password.text != confirm.text) {
      setState(() => error = 'As senhas não são iguais.');
      return;
    }
    setState(() { busy = true; error = null; });
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password.text),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso.')),
      );
      widget.onDone();
    } on AuthException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(radius: 34, backgroundColor: y, child: Icon(Icons.lock_reset, color: dark, size: 34)),
                const SizedBox(height: 20),
                const Text('Criar nova senha', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('Digite a nova senha do Zé Parceiro.', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Nova senha', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirmar nova senha', border: OutlineInputBorder())),
                if (error != null) ...[const SizedBox(height: 10), Text(error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700))],
                const SizedBox(height: 16),
                ZePartnerButton(label: busy ? 'SALVANDO...' : 'SALVAR NOVA SENHA', icon: Icons.check_circle_rounded, onTap: busy ? null : save),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final email = TextEditingController(text: 'jcasjunior@hotmail.com');
  final password = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> firstAccess() async {
    final address = email.text.trim();
    final pass = password.text;
    if (address.isEmpty || pass.length < 6) {
      setState(() => error = 'Informe o e-mail e escolha uma senha com pelo menos 6 caracteres.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: address,
        password: pass,
        emailRedirectTo: 'zecapao-parceiro://login-callback/',
      );
      if (!mounted) return;
      if (response.session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada. Primeiro acesso concluído.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada. Confira seu e-mail para confirmar o cadastro.')),
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'Não foi possível criar o acesso agora.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resetPassword() async {
    final address = email.text.trim();
    if (address.isEmpty) {
      setState(() => error = 'Informe seu e-mail primeiro.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        address,
        redirectTo: 'zecapao-parceiro://login-callback/',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enviamos o acesso para seu e-mail. Confira também o spam.')),
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'Não foi possível enviar o acesso agora.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> login() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'Não foi possível entrar agora.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: y,
                    child: Icon(Icons.storefront, color: dark, size: 34),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Zé Parceiro',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Entre com a conta vinculada ao seu estabelecimento.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ZePartnerButton(
                    label: busy ? 'ENTRANDO...' : 'ENTRAR',
                    icon: Icons.login_rounded,
                    onTap: busy ? null : login,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: busy ? null : firstAccess,
                    child: const Text('PRIMEIRO ACESSO'),
                  ),
                  TextButton(
                    onPressed: busy ? null : resetPassword,
                    child: const Text('ESQUECI MINHA SENHA'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
bool pending=false,loading=true; int tab=0; String? accessError; RealtimeChannel? channel; Timer? syncTimer; Map<String,dynamic>? order; List<Map<String,dynamic>> activeOrders=[]; Map<String,Map<String,dynamic>> deliveryStates={}; String? storeId,storeName;
 @override void initState(){super.initState();_boot();}
 Future<void> _boot() async {
  final sb = Supabase.instance.client;
  final user = sb.auth.currentUser;
  if (user == null) {
    if (mounted) setState(() => loading = false);
    return;
  }
  try {
    var member = await sb.from('store_members').select('store_id,stores(name)').eq('user_id', user.id).limit(1).maybeSingle();
    if (member == null) {
      try {
        await sb.rpc('claim_zecafe_partner');
        member = await sb.from('store_members').select('store_id,stores(name)').eq('user_id', user.id).limit(1).maybeSingle();
      } catch (_) {}
    }
    storeId = member?['store_id']?.toString();
    storeName = (member?['stores'] as Map?)?['name']?.toString();
    if (storeId != null) {
      await _loadPending();
      await _loadActive();
      await _loadDeliveryStates();
      _listenOrders();
      syncTimer?.cancel();
      syncTimer=Timer.periodic(const Duration(seconds:3),(_){_syncOperation();});
    } else {
      accessError = 'Esta conta ainda não está vinculada a um estabelecimento.';
    }
  } catch (_) {
    accessError = 'Não foi possível carregar o estabelecimento. Entre novamente.';
  }
  if (mounted) setState(() => loading = false);
}
 Future<void> _loadPending()async{if(storeId==null)return;final data=await Supabase.instance.client.from('orders').select('*,order_items(*)').eq('store_id',storeId!).eq('status','pending').order('created_at').limit(1).maybeSingle();if(mounted)setState((){order=data;pending=data!=null;});}
 Future<void> _loadActive() async { if(storeId==null)return; final data=await Supabase.instance.client.from('orders').select('*,order_items(*)').eq('store_id',storeId!).inFilter('status',['accepted','preparing','ready','out_for_delivery','delivered']).order('created_at'); if(mounted)setState(()=>activeOrders=List<Map<String,dynamic>>.from(data)); }
 Future<void> _loadDeliveryStates() async { if(storeId==null)return; try { final data=await Supabase.instance.client.rpc('get_partner_delivery_state',params:{'p_store_id':storeId}); final map=<String,Map<String,dynamic>>{}; for(final raw in (data as List)){final row=Map<String,dynamic>.from(raw as Map);map[row['order_id'].toString()]=row;} if(mounted)setState(()=>deliveryStates=map); } catch(_){} }
 Future<void> _syncOperation() async { if(storeId==null)return; try{await Future.wait([_loadPending(),_loadActive(),_loadDeliveryStates()]);}catch(_){} }
 Future<void> advanceOrder(Map<String,dynamic> item) async { final current=item['status']?.toString(); final next=current=='accepted'?'preparing':current=='preparing'?'ready':null; if(next==null)return; try { await Supabase.instance.client.rpc('partner_update_order_status',params:{'p_order_id':item['id'],'p_status':next}); await _loadActive(); } catch(_) { if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Não foi possível avançar o pedido'))); } }
 void _listenOrders(){channel=Supabase.instance.client.channel('ze-parceiro-$storeId').onPostgresChanges(event:PostgresChangeEvent.all,schema:'public',table:'orders',filter:PostgresChangeFilter(type:PostgresChangeFilterType.eq,column:'store_id',value:storeId!),callback:(payload){_loadPending();_loadActive();_loadDeliveryStates();}).subscribe();}
 @override void dispose(){syncTimer?.cancel();if(channel!=null)Supabase.instance.client.removeChannel(channel!);super.dispose();}
 Future<void> decide(bool accept) async { if(order==null)return; final status=accept?'accepted':'cancelled'; final id=order!['id']; try { await Supabase.instance.client.rpc('partner_update_order_status',params:{'p_order_id':id,'p_status':status}); if(!mounted)return; setState((){pending=false;order=null;}); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(accept?'Pedido aceito • preparar agora':'Pedido recusado'))); await _loadPending(); await _loadActive(); } catch(e) { if(!mounted)return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Não foi possível atualizar o pedido'))); } }
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
    Row(children:[
     Expanded(child:Stat(activeOrders.where((o)=>o['status']=='accepted'||o['status']=='preparing').length.toString(),'Em preparo')),
     const SizedBox(width:10),
     Expanded(child:Stat(activeOrders.where((o)=>o['status']=='ready').length.toString(),'Prontos')),
    ]),
    const SizedBox(height:16),
    ...activeOrders.map((o){
      final id=o['id']?.toString()??'';
      final short=id.length>8?id.substring(0,8).toUpperCase():id.toUpperCase();
      final status=o['status']?.toString()??'';
      final delivery=deliveryStates[id];
      final dStatus=delivery?['delivery_status']?.toString();
      final driver=delivery?['driver_name']?.toString();
      final label=dStatus=='delivered'?'PEDIDO CONCLUÍDO':dStatus=='picked_up'?'SAIU PARA ENTREGA':dStatus=='accepted'?'ENTREGADOR A CAMINHO':status=='accepted'?'INICIAR PREPARO':status=='preparing'?'MARCAR COMO PRONTO':'AGUARDANDO ENTREGADOR';
      return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Text('#$short',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),
        const SizedBox(height:4),
        Text(dStatus=='delivered'?'Entregue por $driver':dStatus=='picked_up'?'$driver • em entrega':dStatus=='accepted'?'$driver • a caminho do Zecafé':status=='accepted'?'Pedido aceito':status=='preparing'?'Em preparo':'Pronto para entrega',style:const TextStyle(fontWeight:FontWeight.w700)),
        const SizedBox(height:12),
        ZePartnerButton(label:label,icon:status=='ready'?Icons.delivery_dining:Icons.restaurant,onTap:(status=='ready'||status=='out_for_delivery'||status=='delivered')?null:()=>advanceOrder(o)),
      ])));
    }),
   ],
  );
 }

 Widget management()=>ListView(padding:const EdgeInsets.all(18),children:[const Text('Gestão',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),const SizedBox(height:18),const Card(child:ListTile(leading:CircleAvatar(backgroundColor:y,child:Icon(Icons.calculate,color:dark)),title:Text('CMV e fichas técnicas',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Insumos, custos, margem e preço ideal'),trailing:Icon(Icons.chevron_right))),const Card(child:ListTile(leading:CircleAvatar(backgroundColor:y,child:Icon(Icons.inventory_2,color:dark)),title:Text('Estoque',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Entradas, consumo e alertas'),trailing:Icon(Icons.chevron_right)))]);
 @override Widget build(BuildContext c){if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));return Scaffold(appBar:AppBar(backgroundColor:dark,foregroundColor:Colors.white,title:const Row(children:[CircleAvatar(backgroundColor:y,child:Icon(Icons.storefront,color:dark)),SizedBox(width:10),Text('Zé Parceiro',style:TextStyle(fontWeight:FontWeight.w900))]),actions:[IconButton(tooltip:'Sair',icon:const Icon(Icons.logout_rounded),onPressed:() async {await Supabase.instance.client.auth.signOut();})]),body:SafeArea(child:tab==0?operation():management()),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const[NavigationDestination(icon:Icon(Icons.receipt_long),label:'Pedidos'),NavigationDestination(icon:Icon(Icons.analytics_outlined),label:'Gestão')]));}
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

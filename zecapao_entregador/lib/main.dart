import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

const supabaseUrl='https://yovjbqtazkreruvxoawf.supabase.co';
const supabaseAnonKey='sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url:supabaseUrl,anonKey:supabaseAnonKey);
  runApp(const ZeEntregadorApp());
}
String money(num v)=>'R\$ ${v.toStringAsFixed(2).replaceAll('.',',')}';
double driverFare(double km,{double base=6,double includedKm=2,double extraPerKm=1.5})=>base+((km-includedKm).clamp(0,double.infinity)*extraPerKm);

class ZeEntregadorApp extends StatelessWidget{
 const ZeEntregadorApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Entregador Capão Delivery',theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:const Color(0xFFF3F5F2),colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFF16B96B),primary:const Color(0xFF171717))),home:const DriverGate());
}
class ZeActionButton extends StatelessWidget{
 final String label; final IconData icon; final VoidCallback? onPressed;
 const ZeActionButton({super.key,required this.label,required this.icon,required this.onPressed});
 @override Widget build(BuildContext context)=>Material(color:Colors.transparent,child:InkWell(onTap:onPressed,borderRadius:BorderRadius.circular(16),child:Ink(decoration:BoxDecoration(color:onPressed==null?const Color(0xFFBDB7AA):const Color(0xFF16B96B),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFF171717),width:2)),child:Container(height:62,padding:const EdgeInsets.symmetric(horizontal:18),child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon),const SizedBox(width:10),Flexible(child:Text(label,textAlign:TextAlign.center,style:const TextStyle(fontSize:14,fontWeight:FontWeight.w900,letterSpacing:1.1)))])))));
}
class DriverGate extends StatefulWidget {
  const DriverGate({super.key});
  @override State<DriverGate> createState() => _DriverGateState();
}
class _DriverGateState extends State<DriverGate> {
  final email = TextEditingController(), code = TextEditingController();
  bool loading = false, codeSent = false, showRegistration = false, approved = false;
  String? status, message;
  StreamSubscription<AuthState>? authSubscription;

  @override void initState() {
    super.initState();
    authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((_) => refreshAccess());
    refreshAccess();
  }
  @override void dispose() {
    authSubscription?.cancel();
    email.dispose(); code.dispose(); super.dispose();
  }
  Future<void> refreshAccess() async {
    if (!mounted) return;
    final client = Supabase.instance.client;
    if (client.auth.currentUser == null) {
      setState(() { approved = false; status = null; });
      return;
    }
    setState(() { loading = true; message = null; });
    try {
      // Server-side RPC must verify auth.uid() and matching verified email.
      final result = await client.rpc('driver_claim_and_status');
      final rows = result as List;
      final next = rows.isEmpty ? 'none' : rows.first['status'].toString();
      if (mounted) setState(() { status = next; approved = next == 'approved'; });
    } catch (_) {
      if (mounted) setState(() {
        approved = false;
        message = 'Não foi possível confirmar sua autorização. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
  Future<void> sendCode() async {
    if (!email.text.contains('@')) {
      setState(() => message = 'Informe seu e-mail cadastrado.');
      return;
    }
    setState(() { loading = true; message = null; });
    try {
      await Supabase.instance.client.auth.signInWithOtp(email: email.text.trim(), shouldCreateUser: true);
      if (mounted) setState(() { codeSent = true; message = 'Confira seu e-mail e informe o código recebido.'; });
    } catch (_) {
      if (mounted) setState(() => message = 'Não foi possível enviar o código. Tente novamente.');
    } finally { if (mounted) setState(() => loading = false); }
  }
  Future<void> verifyCode() async {
    if (code.text.trim().length != 6) {
      setState(() => message = 'Informe o código de seis dígitos.');
      return;
    }
    setState(() { loading = true; message = null; });
    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: email.text.trim(), token: code.text.trim(), type: OtpType.email,
      );
      await refreshAccess();
    } catch (_) {
      if (mounted) setState(() => message = 'Código inválido ou expirado. Solicite outro.');
    } finally { if (mounted) setState(() => loading = false); }
  }
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) setState(() { approved = false; status = null; codeSent = false; });
  }
  @override Widget build(BuildContext context) {
    if (approved) return HomePage(onSignOut: signOut);
    final signedIn = Supabase.instance.client.auth.currentUser != null;
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF171717), foregroundColor: Colors.white,
        title: const Text('Entregador Capão Delivery')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Capão Entregador', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        if (loading) const LinearProgressIndicator(),
        if (message != null) Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(message!)),
        if (signedIn) ...[
          Text(status == 'pending' ? 'Seu cadastro está em análise.' :
               status == 'blocked' || status == 'rejected' ? 'Seu cadastro precisa de revisão.' :
               status == 'none' ? 'Nenhum cadastro vinculado a este e-mail.' :
               'Verificando sua aprovação...'),
          const SizedBox(height: 16),
          ZeActionButton(label: 'ATUALIZAR SITUAÇÃO', icon: Icons.refresh, onPressed: loading ? null : refreshAccess),
          TextButton(onPressed: signOut, child: const Text('Sair da conta')),
        ] else if (showRegistration) ...[
          const Text('Quero ser entregador', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DriverApplicationForm(onSubmitted: (e, c) {
            email.text = e;
            setState(() { showRegistration = false; message = 'Cadastro enviado. Aguarde a aprovação e entre com seu e-mail.'; });
          }),
          TextButton(onPressed: () => setState(() => showRegistration = false), child: const Text('Já sou entregador')),
        ] else ...[
          const Text('Já sou entregador: entre com o e-mail utilizado no cadastro.'),
          const SizedBox(height: 16),
          TextField(controller: email, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail cadastrado', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          if (codeSent) ...[
            TextField(controller: code, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Código recebido por e-mail', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ZeActionButton(label: 'CONFIRMAR CÓDIGO', icon: Icons.verified_user, onPressed: loading ? null : verifyCode),
            TextButton(onPressed: loading ? null : sendCode, child: const Text('Reenviar código')),
          ] else ZeActionButton(label: 'RECEBER CÓDIGO', icon: Icons.mail_outline, onPressed: loading ? null : sendCode),
          const SizedBox(height: 16),
          TextButton(onPressed: () => setState(() => showRegistration = true), child: const Text('Quero ser entregador: fazer cadastro')),
        ],
      ]),
    );
  }
}
class DriverApplicationForm extends StatefulWidget{final void Function(String,String) onSubmitted;const DriverApplicationForm({super.key,required this.onSubmitted});@override State<DriverApplicationForm> createState()=>_DriverApplicationFormState();}
class _DriverApplicationFormState extends State<DriverApplicationForm>{
 final fullName=TextEditingController(),whats=TextEditingController(),email=TextEditingController(),cpf=TextEditingController(),birth=TextEditingController(),locality=TextEditingController(),plate=TextEditingController(),availability=TextEditingController(),pix=TextEditingController();String vehicle='moto';bool sending=false,terms=false;
 @override void dispose(){for(final x in [fullName,whats,email,cpf,birth,locality,plate,availability,pix]){x.dispose();}super.dispose();}
 Future<void> submit()async{if(!terms||[fullName,whats,email,cpf,birth,locality,pix].any((x)=>x.text.trim().isEmpty)){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Preencha os campos obrigatórios e aceite os termos.')));return;}final p=birth.text.trim().split('/');if(p.length!=3){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Use nascimento no formato DD/MM/AAAA.')));return;}final date=p[2]+'-'+p[1].padLeft(2,'0')+'-'+p[0].padLeft(2,'0');setState(()=>sending=true);try{await Supabase.instance.client.rpc('submit_driver_application',params:{'p_full_name':fullName.text.trim(),'p_whatsapp':whats.text.trim(),'p_email':email.text.trim(),'p_cpf':cpf.text.trim(),'p_birth_date':date,'p_locality':locality.text.trim(),'p_vehicle_type':vehicle,'p_vehicle_plate':plate.text.trim(),'p_availability':availability.text.trim(),'p_pix_key':pix.text.trim()});if(mounted)widget.onSubmitted(email.text.trim(),cpf.text.trim());}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Não foi possível enviar. Confira os dados ou se já existe cadastro com este CPF.')));}finally{if(mounted)setState(()=>sending=false);}}
 @override Widget build(BuildContext context)=>Column(children:[TextField(controller:fullName,decoration:const InputDecoration(labelText:'Nome completo *',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:whats,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'WhatsApp *',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'E-mail *',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:cpf,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'CPF *',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:birth,keyboardType:TextInputType.datetime,decoration:const InputDecoration(labelText:'Nascimento DD/MM/AAAA *',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:locality,decoration:const InputDecoration(labelText:'Cidade / localidade *',border:OutlineInputBorder())),const SizedBox(height:10),DropdownButtonFormField<String>(initialValue:vehicle,decoration:const InputDecoration(labelText:'Veículo',border:OutlineInputBorder()),items:const [DropdownMenuItem(value:'moto',child:Text('Moto')),DropdownMenuItem(value:'bicicleta',child:Text('Bicicleta')),DropdownMenuItem(value:'carro',child:Text('Carro')),DropdownMenuItem(value:'outro',child:Text('Outro'))],onChanged:(v)=>setState(()=>vehicle=v??'moto')),const SizedBox(height:10),TextField(controller:plate,decoration:const InputDecoration(labelText:'Placa, se aplicável',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:availability,decoration:const InputDecoration(labelText:'Disponibilidade',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:pix,decoration:const InputDecoration(labelText:'Chave Pix *',border:OutlineInputBorder())),CheckboxListTile(contentPadding:EdgeInsets.zero,value:terms,onChanged:(v)=>setState(()=>terms=v??false),title:const Text('Confirmo que os dados são verdadeiros e aceito os termos para entregadores.')),ZeActionButton(label:sending?'ENVIANDO...':'ENVIAR CADASTRO',icon:Icons.send_rounded,onPressed:sending?null:submit)]);
}
class HomePage extends StatefulWidget{final Future<void> Function() onSignOut;const HomePage({super.key,required this.onSignOut});@override State<HomePage> createState()=>_HomePageState();}
class _HomePageState extends State<HomePage>{
 bool online=false,busy=false,fetching=false; Map<String,dynamic>? offer; String? deliveryStatus; Timer? poller; final name=TextEditingController(text:'Zé Entregador');
 @override void dispose(){poller?.cancel();name.dispose();super.dispose();}
 Future<void> toggle()async{setState(()=>online=!online);poller?.cancel();if(online){await loadOffer();poller=Timer.periodic(const Duration(seconds:3),(_){if(online&&deliveryStatus==null)loadOffer();});}else{setState(()=>offer=null);}}
 Future<void> loadOffer() async {
  if(!online||fetching||deliveryStatus!=null)return;
  fetching=true;
  try{
   final data=await Supabase.instance.client.rpc('get_ready_delivery_offer');
   final rows=data as List;
   if(mounted&&deliveryStatus==null&&rows.isNotEmpty){
    final next=Map<String,dynamic>.from(rows.first as Map);
    if(offer?['order_id']!=next['order_id'])setState(()=>offer=next);
   } else if(mounted&&rows.isEmpty&&offer!=null&&deliveryStatus==null){
    setState(()=>offer=null);
   }
  }catch(_){
   // Falha temporaria de rede: preserva a oferta atual e tenta novamente.
  }finally{fetching=false;}
 }
 Future<void> openRoute() async { if(offer==null)return; final lat=offer!['latitude'];final lng=offer!['longitude'];Uri uri;if(lat!=null&&lng!=null){uri=Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');}else{final q=Uri.encodeComponent(offer!['delivery_address']?.toString()??'');uri=Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');}await launchUrl(uri,mode:LaunchMode.externalApplication); }
 Future<void> accept()async{if(offer==null)return;setState(()=>busy=true);try{await Supabase.instance.client.rpc('driver_accept_delivery',params:{'p_order_id':offer!['order_id'],'p_driver_name':name.text.trim()});poller?.cancel();if(mounted)setState(()=>deliveryStatus='accepted');}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Esta entrega não está mais disponível.')));}finally{if(mounted)setState(()=>busy=false);}}
 Future<void> advance()async{if(offer==null||deliveryStatus==null)return;final next=deliveryStatus=='accepted'?'picked_up':deliveryStatus=='picked_up'?'delivered':null;if(next==null)return;setState(()=>busy=true);try{await Supabase.instance.client.rpc('driver_advance_delivery',params:{'p_order_id':offer!['order_id'],'p_status':next});if(mounted)setState(()=>deliveryStatus=next);}finally{if(mounted)setState(()=>busy=false);}}
 @override Widget build(BuildContext context){
  final store=offer?['store_name']?.toString()??'';
  final customer=offer?['customer_name']?.toString()??'';
  final address=offer?['delivery_address']?.toString()??'';
  final id=offer?['order_id']?.toString()??'';
  final short=id.length>8?id.substring(0,8).toUpperCase():id.toUpperCase();
  final action=deliveryStatus==null?'ACEITAR ENTREGA':deliveryStatus=='accepted'?'RETIREI O PEDIDO':deliveryStatus=='picked_up'?'CONFIRMAR ENTREGA':'ENTREGA CONCLUÍDA';
  return Scaffold(appBar:AppBar(backgroundColor:const Color(0xFF171717),foregroundColor:Colors.white,title:const Row(children:[CircleAvatar(backgroundColor:Color(0xFFF4C430),child:Icon(Icons.sports_motorsports,color:Color(0xFF171717))),SizedBox(width:12),Text('Entregador Capão Delivery',style:TextStyle(fontWeight:FontWeight.w900,fontSize:16))])),body:SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
   const Text('Entregador Capão Delivery',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),TextButton.icon(onPressed:widget.onSignOut,icon:const Icon(Icons.logout),label:const Text('SAIR DA CONTA')),const SizedBox(height:16),
   Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:online?const Color(0xFF16B96B):const Color(0xFF171717),borderRadius:BorderRadius.circular(26)),child:Column(children:[Icon(online?Icons.delivery_dining:Icons.power_settings_new,size:54,color:online?const Color(0xFF171717):const Color(0xFF16B96B)),Text(online?'ONLINE':'OFFLINE',style:TextStyle(color:online?const Color(0xFF171717):Colors.white,fontSize:23,fontWeight:FontWeight.w900)),const SizedBox(height:10),ZeActionButton(label:online?'ENCERRAR TURNO':'INICIAR TURNO',icon:online?Icons.pause_circle:Icons.play_circle,onPressed:toggle)])),
   if(online)...[const SizedBox(height:14),TextField(controller:name,decoration:const InputDecoration(labelText:'Nome do entregador',border:OutlineInputBorder())),const SizedBox(height:14),
    if(offer==null)Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(children:[const Text('Nenhuma entrega disponível agora.',style:TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:10),TextButton.icon(onPressed:loadOffer,icon:const Icon(Icons.refresh),label:const Text('ATUALIZAR'))])))
    else Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:const Color(0xFF171717),borderRadius:BorderRadius.circular(26)),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text(deliveryStatus==null?'NOVA ENTREGA':'ENTREGA #$short',style:const TextStyle(color:Color(0xFFF4C430),fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:10),
      Text('$store\nCliente: $customer\nDestino: $address',style:const TextStyle(color:Colors.white,fontSize:16,height:1.5)),const SizedBox(height:10),
      OutlinedButton.icon(onPressed:openRoute,icon:const Icon(Icons.map_outlined),label:Text(offer?['latitude']!=null?'ABRIR ROTA NO MAPA':'LOCALIZAR ENDEREÇO'),style:OutlinedButton.styleFrom(foregroundColor:const Color(0xFF16B96B),side:const BorderSide(color:Color(0xFFF4C430)))),const SizedBox(height:12),
      Text('Você recebe a partir de ${money(driverFare(2))}',style:const TextStyle(color:Colors.white70)),const SizedBox(height:16),
      ZeActionButton(label:busy?'AGUARDE...':action,icon:deliveryStatus=='picked_up'?Icons.check_circle:Icons.navigation_rounded,onPressed:busy||deliveryStatus=='delivered'?null:(deliveryStatus==null?accept:advance))
    ]))
   ],const SizedBox(height:18),const Text('Fluxo real conectado ao Zé Parceiro',textAlign:TextAlign.center,style:TextStyle(color:Colors.black45))
  ])));
 }
}
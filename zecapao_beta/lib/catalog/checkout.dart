import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core.dart';
import 'location_picker.dart';
import 'pix_service.dart';

class CheckoutPage extends StatefulWidget {
  final Store store;
  final String customerName, phone;
  final Repo repo;
  final List<CartLine> items;

  const CheckoutPage({
    super.key,
    required this.store,
    required this.customerName,
    required this.phone,
    required this.repo,
    required this.items,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final address = TextEditingController();
  final notes = TextEditingController();
  final payerEmail = TextEditingController();
  String payment = 'pix';
  bool sending = false;
  bool useValeCoins = false;
  DeliveryPoint? deliveryPoint;
  late Future<ValeCoinRedemptionPreview> redemptionFuture;
  ValeCoinRedemptionPreview? redemption;

  double get subtotal => widget.items.fold(0, (s, i) => s + i.total);
  int get redeemCoins => useValeCoins ? (redemption?.maxRedeemableCoins ?? 0) : 0;
  double get valecoinDiscount => redeemCoins / 100;
  double get eligibleAfterRedemption => (subtotal - valecoinDiscount).clamp(0, double.infinity);
  double get total => subtotal + widget.store.deliveryFee - valecoinDiscount;
  int get expectedCoins => cashbackCoins(eligibleAfterRedemption);
  int get expectedPercent => (cashbackRate(eligibleAfterRedemption) * 100).round();

  @override
  void initState() {
    super.initState();
    redemptionFuture = widget.repo.valecoinRedemptionPreview(widget.phone, subtotal);
    redemptionFuture.then((v) {
      if (mounted) setState(() => redemption = v);
    });
  }

  @override
  void dispose() {
    address.dispose();
    notes.dispose();
    payerEmail.dispose();
    super.dispose();
  }

  Future<void> pickLocation() async {
    final point = await Navigator.push<DeliveryPoint>(
      context,
      MaterialPageRoute(builder: (_) => const DeliveryLocationPickerPage()),
    );
    if (point != null && mounted) setState(() => deliveryPoint = point);
  }

  bool validEmail(String value) {
    final v = value.trim();
    return v.contains('@') && v.contains('.') && v.length >= 5;
  }

  Future<void> sendOrder() async {
    if (address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o endereço, pousada ou referência.')));
      return;
    }
    if (deliveryPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marque também o ponto de entrega no mapa.')));
      return;
    }
    if (widget.phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe seu WhatsApp para acompanhar o pedido.')));
      return;
    }
    if (payment == 'pix' && !validEmail(payerEmail.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um e-mail válido para gerar o Pix.')));
      return;
    }

    setState(() => sending = true);
    try {
      final locationNote = 'GPS ${deliveryPoint!.label}${notes.text.trim().isEmpty ? '' : ' • ${notes.text.trim()}'}';
      final orderId = await widget.repo.createOrder(
        store: widget.store,
        name: widget.customerName,
        phone: widget.phone,
        address: address.text.trim(),
        payment: payment,
        notes: locationNote,
        items: widget.items,
        redeemCoins: redeemCoins,
      );

      if (!mounted) return;

      if (payment == 'pix') {
        final charge = await PixService().createCharge(
          orderId: orderId,
          amount: total,
          payerEmail: payerEmail.text,
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PixPaymentPage(
              orderId: orderId,
              charge: charge,
              repo: widget.repo,
              expectedCoins: expectedCoins,
              redeemedCoins: redeemCoins,
              amount: total,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingPage(
              orderId: orderId,
              repo: widget.repo,
              expectedCoins: expectedCoins,
              redeemedCoins: redeemCoins,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível concluir: $e')));
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Widget valeCoinBox() {
    return FutureBuilder<ValeCoinRedemptionPreview>(
      future: redemptionFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Consultando ValeCoins...')));
        }
        final p = snap.data ?? const ValeCoinRedemptionPreview(balanceCoins: 0, maxRedeemableCoins: 0, minimumRedeemCoins: 100);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(backgroundColor: yellow, child: Text('V', style: TextStyle(fontWeight: FontWeight.w900, color: green))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.canRedeem
                          ? 'Saldo ${p.balanceCoins} VC • use até ${p.maxRedeemableCoins} VC'
                          : p.balanceCoins > 0
                              ? 'Você tem ${p.balanceCoins} VC. Uso a partir de ${p.minimumRedeemCoins} VC.'
                              : 'Você ainda não tem ValeCoins disponíveis.',
                    ),
                  ),
                  if (p.canRedeem) Switch(value: useValeCoins, onChanged: (v) => setState(() => useValeCoins = v)),
                ],
              ),
              if (useValeCoins) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Desconto ValeCoin', style: TextStyle(fontWeight: FontWeight.w800)),
                    Text('- ${valecoinMoney(p.maxRedeemableCoins)}', style: const TextStyle(fontWeight: FontWeight.w900, color: green)),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar pedido', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Seu pedido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ...widget.items.map(
            (line) => Card(
              child: ListTile(
                title: Text('${line.quantity}× ${line.product.name}', style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: line.optionText.isEmpty ? null : Text(line.optionText),
                trailing: Text(money(line.total), style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          valeCoinBox(),
          const SizedBox(height: 10),
          ListTile(title: const Text('Subtotal'), trailing: Text(money(subtotal))),
          if (redeemCoins > 0) ListTile(title: const Text('ValeCoin'), trailing: Text('- ${valecoinMoney(redeemCoins)}', style: const TextStyle(color: green, fontWeight: FontWeight.w900))),
          ListTile(title: const Text('Entrega'), trailing: Text(money(widget.store.deliveryFee))),
          ListTile(title: const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), trailing: Text(money(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: green))),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: yellow, child: Text('V', style: TextStyle(fontWeight: FontWeight.w900, color: green))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Você ganha $expectedCoins ValeCoins', style: const TextStyle(fontWeight: FontWeight.w900)), Text('$expectedPercent% de volta • ${valecoinMoney(expectedCoins)} após a entrega', style: const TextStyle(fontSize: 12, color: Colors.black54))])),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Onde entregar?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 9),
          TextField(controller: address, decoration: const InputDecoration(labelText: 'Endereço / pousada / referência', prefixIcon: Icon(Icons.location_on_outlined))),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: pickLocation,
            icon: Icon(deliveryPoint == null ? Icons.map_outlined : Icons.check_circle_rounded),
            label: Padding(padding: const EdgeInsets.symmetric(vertical: 13), child: Text(deliveryPoint == null ? 'MARCAR PONTO NO MAPA' : 'LOCAL MARCADO • ALTERAR')),
          ),
          if (deliveryPoint != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Ponto GPS: ${deliveryPoint!.label}', style: const TextStyle(fontSize: 11, color: brandMuted), textAlign: TextAlign.center)),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: payment,
            decoration: const InputDecoration(labelText: 'Pagamento', prefixIcon: Icon(Icons.payments_outlined)),
            items: const [
              DropdownMenuItem(value: 'pix', child: Text('Pix Mercado Pago')),
              DropdownMenuItem(value: 'card', child: Text('Cartão na entrega')),
              DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
            ],
            onChanged: (v) => setState(() => payment = v ?? 'pix'),
          ),
          if (payment == 'pix') ...[
            const SizedBox(height: 12),
            TextField(
              controller: payerEmail,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'E-mail para o Pix', prefixIcon: Icon(Icons.email_outlined)),
            ),
          ],
          const SizedBox(height: 12),
          TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Observações para entrega')),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: sending ? null : sendOrder,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), backgroundColor: green),
            child: sending ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : Text(payment == 'pix' ? 'GERAR PIX E FINALIZAR' : 'ENVIAR PEDIDO', style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 10),
          const Text('ValeCoins não são sacáveis nem transferíveis. Cashback não inclui entrega.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black45)),
        ],
      ),
    );
  }
}

class PixPaymentPage extends StatelessWidget {
  final String orderId;
  final PixCharge charge;
  final Repo repo;
  final int expectedCoins, redeemedCoins;
  final double amount;

  const PixPaymentPage({
    super.key,
    required this.orderId,
    required this.charge,
    required this.repo,
    required this.expectedCoins,
    required this.redeemedCoins,
    required this.amount,
  });

  Uint8List? qrBytes() {
    if (charge.qrCodeBase64.isEmpty) return null;
    try {
      final raw = charge.qrCodeBase64.contains(',') ? charge.qrCodeBase64.split(',').last : charge.qrCodeBase64;
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = qrBytes();
    return Scaffold(
      appBar: AppBar(title: const Text('Pague com Pix')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Icon(Icons.pix_rounded, size: 56, color: green),
          const SizedBox(height: 10),
          Text(money(amount), textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Mercado Pago • válido por até 30 minutos', textAlign: TextAlign.center, style: TextStyle(color: brandMuted)),
          const SizedBox(height: 20),
          if (bytes != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                child: Image.memory(bytes, width: 240, height: 240, fit: BoxFit.contain),
              ),
            ),
          if (charge.qrCode.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Pix copia e cola', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Text(charge.qrCode, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: charge.qrCode));
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código Pix copiado.')));
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('COPIAR CÓDIGO PIX'),
            ),
          ],
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OrderTrackingPage(orderId: orderId, repo: repo, expectedCoins: expectedCoins, redeemedCoins: redeemedCoins),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('JÁ PAGUEI • ACOMPANHAR PEDIDO'),
          ),
          const SizedBox(height: 10),
          Text('Pedido #${orderId.substring(0, 8).toUpperCase()} • cobrança ${charge.mercadoPagoOrderId}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: brandMuted)),
        ],
      ),
    );
  }
}

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  final Repo repo;
  final int expectedCoins, redeemedCoins;
  const OrderTrackingPage({super.key, required this.orderId, required this.repo, required this.expectedCoins, required this.redeemedCoins});
  @override State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  Map<String, dynamic>? order;
  Timer? timer;
  bool loading = true;
  @override void initState(){super.initState();refresh();timer=Timer.periodic(const Duration(seconds:4),(_)=>refresh(silent:true));}
  @override void dispose(){timer?.cancel();super.dispose();}
  Future<void> refresh({bool silent=false})async{try{final next=await widget.repo.orderStatus(widget.orderId);if(!mounted)return;setState((){order=next;loading=false;});}catch(_){if(!silent&&mounted)setState(()=>loading=false);}}
  String label(String s)=>const {'pending':'Aguardando confirmação','accepted':'Pedido aceito','preparing':'Em preparo','ready':'Pronto','out_for_delivery':'Saiu para entrega','delivered':'Entregue','cancelled':'Cancelado'}[s]??s;
  @override Widget build(BuildContext context){final status='${order?['status']??'pending'}',credited=order?['cashback_cents']??0;final delivered=status=='delivered';return Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(26),child:Column(children:[CircleAvatar(radius:42,backgroundColor:status=='cancelled'?red:green,child:Icon(delivered?Icons.check:Icons.delivery_dining,size:42,color:Colors.white)),const SizedBox(height:18),Text('Pedido #${widget.orderId.substring(0,8).toUpperCase()}',style:const TextStyle(color:Colors.black54)),const SizedBox(height:8),if(loading)const CircularProgressIndicator(),if(!loading)Text(label(status),textAlign:TextAlign.center,style:const TextStyle(fontSize:27,fontWeight:FontWeight.w900)),const SizedBox(height:18),Container(width:double.infinity,padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:cream,borderRadius:BorderRadius.circular(20)),child:Column(children:[const Text('VALECOIN',style:TextStyle(fontSize:11,fontWeight:FontWeight.w900,color:green)),const SizedBox(height:6),Text(status=='cancelled'?'Pedido cancelado não gera ValeCoins.':delivered?'+$credited VC creditados!':'+${widget.expectedCoins} VC após a entrega',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:green))])),const SizedBox(height:18),OutlinedButton.icon(onPressed:refresh,icon:const Icon(Icons.refresh),label:const Text('ATUALIZAR AGORA')),const SizedBox(height:8),FilledButton(onPressed:()=>Navigator.popUntil(context,(r)=>r.isFirst),child:const Text('VOLTAR AO INÍCIO'))]))))));}
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'core.dart';

class CheckoutPage extends StatefulWidget {
  final Store store;
  final String customerName;
  final String phone;
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
  String payment = 'pix';
  bool sending = false;
  bool useValeCoins = false;
  late Future<ValeCoinRedemptionPreview> redemptionFuture;
  ValeCoinRedemptionPreview? redemption;

  double get subtotal => widget.items.fold(0, (sum, item) => sum + item.total);
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
    redemptionFuture.then((value) {
      if (mounted) setState(() => redemption = value);
    });
  }

  @override
  void dispose() {
    address.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> sendOrder() async {
    if (address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o endereço, pousada ou referência.')),
      );
      return;
    }

    if (widget.phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe seu WhatsApp para usar ValeCoins e acompanhar o pedido.')),
      );
      return;
    }

    setState(() => sending = true);
    try {
      final orderId = await widget.repo.createOrder(
        store: widget.store,
        name: widget.customerName,
        phone: widget.phone,
        address: address.text.trim(),
        payment: payment,
        notes: notes.text.trim(),
        items: widget.items,
        redeemCoins: redeemCoins,
      );

      if (!mounted) return;
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível enviar o pedido: $e')),
        );
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
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 12), Text('Consultando ValeCoins...')]),
            ),
          );
        }
        final p = snap.data ?? const ValeCoinRedemptionPreview(balanceCoins: 0, maxRedeemableCoins: 0, minimumRedeemCoins: 100);
        if (!p.canRedeem) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: yellow, child: Text('V', style: TextStyle(fontWeight: FontWeight.w900, color: green))),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    p.balanceCoins > 0
                        ? 'Você tem ${p.balanceCoins} VC. O uso começa a partir de ${p.minimumRedeemCoins} VC.'
                        : 'Você ainda não tem ValeCoins disponíveis para usar.',
                  ),
                ),
              ],
            ),
          );
        }

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('USAR VALECOINS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: green)),
                        Text('Saldo ${p.balanceCoins} VC • pode usar até ${p.maxRedeemableCoins} VC'),
                      ],
                    ),
                  ),
                  Switch(value: useValeCoins, onChanged: (value) => setState(() => useValeCoins = value)),
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
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Limite de 30% do subtotal. Créditos com vencimento mais próximo são usados primeiro.', style: TextStyle(fontSize: 11, color: Colors.black54)),
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
          if (redeemCoins > 0)
            ListTile(title: const Text('ValeCoin'), trailing: Text('- ${valecoinMoney(redeemCoins)}', style: const TextStyle(color: green, fontWeight: FontWeight.w900))),
          ListTile(title: const Text('Entrega'), trailing: Text(money(widget.store.deliveryFee))),
          ListTile(
            title: const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            trailing: Text(money(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: green)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: yellow, child: Text('V', style: TextStyle(fontWeight: FontWeight.w900, color: green))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Você ganha $expectedCoins ValeCoins', style: const TextStyle(fontWeight: FontWeight.w900)),
                      Text('$expectedPercent% de volta • ${valecoinMoney(expectedCoins)} após a entrega', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: address,
            decoration: const InputDecoration(labelText: 'Endereço / pousada / referência', prefixIcon: Icon(Icons.location_on_outlined)),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: payment,
            decoration: const InputDecoration(labelText: 'Pagamento', prefixIcon: Icon(Icons.payments_outlined)),
            items: const [
              DropdownMenuItem(value: 'pix', child: Text('Pix')),
              DropdownMenuItem(value: 'card', child: Text('Cartão na entrega')),
              DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
            ],
            onChanged: (value) => setState(() => payment = value ?? 'pix'),
          ),
          const SizedBox(height: 12),
          TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Observações')),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: sending ? null : sendOrder,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), backgroundColor: green),
            child: sending
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('ENVIAR PEDIDO', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 10),
          const Text(
            'ValeCoins não são sacáveis nem transferíveis. Cashback é calculado sobre produtos elegíveis após descontos e não inclui entrega.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  final Repo repo;
  final int expectedCoins;
  final int redeemedCoins;

  const OrderTrackingPage({
    super.key,
    required this.orderId,
    required this.repo,
    required this.expectedCoins,
    required this.redeemedCoins,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  Map<String, dynamic>? order;
  Timer? timer;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    refresh();
    timer = Timer.periodic(const Duration(seconds: 4), (_) => refresh(silent: true));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> refresh({bool silent = false}) async {
    try {
      final next = await widget.repo.orderStatus(widget.orderId);
      if (!mounted) return;
      setState(() {
        order = next;
        loading = false;
      });
    } catch (_) {
      if (!silent && mounted) setState(() => loading = false);
    }
  }

  String statusLabel(String status) {
    return const {
          'pending': 'Aguardando confirmação',
          'accepted': 'Pedido aceito',
          'preparing': 'Em preparo',
          'ready': 'Pronto',
          'out_for_delivery': 'Saiu para entrega',
          'delivered': 'Entregue',
          'cancelled': 'Cancelado',
        }[status] ??
        status;
  }

  @override
  Widget build(BuildContext context) {
    final status = '${order?['status'] ?? 'pending'}';
    final creditedCoins = order?['cashback_cents'] ?? 0;
    final delivered = status == 'delivered';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: status == 'cancelled' ? red : green,
                  child: Icon(delivered ? Icons.check : Icons.delivery_dining, size: 42, color: Colors.white),
                ),
                const SizedBox(height: 18),
                Text('Pedido #${widget.orderId.substring(0, 8).toUpperCase()}', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                if (loading) const CircularProgressIndicator(),
                if (!loading)
                  Text(statusLabel(status), textAlign: TextAlign.center, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                if (widget.redeemedCoins > 0) ...[
                  Text('${widget.redeemedCoins} VC usados neste pedido', style: const TextStyle(fontWeight: FontWeight.w800, color: green)),
                  const SizedBox(height: 10),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      const Text('VALECOIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: green)),
                      const SizedBox(height: 6),
                      if (status == 'cancelled')
                        const Text('Pedido cancelado não gera ValeCoins.', textAlign: TextAlign.center)
                      else if (delivered)
                        Text('+$creditedCoins VC creditados!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: green))
                      else
                        Text('+${widget.expectedCoins} VC após a entrega', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: green)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(onPressed: refresh, icon: const Icon(Icons.refresh), label: const Text('ATUALIZAR AGORA')),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('VOLTAR AO INÍCIO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

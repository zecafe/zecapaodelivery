import 'package:flutter/material.dart';

void main() => runApp(const ZeEntregadorApp());

String money(num v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

double driverFare(double km, {double base = 6, double includedKm = 2, double extraPerKm = 1.5}) {
  final extra = (km - includedKm).clamp(0, double.infinity);
  return base + (extra * extraPerKm);
}

class ZeEntregadorApp extends StatelessWidget {
  const ZeEntregadorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Zé Entregador',
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFF6F0E4), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF4C430), primary: const Color(0xFF171717))),
    home: const HomePage(),
  );
}

class WalletEntry {
  final String title;
  final double amount;
  final DateTime at;
  const WalletEntry(this.title, this.amount, this.at);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool online = false;
  int step = 0;
  int deliveries = 0;
  double available = 0;
  String pixKey = '';
  final double distanceKm = 5;
  final List<WalletEntry> ledger = [];

  final labels = const [
    'Nova entrega disponível',
    'Cheguei ao estabelecimento',
    'Pedido retirado',
    'Cheguei ao cliente',
    'Confirmar entrega',
    'Entrega concluída',
  ];

  double get earning => driverFare(distanceKm);
  String get actionLabel => step == 0 ? 'ACEITAR ENTREGA' : step == 5 ? 'CONCLUÍDA' : labels[step];

  void toggleOnline() => setState(() {
    online = !online;
    if (!online) step = 0;
  });

  void advanceDelivery() {
    if (step >= 5) return;
    setState(() {
      step++;
      if (step == 5) {
        deliveries++;
        available += earning;
        ledger.insert(0, WalletEntry('Entrega demonstrativa #0001', earning, DateTime.now()));
      }
    });
  }

  void savePix() {
    final c = TextEditingController(text: pixKey);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chave Pix'),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'CPF, telefone, e-mail ou chave aleatória')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          FilledButton(onPressed: () { setState(() => pixKey = c.text.trim()); Navigator.pop(ctx); }, child: const Text('SALVAR')),
        ],
      ),
    );
  }

  void requestWithdrawal() {
    if (available <= 0 || pixKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pixKey.isEmpty ? 'Cadastre sua chave Pix primeiro.' : 'Você ainda não possui saldo disponível.')));
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Solicitar saque'),
        content: Text('Solicitar saque manual de ${money(available)} para a chave Pix cadastrada?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('VOLTAR')),
          FilledButton(onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('MVP 0.2: solicitação preparada. O pagamento será confirmado manualmente pelo Admin.')));
          }, child: const Text('SOLICITAR')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: const Color(0xFF171717), foregroundColor: Colors.white, title: const Row(children:[CircleAvatar(backgroundColor: Color(0xFFF4C430), child: Icon(Icons.sports_motorsports,color:Color(0xFF171717))),SizedBox(width:12),Text('Zé Entregador', style: TextStyle(fontWeight: FontWeight.w900))])),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Zé Capão • Entregador', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Container(decoration: BoxDecoration(color: online ? const Color(0xFFF4C430) : const Color(0xFF171717), borderRadius: BorderRadius.circular(28)), child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(children: [
              Icon(online ? Icons.delivery_dining : Icons.power_settings_new, size: 60, color: online ? const Color(0xFF171717) : const Color(0xFFF4C430)),
              Text(online ? 'ONLINE' : 'OFFLINE', style: TextStyle(color: online ? const Color(0xFF171717) : Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              FilledButton(onPressed: toggleOnline, child: Text(online ? 'FICAR OFFLINE' : 'FICAR ONLINE')),
            ]),
          )),
          if (online) ...[
            const SizedBox(height: 16),
            Container(decoration: BoxDecoration(color: const Color(0xFF171717), borderRadius: BorderRadius.circular(26)), child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(labels[step], style: const TextStyle(color: Color(0xFFF4C430), fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Zé Capão • corrida demonstrativa\nDistância: ${distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km\nVocê recebe: ${money(earning)}'),
                const SizedBox(height: 6),
                const Text('Regra: R\$ 6,00 até 2 km + R\$ 1,50/km excedente', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 14),
                FilledButton(onPressed: step < 5 ? advanceDelivery : null, child: Text(actionLabel)),
              ]),
            )),
          ],
          const SizedBox(height: 16),
          Card(child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Row(children: [Icon(Icons.account_balance_wallet_outlined), SizedBox(width: 8), Text('Minha carteira', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))]),
              const SizedBox(height: 14),
              const Text('SALDO DISPONÍVEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              Text(money(available), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
              Text('$deliveries entrega(s) concluída(s)'),
              const Divider(height: 28),
              ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.pix), title: const Text('Chave Pix'), subtitle: Text(pixKey.isEmpty ? 'Não cadastrada' : pixKey), trailing: TextButton(onPressed: savePix, child: Text(pixKey.isEmpty ? 'CADASTRAR' : 'ALTERAR'))),
              FilledButton.icon(onPressed: requestWithdrawal, icon: const Icon(Icons.payments_outlined), label: const Text('SOLICITAR SAQUE VIA PIX')),
            ]),
          )),
          if (ledger.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Extrato', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ...ledger.map((e) => ListTile(leading: const CircleAvatar(child: Icon(Icons.add)), title: Text(e.title), subtitle: const Text('Entrega concluída'), trailing: Text('+ ${money(e.amount)}', style: const TextStyle(fontWeight: FontWeight.bold)))),
          ],
          const SizedBox(height: 18),
          const Center(child: Text('MVP 0.2 • carteira contábil demonstrativa', style: TextStyle(color: Colors.black45))),
        ],
      ),
    ),
  );
}

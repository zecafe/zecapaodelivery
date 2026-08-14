import 'package:flutter/material.dart';
import 'core.dart';
import 'store.dart';
import 'wallet.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  bool terms = false;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(child: Image.asset('Ativos/Marca/zecapao_app_icon.png', height: 118)),
            const SizedBox(height: 20),
            const Text('Chegue mais. 🌵', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('Peça no Vale e acumule ValeCoins em cada entrega.', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Seu nome')),
            const SizedBox(height: 12),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'WhatsApp'),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: terms,
              onChanged: (v) => setState(() => terms = v ?? false),
              title: const Text('Aceito os termos e a política de privacidade'),
            ),
            FilledButton(
              onPressed: terms
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomePage(
                            customerName: name.text.trim().isEmpty ? 'Cliente' : name.text.trim(),
                            phone: phone.text.trim(),
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('ENTRAR NO ZÉ CAPÃO'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String customerName;
  final String phone;

  const HomePage({super.key, required this.customerName, required this.phone});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repo = Repo();
  late Future<List<Store>> storesFuture;
  late Future<ValeCoinBalance> walletFuture;

  @override
  void initState() {
    super.initState();
    storesFuture = repo.stores();
    walletFuture = repo.valecoinBalance(widget.phone);
  }

  Future<void> refreshAll() async {
    final stores = repo.stores();
    final wallet = repo.valecoinBalance(widget.phone);
    setState(() {
      storesFuture = stores;
      walletFuture = wallet;
    });
    await Future.wait([stores, wallet]);
  }

  Widget walletCard() {
    return FutureBuilder<ValeCoinBalance>(
      future: walletFuture,
      builder: (_, snap) {
        final wallet = snap.data ?? ValeCoinBalance.zero();
        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ValeCoinWalletPage(phone: widget.phone, repo: repo)),
            );
            if (mounted) setState(() => walletFuture = repo.valecoinBalance(widget.phone));
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(22)),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 27,
                  backgroundColor: yellow,
                  child: Text('V', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: green)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VALECOIN', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900)),
                      Text('${wallet.balanceCoins} VC', style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                      Text('${valecoinMoney(wallet.balanceCoins)} em benefícios', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Olá, ${widget.customerName}')),
      body: RefreshIndicator(
        onRefresh: refreshAll,
        child: FutureBuilder<List<Store>>(
          future: storesFuture,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView(children: const [SizedBox(height: 260), Center(child: CircularProgressIndicator())]);
            }
            if (snap.hasError) {
              return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('Erro: ${snap.error}'))]);
            }
            final stores = snap.data ?? [];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Vale do Capão • BA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                walletCard(),
                const SizedBox(height: 10),
                const Text('1% a 3% de volta nas compras elegíveis. Toque na carteira para ver o extrato.', style: TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 22),
                const Text('Estabelecimentos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                ...stores.map(
                  (store) => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Image.asset(store.logo, width: 56, height: 56, fit: BoxFit.contain),
                      title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text('${store.estimatedMinutes} min • Entrega ${money(store.deliveryFee)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: store.isOpen
                          ? () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StorePage(
                                    store: store,
                                    customerName: widget.customerName,
                                    phone: widget.phone,
                                    repo: repo,
                                  ),
                                ),
                              );
                              if (mounted) setState(() => walletFuture = repo.valecoinBalance(widget.phone));
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

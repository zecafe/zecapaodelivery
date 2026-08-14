import 'package:flutter/material.dart';
import 'core.dart';
import 'store.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Image.asset('Ativos/Marca/zecapao_app_icon.png', height: 110),
            const SizedBox(height: 20),
            const Text('Chegue mais. 🌵', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Seu nome')),
            const SizedBox(height: 12),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'WhatsApp')),
            CheckboxListTile(
              value: terms,
              onChanged: (v) => setState(() => terms = v ?? false),
              title: const Text('Aceito os termos e a política de privacidade'),
            ),
            FilledButton(
              onPressed: terms ? () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomePage(
                      customerName: name.text.trim().isEmpty ? 'Cliente' : name.text.trim(),
                      phone: phone.text.trim(),
                    ),
                  ),
                );
              } : null,
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
  late Future<List<Store>> future;

  @override
  void initState() {
    super.initState();
    future = repo.stores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Olá, ${widget.customerName}')),
      body: FutureBuilder<List<Store>>(
        future: future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Erro: ${snap.error}'));
          final stores = snap.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Vale do Capão • BA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              ...stores.map((store) => Card(
                child: ListTile(
                  leading: Image.asset(store.logo, width: 56, height: 56, fit: BoxFit.contain),
                  title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text('${store.estimatedMinutes} min • Entrega ${money(store.deliveryFee)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: store.isOpen ? () {
                    Navigator.push(
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
                  } : null,
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

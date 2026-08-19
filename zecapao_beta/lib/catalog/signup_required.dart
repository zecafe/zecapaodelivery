import 'package:flutter/material.dart';
import 'core.dart';
import 'commerce_home_v3.dart';

class RequiredSignupPage extends StatefulWidget {
  const RequiredSignupPage({super.key});

  @override
  State<RequiredSignupPage> createState() => _RequiredSignupPageState();
}

class _RequiredSignupPageState extends State<RequiredSignupPage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  bool terms = false;
  String? error;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  String digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  void enter() {
    final n = name.text.trim();
    final p = digits(phone.text);
    if (n.length < 2) {
      setState(() => error = 'Informe seu nome para continuar.');
      return;
    }
    if (p.length < 10 || p.length > 11) {
      setState(() => error = 'Informe um celular válido com DDD.');
      return;
    }
    if (!terms) {
      setState(() => error = 'Aceite os termos e a política de privacidade.');
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CommerceHomeV3Page(customerName: n, phone: p),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandRed,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 28),
            Center(
              child: Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset('Ativos/Marca/zecapao_app_icon.png', fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Tudo que Vale,\nperto de você.', style: TextStyle(color: Colors.white, fontSize: 34, height: 1.02, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Comida, compras, serviços e experiências do Vale do Capão.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: appBg, borderRadius: BorderRadius.circular(28)),
              child: Column(
                children: [
                  TextField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Seu nome *', prefixIcon: Icon(Icons.person_outline_rounded))),
                  const SizedBox(height: 12),
                  TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Celular com DDD *', hintText: '(75) 99999-9999', prefixIcon: Icon(Icons.phone_outlined))),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: terms,
                    activeColor: brandRed,
                    onChanged: (v) => setState(() { terms = v ?? false; error = null; }),
                    title: const Text('Aceito os termos e a política de privacidade', style: TextStyle(fontSize: 12)),
                  ),
                  if (error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: brandRedSoft, borderRadius: BorderRadius.circular(14)),
                      child: Text(error!, style: const TextStyle(color: brandRed, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(onPressed: enter, child: const SizedBox(width: double.infinity, child: Text('ENTRAR NO ZÉ CAPÃO', textAlign: TextAlign.center))),
                  const SizedBox(height: 8),
                  const Text('* Nome e celular são obrigatórios para pedidos e entregas.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: brandMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

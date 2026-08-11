import 'package:flutter/material.dart';

void main() => runApp(const ZecapaoApp());

const red = Color(0xFFE2231A);
const yellow = Color(0xFFFFC107);
const ink = Color(0xFF111111);
const green = Color(0xFF1F5E3A);
const cream = Color(0xFFF2E6C9);

class Partner {
  final String name;
  final String subtitle;
  final String logo;
  const Partner(this.name, this.subtitle, this.logo);
}

const partners = <Partner>[
  Partner('Zecafé', 'Cafés • Doces • Experiências', 'assets/branding/zecafe.jpg'),
  Partner('Café DuValle', 'Café • Brunch', 'assets/branding/cafe_duvalle.jpg'),
  Partner('Frutos', 'Sucos • Focaccias • Toasts', 'assets/branding/frutos.jpg'),
  Partner('Garimpo Burger', 'Hambúrguer artesanal', 'assets/branding/garimpo_burger.jpg'),
  Partner('Gatto Sete Bistrô', 'Bistrô • Gastronomia', 'assets/branding/gatto_sete.jpg'),
  Partner('Green', 'Gastronomia', 'assets/branding/green.jpg'),
  Partner('Mandioca Gastrobar', 'Restaurante • Bar', 'assets/branding/mandioca.jpg'),
  Partner('Ôxe Restô', 'Restaurante', 'assets/branding/oxe.jpg'),
  Partner('Paulistano Capão', 'Restaurante', 'assets/branding/paulistano.jpg'),
  Partner('Pico do Açaí', 'Açaí • Lanches', 'assets/branding/pico_acai.jpg'),
  Partner('Pizza Lab', 'Pizza • Music & Drinks', 'assets/branding/pizza_lab.jpg'),
  Partner('Comercial Bastos', 'Mercado • Conveniência', 'assets/branding/comercial_bastos.jpg'),
  Partner('Alma Bistrô', 'Bistrô', 'assets/branding/alma.jpg'),
  Partner('Dona Beli', 'Comida caseira', 'assets/branding/dona_beli.jpg'),
  Partner('Budha Restaurante', 'Restaurante', 'assets/branding/budha.jpg'),
  Partner('Cabeça de Gelo', 'Turismo de aventura • Sucos', 'assets/branding/cabeca_de_gelo.jpg'),
  Partner('Capão Grande', 'Pizzaria integral', 'assets/branding/capao_grande.jpg'),
  Partner('CBD', 'Loja local', 'assets/branding/cbd.jpg'),
  Partner('Charruá Restaurante', 'Restaurante', 'assets/branding/charrua.jpg'),
];

class ZecapaoApp extends StatelessWidget {
  const ZecapaoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Zé Capão Delivery',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8F4EC),
      colorScheme: ColorScheme.fromSeed(seedColor: red, primary: red, secondary: yellow),
      cardTheme: const CardThemeData(color: Colors.white, elevation: 0),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: const NavigationBar(destinations: [
      NavigationDestination(icon: Icon(Icons.home), label: 'Início'),
      NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
      NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
      NavigationDestination(icon: Icon(Icons.event), label: 'Eventos'),
      NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
    ]),
    body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 24), children: [
      Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/branding/zecapao_app_icon.png', width: 54, height: 54, fit: BoxFit.cover)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Salve, capoeira!', style: TextStyle(color: Colors.black54)), SizedBox(height: 2), Row(children: [Icon(Icons.location_on, color: red, size: 18), SizedBox(width: 4), Text('Vale do Capão • BA', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))])])),
        const Icon(Icons.notifications_none),
      ]),
      const SizedBox(height: 16),
      Container(height: 56, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Row(children: [Icon(Icons.search, color: Colors.black45), SizedBox(width: 10), Expanded(child: Text('O que você quer pedir hoje?', style: TextStyle(color: Colors.black45))) ])),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [red, Color(0xFFB8120A)]), borderRadius: BorderRadius.circular(28)), child: Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Pediu.\nChegou.', style: TextStyle(color: Colors.white, fontSize: 34, height: .95, fontWeight: FontWeight.w900)), SizedBox(height: 10), Text('O Vale inteiro na sua mão.', style: TextStyle(color: cream, fontWeight: FontWeight.w700))])),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('assets/branding/zecapao_app_icon.png', width: 105, height: 105, fit: BoxFit.cover)),
      ])),
      const SizedBox(height: 24),
      const Text('Categorias', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      const Wrap(spacing: 12, runSpacing: 12, children: [Category(label:'Comida',icon:Icons.restaurant),Category(label:'Bebidas',icon:Icons.local_bar),Category(label:'Mercado',icon:Icons.shopping_basket),Category(label:'Cafés',icon:Icons.coffee),Category(label:'Eventos',icon:Icons.event),Category(label:'Pousadas',icon:Icons.bed),Category(label:'Experiências',icon:Icons.landscape)]),
      const SizedBox(height: 26),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Parceiros do Capão', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), Text('Ver todos', style: TextStyle(color: red, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 12),
      ...partners.map((p) => PartnerCard(partner: p)),
    ])),
  );
}

class Category extends StatelessWidget {
  final String label;
  final IconData icon;
  const Category({super.key, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => SizedBox(width: 78, child: Column(children: [CircleAvatar(radius: 26, backgroundColor: cream, child: Icon(icon, color: red)), const SizedBox(height: 6), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))]));
}

class PartnerCard extends StatelessWidget {
  final Partner partner;
  const PartnerCard({super.key, required this.partner});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartnerPage(partner: partner))), child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(16), child: Container(color: Colors.white, width: 72, height: 72, padding: const EdgeInsets.all(5), child: Image.asset(partner.logo, fit: BoxFit.contain))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(partner.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(partner.subtitle, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 6), const Row(children: [Icon(Icons.schedule, size: 14, color: Colors.black45), SizedBox(width: 4), Text('25–40 min', style: TextStyle(fontSize: 12, color: Colors.black54)), SizedBox(width: 12), Icon(Icons.delivery_dining, size: 15, color: green), SizedBox(width: 4), Text('Entrega', style: TextStyle(fontSize: 12, color: Colors.black54))])])),
      const Icon(Icons.chevron_right),
    ]))),
  );
}

class PartnerPage extends StatelessWidget {
  final Partner partner;
  const PartnerPage({super.key, required this.partner});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(partner.name, style: const TextStyle(fontWeight: FontWeight.w900))),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(height: 220, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)), child: Image.asset(partner.logo, fit: BoxFit.contain)),
      const SizedBox(height: 18),
      Text(partner.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 5), Text(partner.subtitle, style: const TextStyle(color: Colors.black54, fontSize: 15)),
      const SizedBox(height: 20),
      const Text('Em breve', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('Aqui entram fotos reais, cardápio, produtos, preços, retirada, entrega e avaliações do parceiro.', style: TextStyle(color: Colors.black54, height: 1.5)),
    ]),
  );
}

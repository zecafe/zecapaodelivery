import 'package:flutter/material.dart';

void main() => runApp(const ZecapaoApp());

const red = Color(0xFFE52318);
const yellow = Color(0xFFFFC51A);
const ink = Color(0xFF211B1B);
const paper = Color(0xFFF8F6F1);

class ProductItem {
  final String name;
  final String description;
  final double price;
  const ProductItem(this.name, this.description, this.price);
}

class Partner {
  final String name;
  final String category;
  final String subtitle;
  final IconData icon;
  final List<ProductItem> products;
  const Partner(this.name, this.category, this.subtitle, this.icon, this.products);
}

const partners = <Partner>[
  Partner('Zecafé', 'Cafés', 'Cafés • Doces • Experiências', Icons.coffee_rounded, [ProductItem('Cappuccino', 'Espresso e leite vaporizado.', 12), ProductItem('Croissant recheado', 'Croissant amanteigado com recheio.', 25)]),
  Partner('Café NuValle', 'Cafés', 'Café • Brunch', Icons.local_cafe_rounded, [ProductItem('Café especial', 'Seleção da casa.', 14)]),
  Partner('Frutos', 'Comer & Beber', 'Sucos • Focaccias • Toasts', Icons.local_drink_rounded, [ProductItem('Suco da estação', 'Frutas frescas.', 16)]),
  Partner('Garimpo Burger', 'Comer & Beber', 'Hambúrguer artesanal', Icons.lunch_dining_rounded, [ProductItem('Garimpo Clássico', 'Hambúrguer artesanal e queijo.', 34)]),
  Partner('Gatto Sete Bistrô', 'Comer & Beber', 'Bistrô • Gastronomia', Icons.restaurant_rounded, [ProductItem('Prato do dia', 'Criação sazonal do bistrô.', 46)]),
  Partner('Mandioca Gastrobar', 'Comer & Beber', 'Restaurante • Bar', Icons.local_bar_rounded, [ProductItem('Prato regional', 'Sabores locais.', 48)]),
  Partner('Ôxe Restô', 'Comer & Beber', 'Restaurante', Icons.ramen_dining_rounded, [ProductItem('Executivo do dia', 'Prato completo.', 38)]),
  Partner('Paulistano Capão', 'Comer & Beber', 'Restaurante', Icons.restaurant_menu_rounded, [ProductItem('Prato da casa', 'Receita da casa.', 42)]),
  Partner('Pico do Açaí', 'Comer & Beber', 'Açaí • Lanches', Icons.icecream_rounded, [ProductItem('Açaí 500ml', 'Açaí com complementos.', 24)]),
  Partner('Pizza Lab', 'Comer & Beber', 'Pizza • Music & Drinks', Icons.local_pizza_rounded, [ProductItem('Pizza da casa', 'Receita artesanal.', 58)]),
  Partner('Princesas das Empadas', 'Comer & Beber', 'Empadas • Lanches', Icons.bakery_dining_rounded, [ProductItem('Empada artesanal', 'Massa delicada.', 12)]),
  Partner('Voraz Sanduicheria', 'Comer & Beber', 'Sanduíches', Icons.fastfood_rounded, [ProductItem('Resenha do Vale', 'Sanduíche de costela.', 34), ProductItem('Diamante da Chapada', 'Cogumelos.', 32)]),
  Partner('Comercial Bastos', 'Mercados', 'Mercado • Conveniência', Icons.shopping_cart_rounded, [ProductItem('Cesta rápida', 'Seleção essencial.', 49)]),
];

class ZecapaoApp extends StatelessWidget {
  const ZecapaoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Zé Capão Delivery',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: red), scaffoldBackgroundColor: paper, useMaterial3: true),
    home: const Shell(),
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  final favorites = <String>{};
  int cartCount = 0;
  void toggleFavorite(String name) => setState(() => favorites.contains(name) ? favorites.remove(name) : favorites.add(name));
  void addCart() => setState(() => cartCount++);
  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(favorites: favorites, toggleFavorite: toggleFavorite, addCart: addCart),
      ExplorePage(favorites: favorites, toggleFavorite: toggleFavorite, addCart: addCart),
      OrdersPage(cartCount: cartCount),
      const EventsPage(),
      ProfilePage(favorites: favorites),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos'),
          NavigationDestination(icon: Icon(Icons.event_outlined), label: 'Eventos'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Set<String> favorites;
  final ValueChanged<String> toggleFavorite;
  final VoidCallback addCart;
  const HomePage({super.key, required this.favorites, required this.toggleFavorite, required this.addCart});
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
    const AppHeader(), const SizedBox(height: 12),
    GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExplorePage(favorites: favorites, toggleFavorite: toggleFavorite, addCart: addCart))), child: const SearchBox()),
    const SizedBox(height: 14), const HeroBanner(),
    const SectionTitle('O que você precisa agora?'),
    Wrap(spacing: 8, runSpacing: 8, children: [
      category(context, 'Comer & Beber', Icons.restaurant, favorites, toggleFavorite, addCart),
      category(context, 'Mercados', Icons.shopping_basket, favorites, toggleFavorite, addCart),
      category(context, 'Cafés', Icons.coffee, favorites, toggleFavorite, addCart),
      category(context, 'Turismo', Icons.landscape, favorites, toggleFavorite, addCart),
    ]),
    const SectionTitle('Destaques do Capão'),
    ...partners.map((p) => PartnerCard(partner: p, favorite: favorites.contains(p.name), onFavorite: () => toggleFavorite(p.name), onTap: () => openPartner(context, p, favorites, toggleFavorite, addCart))),
  ]));

  Widget category(BuildContext context, String title, IconData icon, Set<String> favorites, ValueChanged<String> toggle, VoidCallback add) => InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryPage(title: title, favorites: favorites, toggleFavorite: toggle, addCart: add))),
    child: Container(width: 150, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [Icon(icon, color: red), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)))])),
  );
}

void openPartner(BuildContext context, Partner p, Set<String> favorites, ValueChanged<String> toggle, VoidCallback add) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => PartnerPage(partner: p, favorite: favorites.contains(p.name), onFavorite: () => toggle(p.name), addCart: add)));
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 52, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: yellow, borderRadius: BorderRadius.circular(17)), child: const Text('ZÉ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
    const SizedBox(width: 12),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Bom dia 👋', style: TextStyle(color: Colors.black54)), Row(children: [Icon(Icons.location_on, color: red, size: 18), Text('Vale do Capão • BA', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))])])),
    const Icon(Icons.notifications_none),
  ]);
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});
  @override
  Widget build(BuildContext context) => Container(height: 58, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.search, color: Colors.black45), SizedBox(width: 10), Expanded(child: Text('Buscar restaurantes, mercados, passeios...', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black45)))]));
}

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: red, borderRadius: BorderRadius.circular(28)), child: const Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tudo que Vale,\nentregue até você.', style: TextStyle(color: Colors.white, fontSize: 27, height: 1.05, fontWeight: FontWeight.w900)), SizedBox(height: 10), Text('Comida, compras, experiências e serviços locais.', style: TextStyle(color: Colors.white70))])), Icon(Icons.delivery_dining, size: 62, color: yellow)]));
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 24, bottom: 12), child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)));
}

class PartnerCard extends StatelessWidget {
  final Partner partner;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  const PartnerCard({super.key, required this.partner, required this.favorite, required this.onFavorite, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.all(12),
    leading: CircleAvatar(radius: 28, backgroundColor: const Color(0xFFFFE5E1), child: Icon(partner.icon, color: ink)),
    title: Text(partner.name, style: const TextStyle(fontWeight: FontWeight.w900)),
    subtitle: Text(partner.subtitle),
    trailing: IconButton(onPressed: onFavorite, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? red : Colors.black38)),
  ));
}

class PartnerPage extends StatelessWidget {
  final Partner partner;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback addCart;
  const PartnerPage({super.key, required this.partner, required this.favorite, required this.onFavorite, required this.addCart});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(partner.name), actions: [IconButton(onPressed: onFavorite, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: red))]),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(height: 150, decoration: BoxDecoration(color: yellow, borderRadius: BorderRadius.circular(26)), child: Icon(partner.icon, size: 76, color: ink)),
      const SizedBox(height: 18), Text(partner.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), Text(partner.subtitle, style: const TextStyle(color: Colors.black54)),
      const SectionTitle('Destaques do cardápio'),
      ...partner.products.map((p) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900)), Text(p.description), const SizedBox(height: 6), Text('R\$ ${p.price.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: red, fontWeight: FontWeight.w900))])), FilledButton(onPressed: addCart, child: const Icon(Icons.add))]))),
    ]),
  );
}

class ExplorePage extends StatefulWidget {
  final Set<String> favorites;
  final ValueChanged<String> toggleFavorite;
  final VoidCallback addCart;
  const ExplorePage({super.key, required this.favorites, required this.toggleFavorite, required this.addCart});
  @override State<ExplorePage> createState() => _ExplorePageState();
}
class _ExplorePageState extends State<ExplorePage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final list = partners.where((p) => '${p.name} ${p.category}'.toLowerCase().contains(query.toLowerCase())).toList();
    return SafeArea(child: Column(children: [Padding(padding: const EdgeInsets.all(16), child: TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar no Vale'))), Expanded(child: ListView(padding: const EdgeInsets.all(16), children: list.map((p) => PartnerCard(partner: p, favorite: widget.favorites.contains(p.name), onFavorite: () => widget.toggleFavorite(p.name), onTap: () => openPartner(context, p, widget.favorites, widget.toggleFavorite, widget.addCart))).toList())]));
  }
}

class CategoryPage extends StatelessWidget {
  final String title;
  final Set<String> favorites;
  final ValueChanged<String> toggleFavorite;
  final VoidCallback addCart;
  const CategoryPage({super.key, required this.title, required this.favorites, required this.toggleFavorite, required this.addCart});
  @override
  Widget build(BuildContext context) {
    final list = title == 'Cafés' ? partners.where((p) => p.category == 'Cafés').toList() : title == 'Mercados' ? partners.where((p) => p.category == 'Mercados').toList() : partners.where((p) => p.category == 'Comer & Beber').toList();
    return Scaffold(appBar: AppBar(title: Text(title)), body: ListView(padding: const EdgeInsets.all(16), children: list.map((p) => PartnerCard(partner: p, favorite: favorites.contains(p.name), onFavorite: () => toggleFavorite(p.name), onTap: () => openPartner(context, p, favorites, toggleFavorite, addCart))).toList()));
  }
}

class OrdersPage extends StatelessWidget {
  final int cartCount;
  const OrdersPage({super.key, required this.cartCount});
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Seus pedidos', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 12), Text(cartCount == 0 ? 'Seu carrinho está vazio.' : 'Você adicionou $cartCount item(ns) ao pedido.', style: const TextStyle(fontSize: 17))])));
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [const Text('Eventos', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 18), InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventDetailPage())), child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(28)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('3ª EDIÇÃO', style: TextStyle(color: yellow, fontWeight: FontWeight.w900)), SizedBox(height: 18), Text('CAPÃO\nREGGAE VALE', style: TextStyle(color: Colors.white, fontSize: 34, height: .95, fontWeight: FontWeight.w900)), SizedBox(height: 12), Text('Música • Natureza • Conexão • Cultura', style: TextStyle(color: Colors.white70))])))]));
}

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: ink, appBar: AppBar(backgroundColor: ink, foregroundColor: Colors.white, title: const Text('Capão Reggae Vale')), body: const Padding(padding: EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('CAPÃO\nREGGAE VALE', style: TextStyle(color: Colors.white, fontSize: 42, height: .92, fontWeight: FontWeight.w900)), SizedBox(height: 14), Text('Música • Cultura • Natureza • Conexão', style: TextStyle(color: yellow, fontWeight: FontWeight.w700)), SizedBox(height: 24), Text('Um encontro no coração da Chapada Diamantina.', style: TextStyle(color: Colors.white70, fontSize: 17))])));
}

class ProfilePage extends StatelessWidget {
  final Set<String> favorites;
  const ProfilePage({super.key, required this.favorites});
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [const Text('Seu Zecapão', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 12), Text('Favoritos: ${favorites.length}', style: const TextStyle(fontSize: 18)), const SizedBox(height: 12), ...favorites.map((f) => ListTile(leading: const Icon(Icons.favorite, color: red), title: Text(f)))]));
}

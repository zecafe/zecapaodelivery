import 'package:flutter/material.dart';

void main() => runApp(const ZecapaoApp());

const red = Color(0xFFE52318);
const yellow = Color(0xFFFFC51A);
const ink = Color(0xFF211B1B);
const paper = Color(0xFFF8F6F1);

class Partner {
  final String name;
  final String category;
  final String subtitle;
  final IconData icon;
  final List<ProductItem> products;
  const Partner(this.name, this.category, this.subtitle, this.icon, this.products);
}

class ProductItem {
  final String name;
  final String description;
  final double price;
  const ProductItem(this.name, this.description, this.price);
}

const partners = <Partner>[
  Partner('Zecafé', 'Cafés', 'Cafés • Doces • Experiências', Icons.coffee_rounded, [
    ProductItem('Cappuccino', 'Café espresso, leite vaporizado e cremosidade.', 12),
    ProductItem('Croissant recheado', 'Croissant amanteigado com recheio à escolha.', 25),
    ProductItem('Cinnamon Roll', 'Massa macia, canela e cobertura delicada.', 18),
  ]),
  Partner('Café NuValle', 'Cafés', 'Café • Brunch', Icons.local_cafe_rounded, [
    ProductItem('Café especial', 'Seleção da casa preparada na hora.', 14),
    ProductItem('Brunch do Vale', 'Combinação leve para começar o dia.', 32),
  ]),
  Partner('Frutos', 'Comer & Beber', 'Sucos • Focaccias • Toasts', Icons.local_drink_rounded, [
    ProductItem('Suco da estação', 'Frutas frescas e combinação do dia.', 16),
    ProductItem('Focaccia da casa', 'Massa artesanal com ingredientes frescos.', 28),
  ]),
  Partner('Garimpo Burger', 'Comer & Beber', 'Hambúrguer artesanal', Icons.lunch_dining_rounded, [
    ProductItem('Garimpo Clássico', 'Hambúrguer artesanal, queijo e molho da casa.', 34),
    ProductItem('Batata do Garimpo', 'Batatas crocantes com tempero especial.', 18),
  ]),
  Partner('Gatto Sete Bistrô', 'Comer & Beber', 'Bistrô • Gastronomia', Icons.restaurant_rounded, [
    ProductItem('Prato do dia', 'Criação sazonal do bistrô.', 46),
    ProductItem('Entrada da casa', 'Pequena porção para compartilhar.', 26),
  ]),
  Partner('Mandioca Gastrobar', 'Comer & Beber', 'Restaurante • Bar', Icons.local_bar_rounded, [
    ProductItem('Petisco da casa', 'Petisco autoral para compartilhar.', 32),
    ProductItem('Prato regional', 'Sabores locais em leitura contemporânea.', 48),
  ]),
  Partner('Ôxe Restô', 'Comer & Beber', 'Restaurante', Icons.ramen_dining_rounded, [
    ProductItem('Executivo do dia', 'Prato completo servido no almoço.', 38),
  ]),
  Partner('Paulistano Capão', 'Comer & Beber', 'Restaurante', Icons.restaurant_menu_rounded, [
    ProductItem('Prato da casa', 'Receita clássica do restaurante.', 42),
  ]),
  Partner('Pico do Açaí', 'Comer & Beber', 'Açaí • Lanches', Icons.icecream_rounded, [
    ProductItem('Açaí 500ml', 'Açaí cremoso com complementos.', 24),
    ProductItem('Açaí 300ml', 'Porção individual com complementos.', 18),
  ]),
  Partner('Pizza Lab', 'Comer & Beber', 'Pizza • Music & Drinks', Icons.local_pizza_rounded, [
    ProductItem('Pizza da casa', 'Receita artesanal assada na hora.', 58),
    ProductItem('Pizza vegetariana', 'Vegetais e ingredientes frescos.', 56),
  ]),
  Partner('Princesas das Empadas', 'Comer & Beber', 'Empadas • Lanches', Icons.bakery_dining_rounded, [
    ProductItem('Empada artesanal', 'Massa delicada e recheio generoso.', 12),
    ProductItem('Combo 4 empadas', 'Seleção de sabores da casa.', 42),
  ]),
  Partner('Voraz Sanduicheria', 'Comer & Beber', 'Sanduíches', Icons.fastfood_rounded, [
    ProductItem('Resenha do Vale', 'Sanduíche artesanal de costela.', 34),
    ProductItem('Ouro da Serra', 'Sanduíche artesanal de frango.', 31),
    ProductItem('Diamante da Chapada', 'Sanduíche vegetariano com cogumelos.', 32),
  ]),
  Partner('Comercial Bastos', 'Mercados', 'Mercado • Conveniência', Icons.shopping_cart_rounded, [
    ProductItem('Cesta rápida', 'Seleção essencial para sua estadia.', 49),
  ]),
  Partner('Green', 'Comer & Beber', 'Comer & Beber', Icons.eco_rounded, [
    ProductItem('Especial Green', 'Sugestão da casa.', 29),
  ]),
];

class ZecapaoApp extends StatelessWidget {
  const ZecapaoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zé Capão Delivery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: red).copyWith(primary: red, secondary: yellow, surface: Colors.white),
        scaffoldBackgroundColor: paper,
        useMaterial3: true,
        fontFamily: 'Roboto',
        navigationBarTheme: const NavigationBarThemeData(indicatorColor: Color(0xFFFFDDD8)),
      ),
      home: const Shell(),
    );
  }
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
    final pages = [
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
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          const NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Badge(isLabelVisible: cartCount > 0, label: Text('$cartCount'), child: const Icon(Icons.receipt_long_outlined)), selectedIcon: const Icon(Icons.receipt_long), label: 'Pedidos'),
          const NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Eventos'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
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

  static const categories = [
    ('Comer & Beber', Icons.restaurant_rounded),
    ('Mercados', Icons.shopping_basket_rounded),
    ('Cafés', Icons.coffee_rounded),
    ('Hospedagem', Icons.bed_rounded),
    ('Turismo', Icons.landscape_rounded),
    ('Serviços', Icons.storefront_rounded),
    ('Eventos', Icons.local_activity_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: AppHeader()),
        SliverToBoxAdapter(child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExplorePage(favorites: favorites, toggleFavorite: toggleFavorite, addCart: addCart))), child: const SearchBox())),
        const SliverToBoxAdapter(child: HeroBanner()),
        const SliverToBoxAdapter(child: SectionTitle(title: 'O que você precisa agora?', trailing: 'Ver tudo')),
        SliverToBoxAdapter(child: SizedBox(height: 116, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (context, i) {
          final item = categories[i];
          return InkWell(borderRadius: BorderRadius.circular(22), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryPage(title: item.$1, icon: item.$2, favorites: favorites, toggleFavorite: toggleFavorite, addCart: addCart))), child: Container(width: 98, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 22, backgroundColor: const Color(0xFFFFF0B8), child: Icon(item.$2, color: ink)), const SizedBox(height: 8), Text(item.$1, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))]));
        }))),
        const SliverToBoxAdapter(child: SectionTitle(title: 'Destaques do Capão', trailing: 'Perto de você')),
        SliverPadding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 22), sliver: SliverList.builder(itemCount: partners.length, itemBuilder: (context, i) => PartnerCard(partner: partners[i], favorite: favorites.contains(partners[i].name), onFavorite: () => toggleFavorite(partners[i].name), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartnerPage(partner: partners[i], favorite: favorites.contains(partners[i].name), onFavorite: () => toggleFavorite(partners[i].name), addCart: addCart))))))),
      ]),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 10), child: Row(children: [
    Container(width: 50, height: 50, decoration: BoxDecoration(color: yellow, borderRadius: BorderRadius.circular(17)), child: const Stack(alignment: Alignment.center, children: [Icon(Icons.face_rounded, size: 30, color: ink), Positioned(bottom: 5, child: Text('ZÉ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)))])),
    const SizedBox(width: 12),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Bom dia 👋', style: TextStyle(fontSize: 13, color: Colors.black54)), SizedBox(height: 2), Row(children: [Icon(Icons.location_on, size: 17, color: red), SizedBox(width: 4), Text('Vale do Capão • BA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))])])),
    IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
  ]));
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Container(height: 56, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19)), child: const Row(children: [Icon(Icons.search, color: Colors.black45), SizedBox(width: 10), Expanded(child: Text('Buscar restaurantes, mercados, passeios...', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black45, fontSize: 13))), Icon(Icons.tune_rounded, color: red)])));
}

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.fromLTRB(16, 10, 16, 4), padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [red, Color(0xFFB7150E)]), borderRadius: BorderRadius.circular(28)), child: Row(children: [
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tudo que Vale,\nentregue até você.', style: TextStyle(color: Colors.white, fontSize: 25, height: 1.05, fontWeight: FontWeight.w900)), SizedBox(height: 10), Text('Comida, compras, experiências e serviços locais em um só lugar.', style: TextStyle(color: Colors.white70, height: 1.35))])),
    const SizedBox(width: 14),
    Container(width: 88, height: 88, decoration: BoxDecoration(color: yellow, borderRadius: BorderRadius.circular(27)), child: const Icon(Icons.delivery_dining_rounded, size: 50, color: ink)),
  ]));
}

class SectionTitle extends StatelessWidget {
  final String title; final String trailing;
  const SectionTitle({super.key, required this.title, required this.trailing});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(16, 22, 16, 12), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))), Text(trailing, style: const TextStyle(color: red, fontWeight: FontWeight.w800))]));
}

class PartnerCard extends StatelessWidget {
  final Partner partner; final bool favorite; final VoidCallback onFavorite; final VoidCallback onTap;
  const PartnerCard({super.key, required this.partner, required this.favorite, required this.onFavorite, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: InkWell(borderRadius: BorderRadius.circular(22), onTap: onTap, child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
    Container(width: 70, height: 70, decoration: BoxDecoration(color: const Color(0xFFFFECE8), borderRadius: BorderRadius.circular(19)), child: Icon(partner.icon, size: 34, color: ink)),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(partner.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(partner.subtitle, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 7), const Row(children: [Icon(Icons.schedule, size: 15, color: Colors.black45), SizedBox(width: 4), Text('25–40 min', style: TextStyle(fontSize: 12, color: Colors.black54)), SizedBox(width: 12), Icon(Icons.delivery_dining, size: 16, color: red), SizedBox(width: 4), Text('Entrega', style: TextStyle(fontSize: 12, color: Colors.black54))])])),
    IconButton(onPressed: onFavorite, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? red : Colors.black38)),
  ]))));
}

class PartnerPage extends StatelessWidget {
  final Partner partner; final bool favorite; final VoidCallback onFavorite; final VoidCallback addCart;
  const PartnerPage({super.key, required this.partner, required this.favorite, required this.onFavorite, required this.addCart});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(partner.name, style: const TextStyle(fontWeight: FontWeight.w900)), actions: [IconButton(onPressed: onFavorite, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: red))]), body: ListView(padding: const EdgeInsets.all(16), children: [
    Container(height: 180, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFE5DE), Color(0xFFFFF1B8)]), borderRadius: BorderRadius.circular(28)), child: Center(child: Icon(partner.icon, size: 84, color: ink))),
    const SizedBox(height: 18), Text(partner.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(partner.subtitle, style: const TextStyle(color: Colors.black54, fontSize: 15)), const SizedBox(height: 12),
    const Wrap(spacing: 8, runSpacing: 8, children: [Chip(label: Text('25–40 min')), Chip(label: Text('Entrega')), Chip(label: Text('Retirada'))]),
    const SizedBox(height: 20), const Text('Destaques do cardápio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 12),
    ...partner.products.map((p) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 5), Text(p.description, style: const TextStyle(color: Colors.black54, height: 1.3)), const SizedBox(height: 8), Text('R\$ ${p.price.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: red, fontWeight: FontWeight.w900))])), const SizedBox(width: 10), FilledButton(onPressed: () { addCart(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name} adicionado ao pedido'))); }, child: const Icon(Icons.add))]))),
  ]));
}

class ExplorePage extends StatefulWidget {
  final Set<String> favorites; final ValueChanged<String> toggleFavorite; final VoidCallback addCart;
  const ExplorePage({super.key, required this.favorites, required this.toggleFavorite, required this.addCart});
  @override State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = partners.where((p) => '${p.name} ${p.category} ${p.subtitle}'.toLowerCase().contains(query.toLowerCase())).toList();
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Descubra o Capão', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 12), TextField(onChanged: (v) => setState(() => query = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'O que você procura?', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(18))))])),
      Expanded(child: ListView.builder(padding: const EdgeInsets.fromLTRB(16, 8, 16, 20), itemCount: filtered.length, itemBuilder: (context, i) { final p = filtered[i]; return PartnerCard(partner: p, favorite: widget.favorites.contains(p.name), onFavorite: () { widget.toggleFavorite(p.name); setState(() {}); }, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartnerPage(partner: p, favorite: widget.favorites.contains(p.name), onFavorite: () => widget.toggleFavorite(p.name), addCart: widget.addCart)))); }))
    ]));
  }
}

class CategoryPage extends StatelessWidget {
  final String title; final IconData icon; final Set<String> favorites; final ValueChanged<String> toggleFavorite; final VoidCallback addCart;
  const CategoryPage({super.key, required this.title, required this.icon, required this.favorites, required this.toggleFavorite, required this.addCart});
  @override
  Widget build(BuildContext context) {
    final list = title == 'Cafés' ? partners.where((p) => p.category == 'Cafés').toList() : title == 'Mercados' ? partners.where((p) => p.category == 'Mercados').toList() : title == 'Comer & Beber' ? partners.where((p) => p.category == 'Comer & Beber' || p.category == 'Cafés').toList() : partners.take(5).toList();
    return Scaffold(appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900))), body: ListView(padding: const EdgeInsets.all(16), children: [Container(height: 110, decoration: BoxDecoration(color: yellow, borderRadius: BorderRadius.circular(26)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 44, color: ink), const SizedBox(width: 14), Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))])), const SizedBox(height: 18), ...list.map((p) => PartnerCard(partner: p, favorite: favorites.contains(p.name), onFavorite: () => toggleFavorite(p.name), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartnerPage(partner: p, favorite: favorites.contains(p.name), onFavorite: () => toggleFavorite(p.name), addCart: addCart))))]));
  }
}

class OrdersPage extends StatelessWidget {
  final int cartCount;
  const OrdersPage({super.key, required this.cartCount});
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.delivery_dining_rounded, size: 54, color: red), const SizedBox(height: 20), const Text('Seus pedidos', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 12), Text(cartCount == 0 ? 'Seu carrinho está vazio. Explore os parceiros do Vale e adicione algo gostoso.' : 'Você já adicionou $cartCount item(ns) ao pedido de demonstração.', style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)), if (cartCount > 0) ...[const SizedBox(height: 24), FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.shopping_bag), label: const Text('Ir para checkout'))]])));
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [const Text('Eventos', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 6), const Text('O que está acontecendo no Vale.', style: TextStyle(color: Colors.black54)), const SizedBox(height: 22), InkWell(borderRadius: BorderRadius.circular(28), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventDetailPage())), child: Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(28)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.music_note, color: Color(0xFFFFA51E)), Spacer(), Text('3ª EDIÇÃO', style: TextStyle(color: Color(0xFFFFA51E), fontWeight: FontWeight.w900))]), SizedBox(height: 24), Text('CAPÃO\nREGGAE VALE', style: TextStyle(color: Colors.white, fontSize: 34, height: .95, fontWeight: FontWeight.w900)), SizedBox(height: 12), Text('Música • Natureza • Conexão • Cultura', style: TextStyle(color: Colors.white70)), SizedBox(height: 20), Row(children: [Icon(Icons.touch_app, color: yellow), SizedBox(width: 8), Text('Toque para abrir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))])])))]));
}

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFF111111), appBar: AppBar(backgroundColor: const Color(0xFF111111), foregroundColor: Colors.white, title: const Text('Capão Reggae Vale')), body: ListView(padding: const EdgeInsets.all(20), children: [const Text('CAPÃO\nREGGAE VALE', style: TextStyle(color: Colors.white, fontSize: 42, height: .92, fontWeight: FontWeight.w900)), const SizedBox(height: 12), const Text('3ª edição • Vale do Capão • Chapada Diamantina', style: TextStyle(color: Color(0xFFFFA51E), fontWeight: FontWeight.w700)), const SizedBox(height: 28), const Text('MÚSICA • CULTURA • NATUREZA • CONEXÃO', style: TextStyle(color: Colors.white70, height: 1.5)), const SizedBox(height: 24), Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Sobre o evento', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('Um encontro entre música, cultura, natureza e propósito no coração da Chapada Diamantina.', style: TextStyle(color: Colors.white70, height: 1.5))])), const SizedBox(height: 18), FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFA51E), foregroundColor: Colors.black), onPressed: null, icon: Icon(Icons.local_activity), label: Text('Ingressos em breve'))]));
}

class ProfilePage extends StatelessWidget {
  final Set<String> favorites;
  const ProfilePage({super.key, required this.favorites});
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [const Icon(Icons.person_rounded, size: 54, color: red), const SizedBox(height: 20), const Text('Seu Zecapão', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 10), const Text('Endereços, favoritos, cupons, suporte e preferências.', style: TextStyle(color: Colors.black54, height: 1.5)), const SizedBox(height: 24), Text('Favoritos (${favorites.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10), if (favorites.isEmpty) const Text('Você ainda não favoritou nenhum parceiro.', style: TextStyle(color: Colors.black54)) else ...favorites.map((f) => ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(backgroundColor: Color(0xFFFFE5E1), child: Icon(Icons.favorite, color: red)), title: Text(f, style: const TextStyle(fontWeight: FontWeight.w700))))]));
}

import 'package:flutter/material.dart';

void main() => runApp(const ZecapaoApp());

class ZecapaoApp extends StatelessWidget {
  const ZecapaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFE52318),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zé Capão Delivery',
      theme: ThemeData(
        colorScheme: scheme.copyWith(
          primary: const Color(0xFFE52318),
          secondary: const Color(0xFFFFC51A),
          surface: const Color(0xFFFFFDF8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F6F1),
        useMaterial3: true,
        fontFamily: 'Roboto',
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

  final pages = const [
    HomePage(),
    ExplorePage(),
    OrdersPage(),
    EventsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Pedidos'),
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Eventos'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const categories = [
    ('Comer & Beber', Icons.restaurant_rounded),
    ('Mercados', Icons.shopping_basket_rounded),
    ('Cafés', Icons.coffee_rounded),
    ('Hospedagem', Icons.bed_rounded),
    ('Turismo', Icons.landscape_rounded),
    ('Serviços', Icons.storefront_rounded),
    ('Eventos', Icons.local_activity_rounded),
  ];

  static const partners = [
    ('Zecafé', 'Cafés • Doces • Experiências'),
    ('Café NuValle', 'Café • Brunch'),
    ('Frutos', 'Sucos • Focaccias • Toasts'),
    ('Garimpo Burger', 'Hambúrguer artesanal'),
    ('Gatto Sete Bistrô', 'Bistrô • Gastronomia'),
    ('Mandioca Gastrobar', 'Restaurante • Bar'),
    ('Ôxe Restô', 'Restaurante'),
    ('Paulistano Capão', 'Restaurante'),
    ('Pico do Açaí', 'Açaí • Lanches'),
    ('Pizza Lab', 'Pizza • Music & Drinks'),
    ('Princesas das Empadas', 'Empadas • Lanches'),
    ('Voraz Sanduicheria', 'Sanduíches'),
    ('Comercial Bastos', 'Mercado'),
    ('Green', 'Comer & Beber'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header()),
          SliverToBoxAdapter(child: _SearchBar()),
          SliverToBoxAdapter(child: _HeroBanner()),
          SliverToBoxAdapter(child: _SectionTitle(title: 'O que você precisa agora?', trailing: 'Ver tudo')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 112,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final item = categories[i];
                  return Container(
                    width: 96,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFFFFF0B8),
                          child: Icon(item.$2, color: const Color(0xFF252020)),
                        ),
                        const SizedBox(height: 8),
                        Text(item.$1, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: _SectionTitle(title: 'Destaques do Capão', trailing: 'Perto de você')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
            sliver: SliverList.builder(
              itemCount: partners.length,
              itemBuilder: (context, i) => PartnerCard(name: partners[i].$1, subtitle: partners[i].$2, index: i),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC51A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('ZÉ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF211B1B)))),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bom dia 👋', style: TextStyle(fontSize: 13, color: Colors.black54)),
                SizedBox(height: 2),
                Row(children: [Icon(Icons.location_on, size: 17, color: Color(0xFFE52318)), SizedBox(width: 4), Text('Vale do Capão • BA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))]),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: const Row(children: [Icon(Icons.search, color: Colors.black45), SizedBox(width: 10), Text('Buscar restaurantes, mercados, passeios...', style: TextStyle(color: Colors.black45, fontSize: 13))]),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE52318), Color(0xFFB7150E)]),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tudo que Vale,\nentregue até você.', style: TextStyle(color: Colors.white, fontSize: 25, height: 1.05, fontWeight: FontWeight.w900)),
                SizedBox(height: 10),
                Text('Comida, compras, experiências e serviços locais em um só lugar.', style: TextStyle(color: Colors.white70, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(color: const Color(0xFFFFC51A), borderRadius: BorderRadius.circular(26)),
            child: const Icon(Icons.delivery_dining_rounded, size: 48, color: Color(0xFF231E1E)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String trailing;
  const _SectionTitle({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          Text(trailing, style: const TextStyle(color: Color(0xFFE52318), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class PartnerCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final int index;
  const PartnerCard({super.key, required this.name, required this.subtitle, required this.index});

  @override
  Widget build(BuildContext context) {
    const icons = [Icons.coffee, Icons.local_cafe, Icons.local_drink, Icons.lunch_dining, Icons.restaurant, Icons.local_bar, Icons.ramen_dining, Icons.restaurant_menu, Icons.icecream, Icons.local_pizza, Icons.bakery_dining, Icons.fastfood, Icons.shopping_cart, Icons.eco];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(color: index.isEven ? const Color(0xFFFFE5E1) : const Color(0xFFFFF1B8), borderRadius: BorderRadius.circular(18)),
            child: Icon(icons[index % icons.length], size: 34, color: const Color(0xFF2B2424)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 7),
                const Row(children: [Icon(Icons.schedule, size: 15, color: Colors.black45), SizedBox(width: 4), Text('25–40 min', style: TextStyle(fontSize: 12, color: Colors.black54)), SizedBox(width: 12), Icon(Icons.delivery_dining, size: 16, color: Color(0xFFE52318)), SizedBox(width: 4), Text('Entrega', style: TextStyle(fontSize: 12, color: Colors.black54))]),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) => const SimplePage(
    title: 'Descubra o Capão',
    icon: Icons.explore_rounded,
    text: 'Aqui entram busca, filtros, mapa, categorias e todos os parceiros do destino.',
  );
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) => const SimplePage(
    title: 'Seus pedidos',
    icon: Icons.delivery_dining_rounded,
    text: 'O fluxo de carrinho, checkout, pagamento e acompanhamento será conectado ao backend na próxima etapa.',
  );
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Eventos', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('O que está acontecendo no Vale.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.music_note, color: Color(0xFFFFA51E)), Spacer(), Text('3ª EDIÇÃO', style: TextStyle(color: Color(0xFFFFA51E), fontWeight: FontWeight.w900))]),
                const SizedBox(height: 24),
                const Text('CAPÃO\nREGGAE VALE', style: TextStyle(color: Colors.white, fontSize: 34, height: .95, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                const Text('Música • Natureza • Conexão • Cultura', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.local_activity), label: const Text('Ver evento')),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('A agenda poderá ser atualizada pelo painel sem precisar publicar uma nova versão do app.', style: TextStyle(color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => const SimplePage(
    title: 'Seu Zecapão',
    icon: Icons.person_rounded,
    text: 'Endereços, favoritos, cupons, suporte, preferências e histórico ficarão centralizados aqui.',
  );
}

class SimplePage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String text;
  const SimplePage({super.key, required this.title, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 54, color: const Color(0xFFE52318)),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

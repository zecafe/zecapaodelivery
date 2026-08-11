import 'package:flutter/material.dart';

void main() {
  runApp(const ZecapaoApp());
}

const Color red = Color(0xFFE52318);
const Color yellow = Color(0xFFFFC51A);
const Color paper = Color(0xFFF8F6F1);

class ZecapaoApp extends StatelessWidget {
  const ZecapaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zé Capão Delivery',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(seedColor: red),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Eventos'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Header(),
            const SizedBox(height: 14),
            const SearchBox(),
            const SizedBox(height: 14),
            const HeroBanner(),
            const SizedBox(height: 24),
            const Text(
              'O que você precisa agora?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const CategoryRow(),
            const SizedBox(height: 24),
            const Text(
              'Destaques do Capão',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            PartnerCard(
              name: 'Zecafé',
              subtitle: 'Cafés • Doces • Experiências',
              icon: Icons.coffee,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PartnerPage(
                    name: 'Zecafé',
                    subtitle: 'Cafés • Doces • Experiências',
                    icon: Icons.coffee,
                    items: ['Cappuccino', 'Croissant recheado', 'Cinnamon Roll'],
                  ),
                ),
              ),
            ),
            PartnerCard(
              name: 'Voraz Sanduicheria',
              subtitle: 'Sanduíches artesanais',
              icon: Icons.fastfood,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PartnerPage(
                    name: 'Voraz Sanduicheria',
                    subtitle: 'Sanduíches artesanais',
                    icon: Icons.fastfood,
                    items: ['Resenha do Vale', 'Ouro da Serra', 'Diamante da Chapada'],
                  ),
                ),
              ),
            ),
            PartnerCard(
              name: 'Comercial Bastos',
              subtitle: 'Mercado • Conveniência',
              icon: Icons.shopping_cart,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PartnerPage(
                    name: 'Comercial Bastos',
                    subtitle: 'Mercado • Conveniência',
                    icon: Icons.shopping_cart,
                    items: ['Cesta rápida', 'Bebidas', 'Itens essenciais'],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            EventCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: yellow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'ZÉ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bom dia 👋', style: TextStyle(color: Colors.black54)),
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on, color: red, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Vale do Capão • BA',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.notifications_none),
      ],
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.black45),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Buscar restaurantes, mercados, passeios...',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: red,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tudo que Vale,\nentregue até você.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Comida, compras, experiências e serviços locais.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Icon(Icons.delivery_dining, size: 62, color: yellow),
        ],
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CategoryChip(label: 'Comer', icon: Icons.restaurant),
        CategoryChip(label: 'Mercados', icon: Icons.shopping_basket),
        CategoryChip(label: 'Cafés', icon: Icons.coffee),
        CategoryChip(label: 'Eventos', icon: Icons.event),
      ],
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const CategoryChip({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFFFE9A8),
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class PartnerCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const PartnerCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFFFE5E1),
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class PartnerPage extends StatefulWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final List<String> items;
  const PartnerPage({
    super.key,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.items,
  });

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  int cartCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: yellow,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Icon(widget.icon, size: 76, color: Colors.black87),
          ),
          const SizedBox(height: 18),
          Text(widget.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(widget.subtitle, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          const Text('Destaques', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...widget.items.map(
            (item) => Card(
              child: ListTile(
                title: Text(item, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Item demonstrativo do parceiro'),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: red),
                  onPressed: () {
                    setState(() => cartCount++);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$item adicionado • $cartCount item(ns)')),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final VoidCallback onTap;
  const EventCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EVENTOS', style: TextStyle(color: yellow, fontWeight: FontWeight.w900)),
            SizedBox(height: 14),
            Text(
              'CAPÃO\nREGGAE VALE',
              style: TextStyle(color: Colors.white, fontSize: 30, height: 0.95, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8),
            Text('Música • Natureza • Conexão • Cultura', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151515),
        foregroundColor: Colors.white,
        title: const Text('Capão Reggae Vale'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CAPÃO\nREGGAE VALE',
              style: TextStyle(color: Colors.white, fontSize: 42, height: 0.92, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 14),
            Text('3ª edição • Vale do Capão', style: TextStyle(color: yellow, fontWeight: FontWeight.w800)),
            SizedBox(height: 24),
            Text(
              'Um encontro entre música, cultura, natureza e conexão no coração da Chapada Diamantina.',
              style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

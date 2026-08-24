import 'package:flutter/material.dart';
import 'core.dart';
import 'branded_store.dart';
import 'category_hub.dart';

class ShowcaseHomePage extends StatefulWidget {
  final String customerName;
  final String phone;
  const ShowcaseHomePage({super.key, required this.customerName, required this.phone});

  @override
  State<ShowcaseHomePage> createState() => _ShowcaseHomePageState();
}

class _ShowcaseHomePageState extends State<ShowcaseHomePage> {
  final repo = Repo();
  late Future<List<Store>> storesFuture;
  int tab = 0;

  @override
  void initState() {
    super.initState();
    storesFuture = repo.stores();
  }

  Future<void> openStore(Store store) async {
    if (!store.isOpen) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => BrandedStorePage(store: store, customerName: widget.customerName, phone: widget.phone, repo: repo)));
  }

  Future<void> openCategory(String category) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryHubPage(
      category: category,
      customerName: widget.customerName,
      phone: widget.phone,
      repo: repo,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Pedidos'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Conta'),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Store>>(
          future: storesFuture,
          builder: (_, snap) {
            final stores = snap.data ?? <Store>[];
            if (tab != 0) return _simpleTab(tab, stores);
            return _home(stores);
          },
        ),
      ),
    );
  }

  Widget _home(List<Store> stores) {
    return RefreshIndicator(
      onRefresh: () async => setState(() => storesFuture = repo.stores()),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(17, 12, 17, 28),
        children: [
          _header(),
          const SizedBox(height: 18),
          Container(
            height: 58,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 18, offset: Offset(0, 7))]),
            child: const Row(children: [SizedBox(width: 18), Icon(Icons.search_rounded, size: 28), SizedBox(width: 14), Expanded(child: Text('O que você procura no Vale?', style: TextStyle(color: brandMuted, fontSize: 16)))]),
          ),
          const SizedBox(height: 22),
          const Text('Tudo por aqui', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          _categories(),
          const SizedBox(height: 16),
          _zecafeHero(stores),
          const SizedBox(height: 25),
          const Text('Parceiros em destaque', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 11),
          _partnerRail(stores),
          const SizedBox(height: 26),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('O Vale acontece', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), TextButton(onPressed: () => openCategory('Eventos'), child: const Text('Ver agenda'))]),
          const Text('Música, cultura e experiências que movimentam o Capão.', style: TextStyle(color: brandMuted, fontSize: 11.5)),
          const SizedBox(height: 12),
          _events(),
          const SizedBox(height: 26),
          const Text('Bateu um momento', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text('Escolhas rápidas para entrar no clima.', style: TextStyle(color: brandMuted, fontSize: 11.5)),
          const SizedBox(height: 12),
          _occasionRail(),
          const SizedBox(height: 24),
          _valecoin(),
          const SizedBox(height: 24),
          const Text('Mais do que delivery', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: InkWell(onTap: () => openCategory('Hospedagem'), borderRadius: BorderRadius.circular(21), child: _miniExplore('Hospedagens', Icons.hotel_rounded, const Color(0xFFE6EEFF)))),
            const SizedBox(width: 10),
            Expanded(child: InkWell(onTap: () => openCategory('Experiências'), borderRadius: BorderRadius.circular(21), child: _miniExplore('Experiências', Icons.hiking_rounded, const Color(0xFFE1F5EE)))),
            const SizedBox(width: 10),
            Expanded(child: InkWell(onTap: () => openCategory('Eventos'), borderRadius: BorderRadius.circular(21), child: _miniExplore('Eventos', Icons.local_activity_rounded, const Color(0xFFFFE4EC)))),
          ]),
          const SizedBox(height: 14),
          const Center(child: Text('MVP 0.2.7 • CATEGORY HUB', style: TextStyle(fontSize: 9, color: brandMuted, fontWeight: FontWeight.w800, letterSpacing: 1))),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(children: [
      Container(width: 51, height: 51, padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: brandRed, borderRadius: BorderRadius.circular(17), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 6))]), child: ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset('Ativos/Marca/zecapao_app_icon.png', fit: BoxFit.cover))),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Salve, ${widget.customerName}!', style: const TextStyle(fontSize: 11, color: brandMuted, fontWeight: FontWeight.w700)), const SizedBox(height: 2), const Row(children: [Icon(Icons.location_on_rounded, color: brandRed, size: 17), SizedBox(width: 3), Text('Vale do Capão • BA', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))])])),
      Container(width: 45, height: 45, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.notifications_none_rounded)),
    ]);
  }

  Widget _categories() {
    final items = [
      ('Comida', Icons.lunch_dining_rounded, const Color(0xFFFF6A3D), const Color(0xFFFFE6DD)),
      ('Café', Icons.coffee_rounded, const Color(0xFF8B5E3C), const Color(0xFFF1E1D0)),
      ('Pizza', Icons.local_pizza_rounded, const Color(0xFFE8452C), const Color(0xFFFFE7C9)),
      ('Mercado', Icons.shopping_basket_rounded, const Color(0xFF2F9A62), const Color(0xFFE0F3E6)),
      ('Hospedagem', Icons.hotel_rounded, const Color(0xFF5677C7), const Color(0xFFE7EEFF)),
      ('Experiências', Icons.hiking_rounded, const Color(0xFF27866D), const Color(0xFFE0F4EF)),
      ('Eventos', Icons.local_activity_rounded, const Color(0xFFC84671), const Color(0xFFFFE2EC)),
    ];
    return SizedBox(height: 122, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) {
      final x = items[i];
      return SizedBox(width: 76, child: InkWell(
        onTap: () => openCategory(x.$1),
        borderRadius: BorderRadius.circular(23),
        child: Column(children: [
          Container(width: 70, height: 70, decoration: BoxDecoration(color: x.$4, borderRadius: BorderRadius.circular(23), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 16, offset: Offset(0, 9))]), child: Center(child: Stack(alignment: Alignment.center, children: [Transform.translate(offset: const Offset(3, 5), child: Icon(x.$2, size: 39, color: Colors.black12)), Icon(x.$2, size: 39, color: x.$3), Positioned(top: 13, left: 22, child: Container(width: 16, height: 7, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .45), borderRadius: BorderRadius.circular(10))))]))),
          const SizedBox(height: 9), Text(x.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
        ]),
      ));
    }));
  }

  Widget _zecafeHero(List<Store> stores) {
    Store? zecafe;
    for (final s in stores) { if (s.slug == 'zecafe') zecafe = s; }
    return InkWell(
      onTap: zecafe == null ? null : () => openStore(zecafe!),
      borderRadius: BorderRadius.circular(29),
      child: Container(
        height: 204,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(29), gradient: const LinearGradient(colors: [Color(0xFF6D4A34), Color(0xFF9B6C49)], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 12))]),
        child: Stack(children: [
          Positioned(right: -25, bottom: -25, child: Container(width: 185, height: 185, decoration: BoxDecoration(color: const Color(0xFFFFD28B).withValues(alpha: .18), shape: BoxShape.circle))),
          Positioned(right: 18, bottom: 18, child: Stack(alignment: Alignment.center, children: [Container(width: 122, height: 122, decoration: BoxDecoration(color: const Color(0xFFF0E4D5), borderRadius: BorderRadius.circular(34), boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 18, offset: Offset(0, 9))])), const Icon(Icons.coffee_rounded, size: 76, color: Color(0xFF5A3827)), Positioned(top: 16, right: 26, child: Icon(Icons.auto_awesome_rounded, color: brandYellow, size: 22))])),
          Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('RESPIRA... VOCÊ CHEGOU!', style: TextStyle(color: Color(0xFFFFD9A5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
            const SizedBox(height: 8), const Text('Zecafé', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
            const Text('Café • Pizza • Cinema', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 13), Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: brandYellow, borderRadius: BorderRadius.circular(14)), child: const Text('VER CARDÁPIO  →', style: TextStyle(color: brandInk, fontSize: 10, fontWeight: FontWeight.w900))),
          ])),
        ]),
      ),
    );
  }

  Widget _partnerRail(List<Store> stores) {
    final preferred = ['pizza-lab', 'pico-acai', 'garimpo-burger', 'cafe-duvalle', 'dona-beli'];
    final found = <Store>[];
    for (final slug in preferred) { for (final s in stores) { if (s.slug == slug) found.add(s); } }
    if (found.isEmpty) {
      return SizedBox(height: 152, child: ListView(scrollDirection: Axis.horizontal, children: preferred.map((slug) => Padding(padding: const EdgeInsets.only(right: 10), child: _brandTile(slug, null))).toList()));
    }
    return SizedBox(height: 152, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: found.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => _brandTile(found[i].slug, found[i])));
  }

  Widget _brandTile(String slug, Store? store) {
    final spec = switch (slug) {
      'pizza-lab' => ('PIZZA\nLAB', Icons.science_rounded, const Color(0xFFE72E27), Colors.white, 'Artesanal & criativa'),
      'pico-acai' => ('PICO\ndo AÇAÍ', Icons.local_florist_rounded, const Color(0xFF6D2CA4), Colors.white, 'Energia da Chapada'),
      'garimpo-burger' => ('GARIMPO', Icons.lunch_dining_rounded, const Color(0xFFE9D5A9), const Color(0xFF49321F), 'Burger do Vale'),
      'cafe-duvalle' => ('Café\nDuvalle', Icons.landscape_rounded, const Color(0xFF4D5F22), Colors.white, 'Torrefação artesanal'),
      'dona-beli' => ('Dona Beli', Icons.soup_kitchen_rounded, const Color(0xFFFFEEE3), const Color(0xFFB82C2C), 'Comida de verdade'),
      _ => (store?.name ?? 'Parceiro', Icons.storefront_rounded, brandNavy, Colors.white, 'Parceiro local'),
    };
    return InkWell(onTap: store == null ? null : () => openStore(store), borderRadius: BorderRadius.circular(22), child: Container(width: 132, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: spec.$3, borderRadius: BorderRadius.circular(22), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 16, offset: Offset(0, 8))]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(spec.$2, color: spec.$4, size: 34), const SizedBox(height: 8), Text(spec.$1, textAlign: TextAlign.center, style: TextStyle(color: spec.$4, fontSize: 16, height: .95, fontWeight: FontWeight.w900)), const SizedBox(height: 7), Text(spec.$5, textAlign: TextAlign.center, style: TextStyle(color: spec.$4.withValues(alpha: .72), fontSize: 8.5, fontWeight: FontWeight.w600))])));
  }

  Widget _events() {
    return SizedBox(height: 190, child: PageView(controller: PageController(viewportFraction: .93), children: [
      Padding(padding: const EdgeInsets.only(right: 10), child: _eventCard(title: 'CAPÃO\nREGGAE VALE', date: '01 NOV', subtitle: 'Música • cultura • natureza', colors: const [Color(0xFF123A26), Color(0xFFE3A928)], icon: Icons.graphic_eq_rounded, accent: const Color(0xFFF7C833))),
      Padding(padding: const EdgeInsets.only(right: 10), child: _eventCard(title: 'FESTIVAL\nDE JAZZ', date: '18 • 19 SET', subtitle: 'Jazz entre montanhas', colors: const [Color(0xFF172654), Color(0xFF7E356D)], icon: Icons.music_note_rounded, accent: const Color(0xFFF7C833))),
    ]));
  }

  Widget _eventCard({required String title, required String date, required String subtitle, required List<Color> colors, required IconData icon, required Color accent}) {
    return Container(clipBehavior: Clip.antiAlias, decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 9))]), child: Stack(children: [
      Positioned(right: -18, top: -18, child: Icon(Icons.landscape_rounded, size: 190, color: Colors.white.withValues(alpha: .08))),
      Positioned(right: 22, bottom: 18, child: Container(width: 92, height: 92, decoration: BoxDecoration(color: Colors.black.withValues(alpha: .16), shape: BoxShape.circle), child: Icon(icon, color: accent, size: 58))),
      Padding(padding: const EdgeInsets.all(21), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(10)), child: Text(date, style: const TextStyle(color: brandInk, fontSize: 9, fontWeight: FontWeight.w900))), const SizedBox(height: 10), Text(title, style: const TextStyle(color: Colors.white, fontSize: 25, height: .93, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10.5))])),
    ]));
  }

  Widget _occasionRail() {
    final items = [
      ('Doce intervalo', 'Cookie, café e um respiro.', Icons.cookie_rounded, const [Color(0xFF7B3E1C), Color(0xFFC37B43)]),
      ('Hoje combina com pizza', 'Fatias quentes, noite leve.', Icons.local_pizza_rounded, const [Color(0xFFC92E2B), Color(0xFFFF6A2C)]),
      ('Café da tarde', 'Uma pausa com cheiro de Capão.', Icons.coffee_rounded, const [Color(0xFF4B3427), Color(0xFFB9865E)]),
      ('Frete leve no Vale', 'Achados perto de você.', Icons.delivery_dining_rounded, const [Color(0xFF17624B), Color(0xFF5CBC8B)]),
    ];
    return SizedBox(height: 150, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 11), itemBuilder: (_, i) { final x = items[i]; return Container(width: 222, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(gradient: LinearGradient(colors: x.$4), borderRadius: BorderRadius.circular(25)), child: Stack(children: [Positioned(right: -3, bottom: -3, child: Icon(x.$3, size: 88, color: Colors.white.withValues(alpha: .88))), Positioned(right: -30, top: -35, child: Container(width: 115, height: 115, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .08), shape: BoxShape.circle))), Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 145, child: Text(x.$1, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.05, fontWeight: FontWeight.w900))), const SizedBox(height: 7), SizedBox(width: 125, child: Text(x.$2, style: const TextStyle(color: Colors.white70, fontSize: 10.5, height: 1.25)))])]))); }));
  }

  Widget _valecoin() {
    return Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: const LinearGradient(colors: [brandNavy, brandInk]), borderRadius: BorderRadius.circular(23), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 8))]), child: const Row(children: [CircleAvatar(backgroundColor: brandYellow, child: Text('V', style: TextStyle(color: brandInk, fontWeight: FontWeight.w900, fontSize: 19))), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('VALECOIN', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)), Text('Compre no Vale. Ganhe no Vale.', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)), Text('1% a 3% de volta nas compras elegíveis', style: TextStyle(color: Colors.white60, fontSize: 9.5))])), Icon(Icons.chevron_right_rounded, color: Colors.white70)]));
  }

  Widget _miniExplore(String title, IconData icon, Color bg) {
    return Container(height: 110, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(21)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(icon, color: brandInk, size: 33), Text(title, maxLines: 2, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, height: 1.05))]));
  }

  Widget _simpleTab(int index, List<Store> stores) {
    final titles = ['Início', 'Buscar', 'Pedidos', 'Explorar', 'Conta'];
    return ListView(padding: const EdgeInsets.all(20), children: [Text(titles[index], style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)), const SizedBox(height: 8), const Text('MVP de apresentação • conteúdo em expansão', style: TextStyle(color: brandMuted)), const SizedBox(height: 22), if (index == 1 || index == 3) ...stores.map((s) => ListTile(onTap: () => openStore(s), contentPadding: const EdgeInsets.symmetric(vertical: 6), leading: CircleAvatar(backgroundColor: brandRedSoft, child: Text(s.name.isEmpty ? '?' : s.name[0], style: const TextStyle(color: brandRed, fontWeight: FontWeight.w900))), title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${s.estimatedMinutes} min • Frete ${money(s.deliveryFee)}'), trailing: const Icon(Icons.chevron_right_rounded))) else Container(height: 180, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: const Text('Fluxo demonstrativo do MVP', style: TextStyle(color: brandMuted, fontWeight: FontWeight.w700)))]);
  }
}

import 'package:flutter/material.dart';
import 'core.dart';
import 'branded_store.dart';
import 'wallet.dart';

class BrandedSignupPage extends StatefulWidget {
  const BrandedSignupPage({super.key});
  @override
  State<BrandedSignupPage> createState() => _BrandedSignupPageState();
}

class _BrandedSignupPageState extends State<BrandedSignupPage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  bool terms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandRed,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 18),
            Center(
              child: Container(
                width: 126,
                height: 126,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset('Ativos/Marca/zecapao_app_icon.png', fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text('O Capão chegou.', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Tudo que Vale, entregue até você.', style: TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: appBg, borderRadius: BorderRadius.circular(26)),
              child: Column(
                children: [
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'Seu nome', prefixIcon: Icon(Icons.person_outline_rounded))),
                  const SizedBox(height: 12),
                  TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'WhatsApp', prefixIcon: Icon(Icons.phone_outlined))),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: terms,
                    activeColor: brandRed,
                    onChanged: (v) => setState(() => terms = v ?? false),
                    title: const Text('Aceito os termos e a política de privacidade', style: TextStyle(fontSize: 12)),
                  ),
                  FilledButton(
                    onPressed: terms
                        ? () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BrandedHomePage(
                                  customerName: name.text.trim().isEmpty ? 'Capão' : name.text.trim(),
                                  phone: phone.text.trim(),
                                ),
                              ),
                            )
                        : null,
                    child: const SizedBox(width: double.infinity, child: Text('ENTRAR NO ZÉ CAPÃO', textAlign: TextAlign.center)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandedHomePage extends StatefulWidget {
  final String customerName;
  final String phone;
  const BrandedHomePage({super.key, required this.customerName, required this.phone});
  @override
  State<BrandedHomePage> createState() => _BrandedHomePageState();
}

class _BrandedHomePageState extends State<BrandedHomePage> {
  final repo = Repo();
  final search = TextEditingController();
  late Future<List<Store>> storesFuture;
  late Future<List<CampaignBanner>> bannersFuture;
  late Future<ValeCoinBalance> walletFuture;
  int tab = 0;

  @override
  void initState() {
    super.initState();
    storesFuture = repo.stores();
    bannersFuture = repo.banners();
    walletFuture = repo.valecoinBalance(widget.phone);
  }

  Future<void> openStore(Store store) async {
    if (!store.isOpen) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrandedStorePage(store: store, customerName: widget.customerName, phone: widget.phone, repo: repo),
      ),
    );
  }

  Widget brandImage(String asset, {double size = 54}) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(color: brandBeige, child: const Icon(Icons.storefront_rounded, color: brandRed)),
    );
  }

  Widget storeLogo(Store store, {double size = 54}) {
    final fallback = brandImage(store.localLogo, size: size);
    if (store.logoUrl.isEmpty) return fallback;
    return Image.network(store.logoUrl, width: size, height: size, fit: BoxFit.contain, errorBuilder: (_, __, ___) => fallback);
  }

  Widget storeCard(Store store) {
    return InkWell(
      onTap: () => openStore(store),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 18, offset: Offset(0, 7))],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0x11000000))),
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: storeLogo(store)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(store.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: brandMuted)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 15, color: brandYellow),
                      const Text('4,9', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 10),
                      Text('${store.estimatedMinutes} min', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text(store.isOpen ? 'ABERTO' : 'FECHADO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: store.isOpen ? brandGreen : brandRed)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bannerStrip(List<Store> stores) {
    return FutureBuilder<List<CampaignBanner>>(
      future: bannersFuture,
      builder: (_, snap) {
        final banners = snap.data ?? [];
        if (banners.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 184,
          child: PageView.builder(
            controller: PageController(viewportFraction: .92),
            itemCount: banners.length,
            itemBuilder: (_, index) {
              final b = banners[index];
              final fg = hexColor(b.textHex, Colors.white);
              final bgColor = hexColor(b.backgroundHex, brandRed);
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    if (b.targetType == 'store') {
                      final found = stores.where((s) => s.id == b.targetValue).toList();
                      if (found.isNotEmpty) openStore(found.first);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(28)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(b.title, style: TextStyle(color: fg, fontSize: 27, fontWeight: FontWeight.w900, height: 1.05)),
                        const SizedBox(height: 8),
                        Text(b.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg.withValues(alpha: .85), fontSize: 13)),
                        if (b.ctaLabel.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: brandYellow, borderRadius: BorderRadius.circular(13)),
                            child: Text(b.ctaLabel, style: const TextStyle(color: brandInk, fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget categories() {
    const items = [
      ('Comer', Icons.restaurant_rounded, brandRed),
      ('Mercados', Icons.shopping_cart_outlined, brandGreen),
      ('Lojas', Icons.shopping_bag_outlined, Color(0xFFF2994A)),
      ('Pousadas', Icons.bed_outlined, Color(0xFF9B51E0)),
      ('Passeios', Icons.landscape_outlined, Color(0xFF299E91)),
      ('Serviços', Icons.work_outline_rounded, Color(0xFF2F80ED)),
      ('Eventos', Icons.local_activity_outlined, Color(0xFFEB4D8B)),
    ];
    return SizedBox(
      height: 98,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final item = items[index];
          return SizedBox(
            width: 70,
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19)),
                  child: Icon(item.$2, color: item.$3, size: 27),
                ),
                const SizedBox(height: 6),
                Text(item.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget walletCard() {
    return FutureBuilder<ValeCoinBalance>(
      future: walletFuture,
      builder: (_, snap) {
        final wallet = snap.data ?? ValeCoinBalance.zero();
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ValeCoinWalletPage(phone: widget.phone, repo: repo))),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: brandNavy, borderRadius: BorderRadius.circular(22)),
            child: Row(
              children: [
                const CircleAvatar(radius: 24, backgroundColor: brandYellow, child: Text('V', style: TextStyle(color: brandInk, fontSize: 23, fontWeight: FontWeight.w900))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VALECOIN', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
                      Text('${wallet.balanceCoins} VC', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      Text('${valecoinMoney(wallet.balanceCoins)} em benefícios', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget homeTab(List<Store> stores) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: ClipRRect(borderRadius: BorderRadius.circular(11), child: brandImage('Ativos/Marca/zecapao_app_icon.png', size: 40)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Salve, ${widget.customerName}!', style: const TextStyle(color: brandMuted, fontSize: 12)),
                  const Row(children: [Icon(Icons.location_on_rounded, size: 16, color: brandRed), Text('Vale do Capão • BA', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))]),
                ],
              ),
            ),
            const Icon(Icons.notifications_none_rounded),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => setState(() => tab = 1),
          child: AbsorbPointer(child: TextField(decoration: const InputDecoration(hintText: 'Buscar produtos, lojas, serviços...', prefixIcon: Icon(Icons.search_rounded)))),
        ),
        const SizedBox(height: 16),
        bannerStrip(stores),
        const SizedBox(height: 22),
        const Text('O que você precisa hoje?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        categories(),
        walletCard(),
        const SizedBox(height: 24),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Perto de você', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text('Ver todos', style: TextStyle(color: brandRed, fontSize: 12, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 10),
        ...stores.map(storeCard),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: brandInk, borderRadius: BorderRadius.circular(24)),
          child: const Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Descubra o Vale', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('Eventos, hospedagens, trilhas, cultura e serviços locais.', style: TextStyle(color: Colors.white70, fontSize: 12))])),
              CircleAvatar(radius: 25, backgroundColor: brandYellow, child: Icon(Icons.landscape_rounded, color: brandInk)),
            ],
          ),
        ),
      ],
    );
  }

  Widget searchTab(List<Store> stores) {
    final q = search.text.trim().toLowerCase();
    final filtered = q.isEmpty ? stores : stores.where((s) => s.name.toLowerCase().contains(q) || s.description.toLowerCase().contains(q)).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Buscar no Vale', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        TextField(controller: search, autofocus: true, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Café, pizza, mercado...', prefixIcon: Icon(Icons.search_rounded))),
        const SizedBox(height: 18),
        ...filtered.map(storeCard),
      ],
    );
  }

  Widget emptyTab(String title, String text, IconData icon) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              CircleAvatar(radius: 32, backgroundColor: brandBeige, child: Icon(icon, color: brandRed, size: 31)),
              const SizedBox(height: 14),
              Text(text, textAlign: TextAlign.center, style: const TextStyle(color: brandMuted)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Store>>(
      future: storesFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final stores = snap.data ?? [];
        final pages = [
          homeTab(stores),
          searchTab(stores),
          emptyTab('Meus pedidos', 'Seus pedidos em andamento e recentes aparecem aqui.', Icons.receipt_long_rounded),
          emptyTab('Eventos no Vale', 'Agenda, cultura e experiências do Capão entram aqui.', Icons.local_activity_rounded),
          emptyTab('Minha conta', 'Endereços, formas de pagamento, cupons e configurações.', Icons.person_rounded),
        ];
        return Scaffold(
          backgroundColor: appBg,
          body: SafeArea(child: pages[tab]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) => setState(() => tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Início'),
              NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Busca'),
              NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos'),
              NavigationDestination(icon: Icon(Icons.local_activity_outlined), label: 'Eventos'),
              NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Conta'),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'core.dart';
import 'branded_store.dart';
import 'wallet.dart';

class CommerceSignupPage extends StatefulWidget {
  const CommerceSignupPage({super.key});
  @override
  State<CommerceSignupPage> createState() => _CommerceSignupPageState();
}

class _CommerceSignupPageState extends State<CommerceSignupPage> {
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
                                builder: (_) => CommerceHomePage(
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

class CommerceHomePage extends StatefulWidget {
  final String customerName;
  final String phone;
  const CommerceHomePage({super.key, required this.customerName, required this.phone});

  @override
  State<CommerceHomePage> createState() => _CommerceHomePageState();
}

class _CommerceHomePageState extends State<CommerceHomePage> {
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

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> refreshAll() async {
    final s = repo.stores();
    final b = repo.banners();
    final w = repo.valecoinBalance(widget.phone);
    setState(() {
      storesFuture = s;
      bannersFuture = b;
      walletFuture = w;
    });
    await Future.wait([s, b, w]);
  }

  Future<void> openStore(Store store) async {
    if (!store.isOpen) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrandedStorePage(
          store: store,
          customerName: widget.customerName,
          phone: widget.phone,
          repo: repo,
        ),
      ),
    );
    if (mounted) setState(() => walletFuture = repo.valecoinBalance(widget.phone));
  }

  Widget storeLogo(Store s, {double size = 58}) {
    final local = Image.asset(s.localLogo, width: size, height: size, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.storefront_rounded, color: brandRed));
    if (s.logoUrl.isEmpty) return local;
    return Image.network(s.logoUrl, width: size, height: size, fit: BoxFit.contain, errorBuilder: (_, __, ___) => local);
  }

  Widget placeholderCover(Store s, {double height = 145}) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [brandRed, Color(0xFFFF8C42)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Stack(
        children: [
          Positioned(right: -24, top: -28, child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .10), shape: BoxShape.circle))),
          Positioned(left: 16, bottom: 16, child: Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  Widget heroHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Salve, ${widget.customerName}!', style: const TextStyle(fontSize: 12, color: brandMuted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              const Row(
                children: [
                  Icon(Icons.location_on_rounded, color: brandRed, size: 18),
                  SizedBox(width: 4),
                  Expanded(child: Text('Vale do Capão • BA', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
                ],
              ),
            ],
          ),
        ),
        Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.menu_rounded)),
      ],
    );
  }

  Widget categoryRail() {
    const items = [
      ('Comida', Icons.restaurant_rounded, Color(0xFFFFEFE7)),
      ('Café', Icons.coffee_rounded, Color(0xFFF2E6DA)),
      ('Pizza', Icons.local_pizza_rounded, Color(0xFFFFF1D8)),
      ('Mercado', Icons.shopping_basket_rounded, Color(0xFFE6F6E9)),
      ('Açaí', Icons.icecream_rounded, Color(0xFFEDE5FF)),
      ('Hospedagem', Icons.bed_rounded, Color(0xFFE7EEFF)),
      ('Serviços', Icons.handyman_rounded, Color(0xFFE5F6F4)),
      ('Experiências', Icons.landscape_rounded, Color(0xFFFFE7ED)),
    ];
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final x = items[i];
          return SizedBox(
            width: 72,
            child: Column(
              children: [
                Container(width: 66, height: 66, decoration: BoxDecoration(color: x.$3, borderRadius: BorderRadius.circular(22)), child: Icon(x.$2, color: brandInk, size: 30)),
                const SizedBox(height: 7),
                Text(x.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget bannerRail(List<Store> stores) {
    return FutureBuilder<List<CampaignBanner>>(
      future: bannersFuture,
      builder: (_, snap) {
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return Container(
            height: 188,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [brandRed, Color(0xFFFF8A2B)]), borderRadius: BorderRadius.circular(28)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('O Vale na sua mão.', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Descubra parceiros, benefícios e entregas perto de você.', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 14),
                DecoratedBox(decoration: BoxDecoration(color: brandYellow, borderRadius: BorderRadius.all(Radius.circular(14))), child: Padding(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8), child: Text('EXPLORAR', style: TextStyle(fontWeight: FontWeight.w900)))),
              ],
            ),
          );
        }
        return SizedBox(
          height: 188,
          child: PageView.builder(
            controller: PageController(viewportFraction: .94),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final b = list[i];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: hexColor(b.backgroundHex, brandRed)),
                      if (b.imageUrl.isNotEmpty) Image.network(b.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                      Container(color: Colors.black.withValues(alpha: b.imageUrl.isEmpty ? .05 : .32)),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(b.title, maxLines: 2, style: TextStyle(color: hexColor(b.textHex, Colors.white), fontSize: 27, height: 1.02, fontWeight: FontWeight.w900)),
                            if (b.subtitle.isNotEmpty) ...[const SizedBox(height: 7), Text(b.subtitle, maxLines: 2, style: const TextStyle(color: Colors.white70, fontSize: 12))],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget walletStrip() {
    return FutureBuilder<ValeCoinBalance>(
      future: walletFuture,
      builder: (_, snap) {
        final w = snap.data ?? ValeCoinBalance.zero();
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ValeCoinWalletPage(phone: widget.phone, repo: repo))),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: brandInk, borderRadius: BorderRadius.circular(22)),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: brandYellow, child: Text('V', style: TextStyle(color: brandInk, fontWeight: FontWeight.w900))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('VALECOIN', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)), Text('${w.balanceCoins} VC', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const Text('1% a 3% de volta nas compras elegíveis', style: TextStyle(color: Colors.white60, fontSize: 10))])),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget storeTile(Store s) {
    return InkWell(
      onTap: () => openStore(s),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 240,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 18, offset: Offset(0, 7))]),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 108, width: double.infinity, child: s.coverUrl.isEmpty ? placeholderCover(s, height: 108) : Image.network(s.coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholderCover(s, height: 108))),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 48, height: 48, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0x11000000))), child: ClipRRect(borderRadius: BorderRadius.circular(11), child: storeLogo(s, size: 42))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        Text('${s.estimatedMinutes} min • ${money(s.deliveryFee)}', style: const TextStyle(fontSize: 10, color: brandMuted, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 5),
                        Row(children: [const Icon(Icons.star_rounded, color: brandYellow, size: 14), const Text('4,9', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)), const Spacer(), Text(s.isOpen ? 'ABERTO' : 'FECHADO', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: s.isOpen ? brandGreen : brandRed))]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget merchantListTile(Store s) {
    return InkWell(
      onTap: () => openStore(s),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Container(width: 74, height: 74, padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0x11000000))), child: ClipOval(child: storeLogo(s, size: 60))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('${s.estimatedMinutes} min • Frete ${money(s.deliveryFee)}', style: const TextStyle(fontSize: 11, color: brandMuted)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE5FFF1), borderRadius: BorderRadius.circular(9)), child: const Text('+ ValeCoin', style: TextStyle(color: brandGreen, fontSize: 9, fontWeight: FontWeight.w900))),
                    if (s.deliveryFee == 0) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE5FFF1), borderRadius: BorderRadius.circular(9)), child: const Text('Entrega grátis', style: TextStyle(color: brandGreen, fontSize: 9, fontWeight: FontWeight.w900))),
                  ]),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: brandMuted),
          ],
        ),
      ),
    );
  }

  Widget home(List<Store> stores) {
    final open = stores.where((s) => s.isOpen).toList();
    final spotlight = open.isEmpty ? stores : open;
    return RefreshIndicator(
      onRefresh: refreshAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          heroHeader(),
          const SizedBox(height: 16),
          GestureDetector(onTap: () => setState(() => tab = 1), child: const AbsorbPointer(child: TextField(decoration: InputDecoration(hintText: 'Buscar lojas ou itens', prefixIcon: Icon(Icons.search_rounded))))),
          const SizedBox(height: 18),
          categoryRail(),
          bannerRail(stores),
          const SizedBox(height: 18),
          walletStrip(),
          const SizedBox(height: 26),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Queridinhos do Vale', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), Text('Ver mais', style: TextStyle(color: brandRed, fontWeight: FontWeight.w800, fontSize: 11))]),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: spotlight.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => storeTile(spotlight[i]))),
          const SizedBox(height: 28),
          const Text('Só no Capão', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Parceiros locais e experiências que você encontra por aqui.', style: TextStyle(color: brandMuted, fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(height: 92, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: stores.length, separatorBuilder: (_, __) => const SizedBox(width: 14), itemBuilder: (_, i) => SizedBox(width: 76, child: Column(children: [Container(width: 62, height: 62, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0x11000000))), child: ClipOval(child: storeLogo(stores[i], size: 52))), const SizedBox(height: 6), Text(stores[i].name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700))])))),
          const SizedBox(height: 28),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Recomendados para você', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), Text('Ver mais', style: TextStyle(color: brandRed, fontWeight: FontWeight.w800, fontSize: 11))]),
          const SizedBox(height: 8),
          ...stores.map(merchantListTile),
        ],
      ),
    );
  }

  Widget searchPage(List<Store> stores) {
    final q = search.text.trim().toLowerCase();
    final filtered = q.isEmpty ? stores : stores.where((s) => s.name.toLowerCase().contains(q) || s.description.toLowerCase().contains(q)).toList();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Buscar no Vale', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        TextField(controller: search, autofocus: true, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Café, pizza, mercado, serviço...', prefixIcon: Icon(Icons.search_rounded))),
        const SizedBox(height: 20),
        ...filtered.map(merchantListTile),
      ],
    );
  }

  Widget placeholderPage(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(radius: 34, backgroundColor: brandRedSoft, child: Icon(icon, color: brandRed, size: 32)), const SizedBox(height: 16), Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: brandMuted))]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Store>>(
      future: storesFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final stores = snap.data ?? [];
        final pages = [home(stores), searchPage(stores), placeholderPage('Pedidos', 'Acompanhe pedidos em andamento e reveja compras anteriores.', Icons.receipt_long_rounded), placeholderPage('Explorar', 'Eventos, hospedagens, experiências e serviços do Vale.', Icons.explore_rounded), placeholderPage('Minha conta', 'ValeCoin, endereços, cupons e preferências.', Icons.person_rounded)];
        return Scaffold(
          backgroundColor: appBg,
          body: SafeArea(child: IndexedStack(index: tab, children: pages)),
          bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) => setState(() => tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Início'),
              NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Buscar'),
              NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Pedidos'),
              NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore_rounded), label: 'Explorar'),
              NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Conta'),
            ],
          ),
        );
      },
    );
  }
}

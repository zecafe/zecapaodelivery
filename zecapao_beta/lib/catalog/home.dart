import 'package:flutter/material.dart';
import 'core.dart';
import 'store.dart';
import 'wallet.dart';

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
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(child: Image.asset('Ativos/Marca/zecapao_app_icon.png', height: 118)),
              const SizedBox(height: 20),
              const Text('Chegue mais. 🌵', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('Comida, café, mercado e experiências do Vale.', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 18),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Seu nome')),
              const SizedBox(height: 12),
              TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'WhatsApp')),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: terms,
                onChanged: (v) => setState(() => terms = v ?? false),
                title: const Text('Aceito os termos e a política de privacidade'),
              ),
              FilledButton(
                onPressed: terms
                    ? () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomePage(
                              customerName: name.text.trim().isEmpty ? 'Cliente' : name.text.trim(),
                              phone: phone.text.trim(),
                            ),
                          ),
                        )
                    : null,
                child: const Text('ENTRAR NO ZÉ CAPÃO'),
              ),
            ],
          ),
        ),
      );
}

class HomePage extends StatefulWidget {
  final String customerName, phone;
  const HomePage({super.key, required this.customerName, required this.phone});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final stores = repo.stores();
    final banners = repo.banners();
    final wallet = repo.valecoinBalance(widget.phone);
    setState(() {
      storesFuture = stores;
      bannersFuture = banners;
      walletFuture = wallet;
    });
    await Future.wait([stores, banners, wallet]);
  }

  Widget remoteOrAsset(String url, String asset, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (url.isNotEmpty) {
      return Image.network(url, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) => Image.asset(asset, width: width, height: height, fit: fit));
    }
    return Image.asset(asset, width: width, height: height, fit: fit);
  }

  Future<void> openStore(Store store) async {
    if (!store.isOpen) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => StorePage(store: store, customerName: widget.customerName, phone: widget.phone, repo: repo)));
    if (mounted) setState(() => walletFuture = repo.valecoinBalance(widget.phone));
  }

  Widget campaignBanners(List<Store> stores) => FutureBuilder<List<CampaignBanner>>(
        future: bannersFuture,
        builder: (_, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) return const SizedBox.shrink();
          return SizedBox(
            height: 176,
            child: PageView.builder(
              controller: PageController(viewportFraction: .94),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final b = items[i];
                final fg = hexColor(b.textHex, Colors.white);
                final bgColor = hexColor(b.backgroundHex, red);
                return InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () {
                    if (b.targetType == 'store' && b.targetValue.isNotEmpty) {
                      final found = stores.where((s) => s.id == b.targetValue).toList();
                      if (found.isNotEmpty) openStore(found.first);
                    } else if (b.title.toLowerCase().contains('valecoin')) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ValeCoinWalletPage(phone: widget.phone, repo: repo)));
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(26)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (b.imageUrl.isNotEmpty)
                          Image.network(b.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                        if (b.imageUrl.isNotEmpty) Container(color: Colors.black.withValues(alpha: .30)),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(b.title, style: TextStyle(color: fg, fontSize: 28, fontWeight: FontWeight.w900)),
                              if (b.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(b.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg.withValues(alpha: .9), fontSize: 14)),
                              ],
                              if (b.ctaLabel.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(color: fg.withValues(alpha: .16), borderRadius: BorderRadius.circular(20)),
                                  child: Text(b.ctaLabel, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w900)),
                                ),
                              ],
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

  Widget walletCard() => FutureBuilder<ValeCoinBalance>(
        future: walletFuture,
        builder: (_, snap) {
          final wallet = snap.data ?? ValeCoinBalance.zero();
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ValeCoinWalletPage(phone: widget.phone, repo: repo))),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(22)),
              child: Row(
                children: [
                  const CircleAvatar(radius: 24, backgroundColor: yellow, child: Text('V', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: green))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('MEUS VALECOINS', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
                      Text('${wallet.balanceCoins} VC', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      Text('${valecoinMoney(wallet.balanceCoins)} em benefícios', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          );
        },
      );

  Widget categoryStrip() {
    const items = [
      ('Comida', Icons.restaurant),
      ('Cafés', Icons.local_cafe),
      ('Mercado', Icons.shopping_basket),
      ('Bebidas', Icons.local_bar),
      ('Pousadas', Icons.hotel),
      ('Eventos', Icons.event),
      ('Experiências', Icons.landscape),
    ];
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final item = items[i];
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => tab = item.$1 == 'Eventos' ? 3 : 1),
            child: SizedBox(
              width: 74,
              child: Column(children: [
                Container(width: 56, height: 56, decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(18)), child: Icon(item.$2, color: red)),
                const SizedBox(height: 6),
                Text(item.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget storeCard(Store store, {bool compact = false}) => InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => openStore(store),
        child: Container(
          margin: EdgeInsets.only(bottom: compact ? 0 : 14),
          width: compact ? 210 : double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (store.coverUrl.isNotEmpty)
                SizedBox(height: compact ? 88 : 118, width: double.infinity, child: Image.network(store.coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(14), child: remoteOrAsset(store.logoUrl, store.localLogo, width: compact ? 48 : 60, height: compact ? 48 : 60, fit: BoxFit.contain)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(store.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 15 : 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text('${store.estimatedMinutes} min • ${money(store.deliveryFee)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(store.isOpen ? 'ABERTO' : 'FECHADO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: store.isOpen ? green : red)),
                    ]),
                  ),
                ]),
              ),
            ],
          ),
        ),
      );

  Widget homeTab(List<Store> stores) => RefreshIndicator(
        onRefresh: refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            GestureDetector(
              onTap: () => setState(() => tab = 1),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(hintText: 'Buscar produtos, lojas, serviços...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            campaignBanners(stores),
            const SizedBox(height: 18),
            const Text('Categorias', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            categoryStrip(),
            const SizedBox(height: 14),
            walletCard(),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Destaques no Vale', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              Text('${stores.length} parceiros', style: const TextStyle(color: red, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 126,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stores.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => storeCard(stores[i], compact: true),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Parceiros do Capão', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...stores.map(storeCard),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF242330), borderRadius: BorderRadius.circular(24)),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Explore o Vale', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Hospedagens, trilhas, eventos, cultura e serviços em uma só plataforma.', style: TextStyle(color: Colors.white70)),
              ]),
            ),
          ],
        ),
      );

  Widget searchTab(List<Store> stores) {
    final q = search.text.trim().toLowerCase();
    final filtered = q.isEmpty ? stores : stores.where((s) => s.name.toLowerCase().contains(q) || s.description.toLowerCase().contains(q)).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: search,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: 'Buscar no Vale...', prefixIcon: const Icon(Icons.search), suffixIcon: search.text.isEmpty ? null : IconButton(onPressed: () { search.clear(); setState(() {}); }, icon: const Icon(Icons.close)), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 18),
        Text(q.isEmpty ? 'Descubra' : '${filtered.length} resultado(s)', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        ...filtered.map(storeCard),
      ],
    );
  }

  Widget ordersTab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          const Text('Meus pedidos', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Acompanhe pedidos em andamento e reveja compras recentes.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: const Column(children: [
              Icon(Icons.receipt_long, size: 44, color: red),
              SizedBox(height: 12),
              Text('Nenhum pedido em andamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              SizedBox(height: 6),
              Text('Quando você fizer um pedido, o acompanhamento aparece aqui.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            ]),
          ),
        ],
      );

  Widget eventsTab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Eventos & experiências', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('O que está pulsando no Vale.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          eventCard('01 NOV', 'Capão Reggae Vale', 'Festival de reggae • Vale do Capão', red),
          const SizedBox(height: 12),
          eventCard('TODO DIA', 'Experiências da Chapada', 'Trilhas, passeios, guias e vivências', green),
          const SizedBox(height: 12),
          eventCard('EM BREVE', 'Agenda cultural', 'Cinema, música, gastronomia e encontros', const Color(0xFF242330)),
        ],
      );

  Widget eventCard(String date, String title, String subtitle, Color color) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
        child: Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(16)), child: Text(date, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white70))])),
          const Icon(Icons.chevron_right, color: Colors.white),
        ]),
      );

  Widget profileTab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          CircleAvatar(radius: 42, backgroundColor: cream, child: Text(widget.customerName.isEmpty ? 'Z' : widget.customerName[0].toUpperCase(), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: red))),
          const SizedBox(height: 14),
          Center(child: Text(widget.customerName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
          Center(child: Text(widget.phone, style: const TextStyle(color: Colors.black54))),
          const SizedBox(height: 24),
          ListTile(tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), leading: const Icon(Icons.account_balance_wallet_outlined), title: const Text('Minha ValeCoin'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ValeCoinWalletPage(phone: widget.phone, repo: repo)))),
          const SizedBox(height: 10),
          ListTile(tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), leading: const Icon(Icons.location_on_outlined), title: const Text('Endereços'), trailing: const Icon(Icons.chevron_right)),
          const SizedBox(height: 10),
          ListTile(tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), leading: const Icon(Icons.help_outline), title: const Text('Ajuda e suporte'), trailing: const Icon(Icons.chevron_right)),
        ],
      );

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Store>>(
        future: storesFuture,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final stores = snap.data ?? [];
          final bodies = [homeTab(stores), searchTab(stores), ordersTab(), eventsTab(), profileTab()];
          return Scaffold(
            appBar: tab == 0
                ? AppBar(
                    title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Salve, ${widget.customerName}!', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const Text('Vale do Capão • BA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ]),
                    actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.notifications_none))],
                  )
                : AppBar(title: Text(const ['Início', 'Buscar', 'Pedidos', 'Eventos', 'Perfil'][tab], style: const TextStyle(fontWeight: FontWeight.w900))),
            body: bodies[tab],
            bottomNavigationBar: NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (i) => setState(() => tab = i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
                NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
                NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos'),
                NavigationDestination(icon: Icon(Icons.event_outlined), label: 'Eventos'),
                NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
              ],
            ),
          );
        },
      );
}

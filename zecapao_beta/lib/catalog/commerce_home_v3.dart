import 'package:flutter/material.dart';
import 'core.dart';
import 'branded_store.dart';
import 'wallet.dart';

class CommerceHomeV3Page extends StatefulWidget {
  final String customerName;
  final String phone;
  const CommerceHomeV3Page({super.key, required this.customerName, required this.phone});

  @override
  State<CommerceHomeV3Page> createState() => _CommerceHomeV3PageState();
}

class _CommerceHomeV3PageState extends State<CommerceHomeV3Page> {
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
    final local = Image.asset(
      s.localLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.storefront_rounded, color: brandRed),
    );
    if (s.logoUrl.isEmpty) return local;
    return Image.network(s.logoUrl, width: size, height: size, fit: BoxFit.contain, errorBuilder: (_, __, ___) => local);
  }

  Widget header() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 16, offset: Offset(0, 5))]),
          child: ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.asset('Ativos/Marca/zecapao_app_icon.png', fit: BoxFit.cover)),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Salve, ${widget.customerName}!', style: const TextStyle(fontSize: 11, color: brandMuted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              const Row(children: [Icon(Icons.location_on_rounded, color: brandRed, size: 17), SizedBox(width: 3), Text('Vale do Capão • BA', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))]),
            ],
          ),
        ),
        Container(width: 43, height: 43, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.notifications_none_rounded)),
      ],
    );
  }

  Widget categoryRail() {
    const items = [
      ('Comida', '🍔', Color(0xFFFFE7DE)),
      ('Café', '☕', Color(0xFFF3E2CF)),
      ('Pizza', '🍕', Color(0xFFFFEDCE)),
      ('Mercado', '🛒', Color(0xFFE3F5E7)),
      ('Hospedagem', '🏡', Color(0xFFE7EEFF)),
      ('Experiências', '🥾', Color(0xFFE0F4EF)),
      ('Eventos', '🎫', Color(0xFFFFE2EC)),
      ('Serviços', '🧰', Color(0xFFE9E5FF)),
    ];
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final x = items[i];
          return InkWell(
            onTap: () => setState(() => tab = x.$1 == 'Eventos' ? 3 : 1),
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              width: 75,
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: x.$3,
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: const [BoxShadow(color: Color(0x13000000), blurRadius: 15, offset: Offset(0, 7))],
                    ),
                    child: Text(x.$2, style: const TextStyle(fontSize: 36)),
                  ),
                  const SizedBox(height: 8),
                  Text(x.$1, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.2, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget topBannerRail(List<Store> stores) {
    return FutureBuilder<List<CampaignBanner>>(
      future: bannersFuture,
      builder: (_, snap) {
        final list = snap.data ?? [];
        final zecafe = stores.where((s) => s.slug == 'zecafe').toList();
        final cards = <Widget>[
          _heroCard(
            title: 'O Vale inteiro\nna palma da mão.',
            subtitle: 'Comida, mercado, serviços e experiências locais.',
            tag: 'ZÉ CAPÃO',
            colors: const [brandRed, Color(0xFFFF7B2C)],
            emoji: '📍',
          ),
          if (zecafe.isNotEmpty)
            _imageHeroCard(
              title: 'Café, afeto\ne boas histórias.',
              subtitle: 'Conheça o cardápio do Zecafé.',
              tag: 'ZECAFÉ',
              url: zecafe.first.coverUrl,
              onTap: () => openStore(zecafe.first),
            ),
          ...list.take(3).map((b) => _networkCampaign(b)),
        ];
        return SizedBox(
          height: 194,
          child: PageView.builder(
            controller: PageController(viewportFraction: .94),
            itemCount: cards.length,
            itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(right: 10), child: cards[i]),
          ),
        );
      },
    );
  }

  Widget _heroCard({required String title, required String subtitle, required String tag, required List<Color> colors, required String emoji, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(29),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(29)),
        child: Stack(
          children: [
            Positioned(right: -20, top: -18, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .10), shape: BoxShape.circle))),
            Positioned(right: 22, bottom: 8, child: Transform.rotate(angle: -.08, child: Text(emoji, style: const TextStyle(fontSize: 88)))),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(11)), child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))),
                  const SizedBox(height: 9),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 25, height: 1.02, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 7),
                  SizedBox(width: 230, child: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageHeroCard({required String title, required String subtitle, required String tag, required String url, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(29),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url.isNotEmpty) Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: brandInk)) else Container(color: brandInk),
            Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xD9000000), Color(0x22000000)], begin: Alignment.centerLeft, end: Alignment.centerRight))),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: brandYellow, borderRadius: BorderRadius.circular(10)), child: Text(tag, style: const TextStyle(color: brandInk, fontSize: 9, fontWeight: FontWeight.w900))),
                const SizedBox(height: 9),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 25, height: 1.03, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                SizedBox(width: 235, child: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11.5))),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _networkCampaign(CampaignBanner b) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(29),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: hexColor(b.backgroundHex, brandRed)),
          if (b.imageUrl.isNotEmpty) Image.network(b.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          Container(color: Colors.black.withValues(alpha: b.imageUrl.isEmpty ? .05 : .35)),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(b.title, maxLines: 2, style: TextStyle(color: hexColor(b.textHex, Colors.white), fontSize: 25, height: 1.03, fontWeight: FontWeight.w900)),
              if (b.subtitle.isNotEmpty) ...[const SizedBox(height: 7), SizedBox(width: 240, child: Text(b.subtitle, maxLines: 2, style: const TextStyle(color: Colors.white70, fontSize: 11.5)))],
            ]),
          ),
        ],
      ),
    );
  }

  Widget occasionRail() {
    const items = [
      ('Doce intervalo', 'Cookie, café e um respiro.', '🍪', [Color(0xFF582D1B), Color(0xFFB86E42)]),
      ('Hoje combina com pizza', 'Fatias quentes, noite leve.', '🍕', [Color(0xFFB32024), Color(0xFFFF8F3D)]),
      ('Frete leve no Vale', 'Achados perto de você.', '🛵', [Color(0xFF175D48), Color(0xFF5AB883)]),
      ('Café da tarde', 'Uma pausa com cheiro de Capão.', '☕', [Color(0xFF4A3529), Color(0xFFC08B5B)]),
    ];
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 11),
        itemBuilder: (_, i) {
          final x = items[i];
          return Container(
            width: 218,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(gradient: LinearGradient(colors: x.$4), borderRadius: BorderRadius.circular(25)),
            child: Stack(
              children: [
                Positioned(right: -4, bottom: -5, child: Text(x.$3, style: const TextStyle(fontSize: 70))),
                Positioned(right: -28, top: -38, child: Container(width: 110, height: 110, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .08), shape: BoxShape.circle))),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(width: 145, child: Text(x.$1, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.05, fontWeight: FontWeight.w900))),
                    const SizedBox(height: 7),
                    SizedBox(width: 130, child: Text(x.$2, style: const TextStyle(color: Colors.white70, fontSize: 10.5, height: 1.25))),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget walletStrip() {
    return FutureBuilder<ValeCoinBalance>(
      future: walletFuture,
      builder: (_, snap) {
        final w = snap.data ?? ValeCoinBalance.zero();
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ValeCoinWalletPage(phone: widget.phone, repo: repo))),
          borderRadius: BorderRadius.circular(23),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [brandNavy, brandInk]), borderRadius: BorderRadius.circular(23)),
            child: Row(children: [
              const CircleAvatar(backgroundColor: brandYellow, child: Text('V', style: TextStyle(color: brandInk, fontWeight: FontWeight.w900, fontSize: 19))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('MEU VALECOIN', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)), Text('${w.balanceCoins} VC', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const Text('Ganhe de 1% a 3% de volta', style: TextStyle(color: Colors.white60, fontSize: 10))])),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            ]),
          ),
        );
      },
    );
  }

  Widget storeCard(Store s) {
    return InkWell(
      onTap: () => openStore(s),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 234,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 18, offset: Offset(0, 7))]),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 58, height: 58, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0x11000000))), child: ClipRRect(borderRadius: BorderRadius.circular(13), child: storeLogo(s, size: 50))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, height: 1.08, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text('${s.estimatedMinutes} min', style: const TextStyle(fontSize: 10, color: brandMuted)),
              const SizedBox(height: 4),
              Row(children: [const Icon(Icons.star_rounded, size: 14, color: brandYellow), const Text('4,9', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)), const Spacer(), Text(s.isOpen ? 'ABERTO' : 'FECHADO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: s.isOpen ? brandGreen : brandRed))]),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget eventRail() {
    return SizedBox(
      height: 178,
      child: PageView(
        controller: PageController(viewportFraction: .92),
        children: [
          Padding(padding: const EdgeInsets.only(right: 10), child: _eventCard('CAPÃO REGGAE VALE', '01 NOV', 'Reggae, feminino e Chapada.', '🎶', const [Color(0xFF102C24), Color(0xFFB48237)])),
          Padding(padding: const EdgeInsets.only(right: 10), child: _eventCard('FESTIVAL DE JAZZ', 'EM BREVE', 'Música entre montanhas.', '🎷', const [Color(0xFF1B2446), Color(0xFF7B4A85)])),
        ],
      ),
    );
  }

  Widget _eventCard(String title, String date, String subtitle, String emoji, List<Color> colors) {
    return InkWell(
      onTap: () => setState(() => tab = 3),
      borderRadius: BorderRadius.circular(27),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(27)),
        child: Stack(children: [
          Positioned(right: 18, bottom: -2, child: Text(emoji, style: const TextStyle(fontSize: 92))),
          Positioned(right: -35, top: -45, child: Container(width: 145, height: 145, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .07), shape: BoxShape.circle))),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: brandYellow, borderRadius: BorderRadius.circular(10)), child: Text(date, style: const TextStyle(color: brandInk, fontSize: 9, fontWeight: FontWeight.w900))),
            const SizedBox(height: 9),
            SizedBox(width: 220, child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, height: 1.02, fontWeight: FontWeight.w900))),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ])),
        ]),
      ),
    );
  }

  Widget home(List<Store> stores) {
    final spotlight = stores.where((s) => s.isOpen).toList();
    final featured = spotlight.isEmpty ? stores : spotlight;
    return RefreshIndicator(
      onRefresh: refreshAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(17, 11, 17, 30),
        children: [
          header(),
          const SizedBox(height: 16),
          GestureDetector(onTap: () => setState(() => tab = 1), child: const AbsorbPointer(child: TextField(decoration: InputDecoration(hintText: 'O que você procura no Vale?', prefixIcon: Icon(Icons.search_rounded))))),
          const SizedBox(height: 17),
          const Text('Tudo por aqui', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          categoryRail(),
          const SizedBox(height: 4),
          topBannerRail(stores),
          const SizedBox(height: 23),
          const Text('Do seu jeito, hoje', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text('Escolhas rápidas para entrar no clima.', style: TextStyle(color: brandMuted, fontSize: 11.5)),
          const SizedBox(height: 12),
          occasionRail(),
          const SizedBox(height: 22),
          walletStrip(),
          const SizedBox(height: 26),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Queridinhos do Vale', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), Text('${stores.length} parceiros', style: const TextStyle(color: brandRed, fontSize: 10.5, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 11),
          SizedBox(height: 105, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: featured.length, separatorBuilder: (_, __) => const SizedBox(width: 11), itemBuilder: (_, i) => storeCard(featured[i]))),
          const SizedBox(height: 27),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('O Vale acontece', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), Text('Agenda', style: TextStyle(color: brandRed, fontSize: 10.5, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 5),
          const Text('Eventos, cultura e encontros para sair do automático.', style: TextStyle(color: brandMuted, fontSize: 11.5)),
          const SizedBox(height: 12),
          eventRail(),
          const SizedBox(height: 27),
          const Text('Mais do que delivery', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _miniExplore('Hospedagens', '🏡', const Color(0xFFE7EEFF))),
            const SizedBox(width: 10),
            Expanded(child: _miniExplore('Experiências', '🥾', const Color(0xFFE0F4EF))),
            const SizedBox(width: 10),
            Expanded(child: _miniExplore('Eventos', '🎫', const Color(0xFFFFE2EC))),
          ]),
          const SizedBox(height: 26),
          const Text('Parceiros do Capão', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ...stores.map((s) => _merchantRow(s)),
        ],
      ),
    );
  }

  Widget _miniExplore(String title, String emoji, Color bg) {
    return InkWell(
      onTap: () => setState(() => tab = 3),
      borderRadius: BorderRadius.circular(21),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(21)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(emoji, style: const TextStyle(fontSize: 32)), Text(title, maxLines: 2, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, height: 1.05))]),
      ),
    );
  }

  Widget _merchantRow(Store s) {
    return InkWell(
      onTap: () => openStore(s),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Container(width: 64, height: 64, padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0x11000000))), child: ClipOval(child: storeLogo(s, size: 54))),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('${s.estimatedMinutes} min • Frete ${money(s.deliveryFee)}', style: const TextStyle(fontSize: 10.5, color: brandMuted)), const SizedBox(height: 5), Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFE5FFF1), borderRadius: BorderRadius.circular(8)), child: const Text('+ ValeCoin', style: TextStyle(color: brandGreen, fontSize: 8.5, fontWeight: FontWeight.w900))), const SizedBox(width: 6), Text(s.isOpen ? 'Aberto agora' : 'Fechado', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: s.isOpen ? brandGreen : brandRed))])])),
          const Icon(Icons.chevron_right_rounded, color: brandMuted),
        ]),
      ),
    );
  }

  Widget searchPage(List<Store> stores) {
    final q = search.text.trim().toLowerCase();
    final filtered = q.isEmpty ? stores : stores.where((s) => s.name.toLowerCase().contains(q) || s.description.toLowerCase().contains(q)).toList();
    return ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Buscar no Vale', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
      const SizedBox(height: 14),
      TextField(controller: search, autofocus: true, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Café, pizza, mercado, serviço...', prefixIcon: Icon(Icons.search_rounded))),
      const SizedBox(height: 18),
      ...filtered.map(_merchantRow),
    ]);
  }

  Widget explorePage() {
    return ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Explore o Vale', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
      const SizedBox(height: 5),
      const Text('Hospedagens, experiências, eventos e serviços locais.', style: TextStyle(color: brandMuted)),
      const SizedBox(height: 20),
      eventRail(),
      const SizedBox(height: 20),
      _heroCard(title: 'Durma perto\ndas montanhas.', subtitle: 'Hospedagens para viver o Vale no seu ritmo.', tag: 'HOSPEDAGENS', colors: const [Color(0xFF294D3A), Color(0xFF6E9D72)], emoji: '🏡'),
      const SizedBox(height: 13),
      _heroCard(title: 'Viva o Vale\npor dentro.', subtitle: 'Trilhas, terapias, cultura e experiências locais.', tag: 'EXPERIÊNCIAS', colors: const [Color(0xFF244D58), Color(0xFF54A9A3)], emoji: '🥾'),
    ]);
  }

  Widget placeholderPage(String title, String subtitle, IconData icon) {
    return Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(radius: 34, backgroundColor: brandRedSoft, child: Icon(icon, color: brandRed, size: 32)), const SizedBox(height: 16), Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: brandMuted))])));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Store>>(
      future: storesFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (snap.hasError) return Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Não foi possível carregar os parceiros.\n${snap.error}', textAlign: TextAlign.center))));
        final stores = snap.data ?? [];
        final pages = [
          home(stores),
          searchPage(stores),
          placeholderPage('Pedidos', 'Acompanhe pedidos em andamento e reveja compras anteriores.', Icons.receipt_long_rounded),
          explorePage(),
          placeholderPage('Minha conta', 'ValeCoin, endereços, cupons e preferências.', Icons.person_rounded),
        ];
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

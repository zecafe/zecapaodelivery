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
  late Future<List<Store>> storesFuture;
  late Future<List<CampaignBanner>> bannersFuture;
  late Future<ValeCoinBalance> walletFuture;

  @override
  void initState() {
    super.initState();
    storesFuture = repo.stores();
    bannersFuture = repo.banners();
    walletFuture = repo.valecoinBalance(widget.phone);
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

  Widget banners() => FutureBuilder<List<CampaignBanner>>(
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
                return Container(
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
                              Text(b.subtitle, style: TextStyle(color: fg.withValues(alpha: .9), fontSize: 14)),
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
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => ValeCoinWalletPage(phone: widget.phone, repo: repo)));
              if (mounted) setState(() => walletFuture = repo.valecoinBalance(widget.phone));
            },
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Salve, ${widget.customerName}!', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const Text('Vale do Capão • BA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ]),
          actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.notifications_none))],
        ),
        body: RefreshIndicator(
          onRefresh: refreshAll,
          child: FutureBuilder<List<Store>>(
            future: storesFuture,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return ListView(children: const [SizedBox(height: 280), Center(child: CircularProgressIndicator())]);
              }
              if (snap.hasError) return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('Erro: ${snap.error}'))]);
              final stores = snap.data ?? [];
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'O que você quer pedir hoje?',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  banners(),
                  const SizedBox(height: 18),
                  walletCard(),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Parceiros do Capão', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    Text('${stores.length} lugares', style: const TextStyle(color: red, fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 10),
                  ...stores.map((store) => InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: store.isOpen
                            ? () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => StorePage(store: store, customerName: widget.customerName, phone: widget.phone, repo: repo)));
                                if (mounted) setState(() => walletFuture = repo.valecoinBalance(widget.phone));
                              }
                            : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                          child: Column(
                            children: [
                              if (store.coverUrl.isNotEmpty)
                                SizedBox(height: 118, width: double.infinity, child: Image.network(store.coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: remoteOrAsset(store.logoUrl, store.localLogo, width: 64, height: 64, fit: BoxFit.contain),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: [
                                        Expanded(child: Text(store.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
                                        Text(store.isOpen ? 'ABERTO' : 'FECHADO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: store.isOpen ? green : red)),
                                      ]),
                                      const SizedBox(height: 4),
                                      Text(store.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
                                      const SizedBox(height: 6),
                                      Text('${store.estimatedMinutes} min • Entrega ${money(store.deliveryFee)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                    ]),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              );
            },
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'zecapao_brand.dart';
import 'zecapao_catalog.dart';

class ZecapaoHomePreview extends StatelessWidget {
  const ZecapaoHomePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              sliver: SliverList.list(children: [
                _Header(),
                const SizedBox(height: 22),
                Text('O que você\nprecisa hoje?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: ZecapaoBrand.graphite)),
                const SizedBox(height: 7),
                const Row(children: [Icon(Icons.location_on_rounded, color: ZecapaoBrand.red, size: 18), SizedBox(width: 4), Text('Vale do Capão • BA')]),
                const SizedBox(height: 18),
                const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar produtos, lojas, serviços...')),
                const SizedBox(height: 22),
                _CategoryGrid(),
                const SizedBox(height: 24),
                _EventBanner(),
                const SizedBox(height: 26),
                _SectionTitle('Do Vale pra você'),
                const SizedBox(height: 12),
                _PartnersStrip(),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Busca'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Pedidos'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Conta'),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(children: [
        Image.asset('assets/zecapao/zecapao_icon.png', width: 38, height: 38),
        const SizedBox(width: 10),
        const Expanded(child: Text('ZÉ CAPÃO\nDELIVERY', style: TextStyle(fontWeight: FontWeight.w900, height: .9, letterSpacing: .8))),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
      ]);
}

class _CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 10,
        childAspectRatio: .82,
        children: ZecapaoCatalog.categories.map((c) => Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: ZecapaoBrand.lightSurface, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(c.emoji, style: const TextStyle(fontSize: 23)), const SizedBox(height: 5), Text(c.name, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600))]),
        )).toList(),
      );
}

class _EventBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(alignment: Alignment.bottomLeft, children: [
          AspectRatio(aspectRatio: 1.95, child: Image.asset('assets/zecapao/events/capao_reggae_vale.jpg', fit: BoxFit.cover)),
          Container(padding: const EdgeInsets.all(14), width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87])), child: const Text('Eventos do Vale  •  Ver agenda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ]),
      );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), const Text('Ver todos', style: TextStyle(color: ZecapaoBrand.red, fontWeight: FontWeight.w700))]);
}

class _PartnersStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 142,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: ZecapaoCatalog.partners.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final p = ZecapaoCatalog.partners[i];
            return SizedBox(width: 112, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.asset(p.asset, width: 112, height: 92, fit: BoxFit.cover)),
              const SizedBox(height: 7),
              Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ]));
          },
        ),
      );
}

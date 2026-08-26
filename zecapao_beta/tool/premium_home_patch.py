from pathlib import Path
import re

p = Path('lib/catalog/showcase_home.dart')
s = p.read_text()

cat = """  Widget _categories() {
    return FutureBuilder<List<CategoryItem>>(
      future: repo.categories(),
      builder: (_, snap) {
        final items = snap.data ?? <CategoryItem>[];
        if (items.isEmpty) {
          return const SizedBox(height: 70, child: Center(child: Text('Categorias em atualização', style: TextStyle(color: brandMuted))));
        }
        return SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final x = items[i];
              return InkWell(
                onTap: () => openCategory(x.name),
                borderRadius: BorderRadius.circular(23),
                child: SizedBox(
                  width: 76,
                  child: Column(children: [
                    Container(
                      width: 70,
                      height: 70,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(23), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 16, offset: Offset(0, 9))]),
                      child: x.icon.startsWith('http')
                          ? Image.network(x.icon, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.grid_view_rounded, color: brandRed, size: 34))
                          : const Icon(Icons.grid_view_rounded, color: brandRed, size: 34),
                    ),
                    const SizedBox(height: 9),
                    Text(x.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                  ]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _zecafeHero"""
s, n = re.subn(r"  Widget _categories\(\) \{.*?\n  \}\n\n  Widget _zecafeHero", cat, s, count=1, flags=re.S)
if n != 1:
    raise SystemExit('premium categories block not found')

hero = """  Widget _zecafeHero(List<Store> stores) {
    Store? zecafe;
    for (final st in stores) { if (st.slug == 'zecafe') zecafe = st; }
    final zecafeStore = zecafe;
    return FutureBuilder<List<CampaignBanner>>(
      future: repo.banners(),
      builder: (_, snap) {
        final live = (snap.data ?? <CampaignBanner>[]).where((b) => b.imageUrl.isNotEmpty).toList();
        if (live.isNotEmpty) {
          return SizedBox(
            height: 204,
            child: PageView.builder(
              controller: PageController(viewportFraction: .96),
              itemCount: live.length,
              itemBuilder: (_, i) {
                final b = live[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(29),
                    child: Stack(fit: StackFit.expand, children: [
                      Image.network(b.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: hexColor(b.backgroundHex, brandRed))),
                      Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xB8000000), Color(0x22000000)], begin: Alignment.centerLeft, end: Alignment.centerRight))),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(b.title, maxLines: 2, style: TextStyle(color: hexColor(b.textHex, Colors.white), fontSize: 27, height: 1.02, fontWeight: FontWeight.w900)),
                          if (b.subtitle.isNotEmpty) ...[const SizedBox(height: 7), SizedBox(width: 250, child: Text(b.subtitle, maxLines: 2, style: const TextStyle(color: Colors.white70, fontSize: 11.5)))],
                          if (b.ctaLabel.isNotEmpty) ...[const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8), decoration: BoxDecoration(color: brandYellow, borderRadius: BorderRadius.circular(13)), child: Text(b.ctaLabel, style: const TextStyle(color: brandInk, fontSize: 10, fontWeight: FontWeight.w900)))],
                        ]),
                      ),
                    ]),
                  ),
                );
              },
            ),
          );
        }
        if (zecafeStore != null && zecafeStore.coverUrl.isNotEmpty) {
          return InkWell(onTap: () => openStore(zecafeStore), borderRadius: BorderRadius.circular(29), child: ClipRRect(borderRadius: BorderRadius.circular(29), child: Image.network(zecafeStore.coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 204, color: const Color(0xFF715441), alignment: Alignment.center, child: const Text('Zecafé', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900))))));
        }
        return Container(height: 204, decoration: BoxDecoration(color: const Color(0xFF715441), borderRadius: BorderRadius.circular(29)), alignment: Alignment.center, child: const Text('Zecafé', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)));
      },
    );
  }

  Widget _partnerRail"""
s, n = re.subn(r"  Widget _zecafeHero\(List<Store> stores\) \{.*?\n  \}\n\n  Widget _partnerRail", hero, s, count=1, flags=re.S)
if n != 1:
    raise SystemExit('premium hero block not found')

partners = """  Widget _partnerRail(List<Store> stores) {
    return FutureBuilder<List<Store>>(
      future: repo.featuredStores(),
      builder: (_, snap) {
        final items = snap.data ?? <Store>[];
        if (items.isEmpty) return Container(height: 120, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: const Text('Parceiros em destaque em atualização', style: TextStyle(color: brandMuted)));
        return SizedBox(
          height: 152,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final store = items[i];
              return InkWell(
                onTap: () => openStore(store),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 132,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 16, offset: Offset(0, 8))]),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ClipRRect(borderRadius: BorderRadius.circular(17), child: SizedBox(width: 78, height: 78, child: store.logoUrl.isNotEmpty ? Image.network(store.logoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset(store.localLogo, fit: BoxFit.cover)) : Image.asset(store.localLogo, fit: BoxFit.cover))),
                    const SizedBox(height: 8),
                    Text(store.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  ]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _brandTile"""
s, n = re.subn(r"  Widget _partnerRail\(List<Store> stores\) \{.*?\n  \}\n\n  Widget _brandTile", partners, s, count=1, flags=re.S)
if n != 1:
    raise SystemExit('premium partner rail block not found')

# Keep the original premium event rail for visual parity. The workflow removes only
# the malformed legacy occasion widget after this patch, before analyze/build.
p.write_text(s)
print('Premium Home restored: dynamic categories + banners + featured partners')

import 'package:flutter/material.dart';
import 'core.dart';
import 'checkout.dart';

class MerchantStoreV2Page extends StatefulWidget {
  final Store store;
  final String customerName;
  final String phone;
  final Repo repo;

  const MerchantStoreV2Page({
    super.key,
    required this.store,
    required this.customerName,
    required this.phone,
    required this.repo,
  });

  @override
  State<MerchantStoreV2Page> createState() => _MerchantStoreV2PageState();
}

class _MerchantStoreV2PageState extends State<MerchantStoreV2Page> {
  late Future<List<Product>> future;
  final cart = <String, CartLine>{};
  String category = 'Todos';

  @override
  void initState() {
    super.initState();
    future = widget.repo.products(widget.store.id);
  }

  double get subtotal => cart.values.fold(0.0, (sum, line) => sum + line.total);
  int get count => cart.values.fold(0, (sum, line) => sum + line.quantity);

  Widget merchantLogo({double size = 76}) {
    final local = Image.asset(
      widget.store.localLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.storefront_rounded, color: brandRed),
    );
    if (widget.store.logoUrl.isEmpty) return local;
    return Image.network(
      widget.store.logoUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => local,
    );
  }

  Widget placeholderHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [brandRed, Color(0xFFFF8A2B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -30, top: 10, child: Icon(Icons.landscape_rounded, size: 190, color: Colors.white24)),
          Positioned(left: 24, bottom: 28, child: Text(widget.store.name, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  Widget productImage(Product product, {double width = 132, double height = 118, BorderRadius? radius}) {
    final border = radius ?? BorderRadius.circular(22);
    if (product.imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFEFE7), brandBeige]),
          borderRadius: border,
        ),
        child: const Icon(Icons.restaurant_menu_rounded, color: brandRed, size: 38),
      );
    }
    return ClipRRect(
      borderRadius: border,
      child: Image.network(
        product.imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: brandBeige,
          child: const Icon(Icons.restaurant_menu_rounded, color: brandRed, size: 38),
        ),
      ),
    );
  }

  void add(Product product) {
    setState(() {
      cart.update(
        product.id,
        (line) {
          line.quantity++;
          return line;
        },
        ifAbsent: () => CartLine(product),
      );
    });
  }

  Widget headerCard() {
    return Transform.translate(
      offset: const Offset(0, -38),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Color(0x17000000), blurRadius: 24, offset: Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: const Offset(0, -34),
                  child: Container(
                    width: 82,
                    height: 82,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 7))],
                    ),
                    child: ClipOval(child: merchantLogo(size: 68)),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(widget.store.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.store.isOpen ? const Color(0xFFE6F7ED) : brandRedSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.store.isOpen ? 'ABERTO' : 'FECHADO',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: widget.store.isOpen ? brandGreen : brandRed),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(widget.store.description.isEmpty ? 'Parceiro local do Vale do Capão.' : widget.store.description, style: const TextStyle(color: brandMuted, fontSize: 12, height: 1.4)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _infoPill(Icons.star_rounded, '4,9'),
                        _infoPill(Icons.schedule_rounded, '${widget.store.estimatedMinutes} min'),
                        _infoPill(Icons.delivery_dining_rounded, 'Frete ${money(widget.store.deliveryFee)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: appBg, borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: brandInk), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700))]),
    );
  }

  Widget benefitsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      child: Row(
        children: [
          Expanded(child: _benefit(Icons.savings_rounded, 'VALECOIN', '1% a 3% de volta', brandYellow, brandInk)),
          const SizedBox(width: 10),
          Expanded(child: _benefit(Icons.local_offer_rounded, 'BENEFÍCIO', 'Ofertas do parceiro', const Color(0xFFE6F7ED), brandGreen)),
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String title, String subtitle, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [Icon(icon, color: fg), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 9, color: fg, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700))]))]),
    );
  }

  Widget highlights(List<Product> featured) {
    if (featured.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Destaques', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900))),
        const SizedBox(height: 12),
        SizedBox(
          height: 228,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final p = featured[i];
              return InkWell(
                onTap: () => add(p),
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  width: 172,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          productImage(p, width: 172, height: 154),
                          if (p.badge.isNotEmpty)
                            Positioned(
                              left: 9,
                              top: 9,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(color: brandInk.withValues(alpha: .82), borderRadius: BorderRadius.circular(12)),
                                child: Text(p.badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(money(p.price), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, height: 1.2)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget categoryRail(List<String> categories) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = categories[i];
          final selected = c == category;
          return ChoiceChip(
            label: Text(c),
            selected: selected,
            onSelected: (_) => setState(() => category = c),
            labelStyle: TextStyle(color: selected ? Colors.white : brandInk, fontWeight: FontWeight.w800),
          );
        },
      ),
    );
  }

  Widget productRow(Product p) {
    return InkWell(
      onTap: () => add(p),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.badge.isNotEmpty) ...[
                    Text(p.badge.toUpperCase(), style: const TextStyle(color: brandRed, fontSize: 9, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                  ],
                  Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(p.description.isEmpty ? 'Produto do parceiro.' : p.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: brandMuted, fontSize: 11.5, height: 1.35)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(money(p.price), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFE6F7ED), borderRadius: BorderRadius.circular(10)),
                        child: Text('+${cashbackCoins(p.price)} VC', style: const TextStyle(fontSize: 9, color: brandGreen, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                productImage(p, width: 118, height: 104, radius: BorderRadius.circular(20)),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: brandRed),
                    onPressed: () => add(p),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyCatalog() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26)),
        child: const Column(
          children: [
            CircleAvatar(radius: 34, backgroundColor: brandBeige, child: Icon(Icons.menu_book_rounded, size: 34, color: brandRed)),
            SizedBox(height: 16),
            Text('Cardápio em preparação', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            SizedBox(height: 7),
            Text('Este parceiro já está no Zé Capão. As fotos e produtos serão administrados pelo próprio estabelecimento.', textAlign: TextAlign.center, style: TextStyle(color: brandMuted, height: 1.45)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                color: Colors.white,
                child: FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(
                        store: widget.store,
                        customerName: widget.customerName,
                        phone: widget.phone,
                        repo: widget.repo,
                        items: cart.values.toList(),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)), child: Text('$count', style: const TextStyle(fontWeight: FontWeight.w900))),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('VER CARRINHO')),
                      Text(money(subtotal), style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
            ),
      body: FutureBuilder<List<Product>>(
        future: future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Não foi possível carregar o cardápio.\n${snap.error}', textAlign: TextAlign.center));
          final products = snap.data ?? [];
          final categories = ['Todos', ...{for (final p in products) if (p.category.isNotEmpty) p.category}];
          final filtered = category == 'Todos' ? products : products.where((p) => p.category == category).toList();
          final featured = products.where((p) => p.featured).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 245,
                pinned: true,
                backgroundColor: brandInk,
                foregroundColor: Colors.white,
                actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)), IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_rounded))],
                flexibleSpace: FlexibleSpaceBar(
                  background: widget.store.coverUrl.isEmpty
                      ? placeholderHero()
                      : Image.network(widget.store.coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholderHero()),
                ),
              ),
              SliverToBoxAdapter(child: headerCard()),
              SliverToBoxAdapter(child: benefitsBar()),
              if (products.isEmpty)
                SliverToBoxAdapter(child: emptyCatalog())
              else ...[
                SliverToBoxAdapter(child: highlights(featured)),
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 10), child: Text('Cardápio', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)))),
                SliverToBoxAdapter(child: categoryRail(categories)),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (_, i) => productRow(filtered[i]),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ],
          );
        },
      ),
    );
  }
}

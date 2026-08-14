import 'package:flutter/material.dart';
import 'core.dart';
import 'checkout.dart';

class StorePage extends StatefulWidget {
  final Store store;
  final String customerName, phone;
  final Repo repo;
  const StorePage({super.key, required this.store, required this.customerName, required this.phone, required this.repo});
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late Future<List<Product>> future;
  final cart = <String, CartLine>{};
  String selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    future = widget.repo.products(widget.store.id);
  }

  double get subtotal => cart.values.fold(0, (s, e) => s + e.total);
  int get count => cart.values.fold(0, (s, e) => s + e.quantity);

  void add(Product p) {
    setState(() => cart.update(p.id, (e) { e.quantity++; return e; }, ifAbsent: () => CartLine(p)));
  }

  Widget productImage(Product p) {
    if (p.imageUrl.isEmpty) {
      return Container(width: 92, height: 92, decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.restaurant_menu, color: green, size: 34));
    }
    return ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(p.imageUrl, width: 92, height: 92, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 92, height: 92, color: cream, child: const Icon(Icons.restaurant_menu, color: green))));
  }

  Widget logo() {
    if (widget.store.logoUrl.isNotEmpty) {
      return Image.network(widget.store.logoUrl, width: 72, height: 72, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Image.asset(widget.store.localLogo, width: 72, height: 72, fit: BoxFit.contain));
    }
    return Image.asset(widget.store.localLogo, width: 72, height: 72, fit: BoxFit.contain);
  }

  Widget emptyCatalog() => Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: const Column(children: [
          CircleAvatar(radius: 34, backgroundColor: cream, child: Icon(Icons.menu_book_outlined, color: green, size: 34)),
          SizedBox(height: 14),
          Text('Cardápio em preparação', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          SizedBox(height: 6),
          Text('Este parceiro já faz parte do Zé Capão. Estamos finalizando produtos, fotos e valores para abrir os pedidos.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, height: 1.4)),
          SizedBox(height: 14),
          Text('VOLTE EM BREVE 🌵', style: TextStyle(color: red, fontWeight: FontWeight.w900)),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.store.name, style: const TextStyle(fontWeight: FontWeight.w900))),
        bottomNavigationBar: cart.isEmpty ? null : SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: FilledButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutPage(store: widget.store, customerName: widget.customerName, phone: widget.phone, repo: widget.repo, items: cart.values.toList()))),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), backgroundColor: green),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('$count', style: const TextStyle(fontWeight: FontWeight.w900)), const Text('VER CARRINHO', style: TextStyle(fontWeight: FontWeight.w900)), Text(money(subtotal), style: const TextStyle(fontWeight: FontWeight.w900))]),
        ))),
        body: FutureBuilder<List<Product>>(
          future: future,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snap.hasError) return Center(child: Text('Erro: ${snap.error}'));
            final products = snap.data ?? [];
            final categories = ['Todos', ...{for (final p in products) if (p.category.isNotEmpty) p.category}];
            final filtered = selectedCategory == 'Todos' ? products : products.where((p) => p.category == selectedCategory).toList();
            final featured = products.where((p) => p.featured).toList();

            return ListView(padding: EdgeInsets.zero, children: [
              if (widget.store.coverUrl.isNotEmpty) SizedBox(height: 180, width: double.infinity, child: Image.network(widget.store.coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    logo(),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.store.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(widget.store.description, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Text('${widget.store.estimatedMinutes} min • ${money(widget.store.deliveryFee)} entrega', style: const TextStyle(fontWeight: FontWeight.w700, color: green)),
                    ])),
                  ]),
                  if (products.isEmpty) emptyCatalog(),
                  if (products.isNotEmpty) ...[
                    if (featured.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text('Destaques', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      SizedBox(height: 190, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: featured.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) {
                        final p = featured[i];
                        return Container(width: 150, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: SizedBox(width: double.infinity, child: productImage(p))), const SizedBox(height: 6), Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)), Text(money(p.price), style: const TextStyle(color: green, fontWeight: FontWeight.w900))]));
                      })),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) {
                      final c = categories[i];
                      return ChoiceChip(label: Text(c), selected: selectedCategory == c, onSelected: (_) => setState(() => selectedCategory = c), selectedColor: green, labelStyle: TextStyle(color: selectedCategory == c ? Colors.white : Colors.black87, fontWeight: FontWeight.w800));
                    })),
                    const SizedBox(height: 20),
                    Text(selectedCategory == 'Todos' ? 'Cardápio' : selectedCategory, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    ...filtered.map((p) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (p.badge.isNotEmpty) Text(p.badge.toUpperCase(), style: const TextStyle(fontSize: 9, color: red, fontWeight: FontWeight.w900)), Text(p.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(p.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 8), Text(money(p.price), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: green))])),
                        const SizedBox(width: 10),
                        Stack(alignment: Alignment.bottomRight, children: [productImage(p), IconButton.filled(onPressed: () => add(p), icon: const Icon(Icons.add))]),
                      ]),
                    )),
                  ],
                ]),
              ),
            ]);
          },
        ),
      );
}

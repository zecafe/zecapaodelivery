import 'package:flutter/material.dart';
import 'core.dart';

class CheckoutPage extends StatelessWidget {
  final Store store;
  final String customerName;
  final String phone;
  final Repo repo;
  final List<CartLine> items;

  const CheckoutPage({
    super.key,
    required this.store,
    required this.customerName,
    required this.phone,
    required this.repo,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar pedido')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items.map((line) => ListTile(
          title: Text('${line.quantity}× ${line.product.name}'),
          subtitle: line.optionText.isEmpty ? null : Text(line.optionText),
          trailing: Text(money(line.total)),
        )).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'core.dart';

class ValeCoinWalletPage extends StatefulWidget {
  final String phone;
  final Repo repo;

  const ValeCoinWalletPage({super.key, required this.phone, required this.repo});

  @override
  State<ValeCoinWalletPage> createState() => _ValeCoinWalletPageState();
}

class _ValeCoinWalletPageState extends State<ValeCoinWalletPage> {
  late Future<ValeCoinBalance> balanceFuture;
  late Future<List<ValeCoinEntry>> statementFuture;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    balanceFuture = widget.repo.valecoinBalance(widget.phone);
    statementFuture = widget.repo.valecoinStatement(widget.phone);
  }

  Future<void> reload() async {
    setState(refresh);
    await Future.wait([balanceFuture, statementFuture]);
  }

  String date(DateTime value) {
    final d = value.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha ValeCoin', style: TextStyle(fontWeight: FontWeight.w900))),
      body: RefreshIndicator(
        onRefresh: reload,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<ValeCoinBalance>(
              future: balanceFuture,
              builder: (_, snap) {
                final wallet = snap.data ?? ValeCoinBalance.zero();
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SALDO DISPONÍVEL', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('${wallet.balanceCoins} VC', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
                      Text(valecoinMoney(wallet.balanceCoins), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      if (wallet.expiresNextAt != null) ...[
                        const SizedBox(height: 12),
                        Text('Próximo vencimento em ${date(wallet.expiresNextAt!)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(18)),
              child: const Text(
                'Como funciona: você recebe 1% a 3% de volta após a entrega. Os créditos valem por 90 dias e podem pagar até 30% dos produtos de uma nova compra. Uso mínimo: 100 VC.',
                style: TextStyle(height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Extrato', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            FutureBuilder<List<ValeCoinEntry>>(
              future: statementFuture,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator()));
                }
                final entries = snap.data ?? [];
                if (entries.isEmpty) {
                  return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Seu extrato ainda está vazio.')));
                }
                return Column(
                  children: entries.map((entry) {
                    final positive = entry.amountCoins >= 0;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: positive ? green : red,
                          child: Icon(positive ? Icons.add : Icons.remove, color: Colors.white),
                        ),
                        title: Text(entry.description.isEmpty ? (positive ? 'Cashback' : 'Uso de ValeCoins') : entry.description),
                        subtitle: Text('${date(entry.createdAt)}${entry.expiresAt == null ? '' : ' • vence ${date(entry.expiresAt!)}'}'),
                        trailing: Text(
                          '${positive ? '+' : ''}${entry.amountCoins} VC',
                          style: TextStyle(fontWeight: FontWeight.w900, color: positive ? green : red),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

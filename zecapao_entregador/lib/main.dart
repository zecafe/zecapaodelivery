import 'package:flutter/material.dart';

void main() {
  runApp(const ZeEntregadorApp());
}

class ZeEntregadorApp extends StatelessWidget {
  const ZeEntregadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zé Entregador',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFF4C430),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool online = false;
  int step = 0;

  final List<String> labels = const [
    'Nova entrega disponível',
    'Cheguei ao estabelecimento',
    'Pedido retirado',
    'Cheguei ao cliente',
    'Confirmar entrega',
    'Entrega concluída',
  ];

  String get actionLabel {
    if (step == 0) return 'ACEITAR ENTREGA';
    if (step == 5) return 'CONCLUÍDA';
    return labels[step];
  }

  void toggleOnline() {
    setState(() {
      online = !online;
      if (!online) step = 0;
    });
  }

  void advanceDelivery() {
    if (step >= labels.length - 1) return;
    setState(() => step++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Zé Entregador',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Painel do entregador',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Icon(
                        online ? Icons.delivery_dining : Icons.power_settings_new,
                        size: 60,
                      ),
                      Text(
                        online ? 'ONLINE' : 'OFFLINE',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: toggleOnline,
                        child: Text(
                          online ? 'FICAR OFFLINE' : 'FICAR ONLINE',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (online) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          labels[step],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Teste MVP • Vale do Capão\n'
                          'Corrida demonstrativa • R\$ 8,00',
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: step < labels.length - 1
                              ? advanceDelivery
                              : null,
                          child: Text(actionLabel),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'R\$ 0,00',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Ganhos hoje'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Entregas'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

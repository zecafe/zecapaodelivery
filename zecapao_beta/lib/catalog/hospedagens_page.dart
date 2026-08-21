import 'package:flutter/material.dart';
import 'core.dart';
import 'pousada_demo.dart';

class HospedagensPage extends StatelessWidget {
  const HospedagensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      appBar: AppBar(title: const Text('Hospedagens')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          const Text('Durma no Vale. Acorde dentro da paisagem.', style: TextStyle(fontSize: 26, height: 1.05, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Pousadas e refúgios selecionados para transformar estadia em experiência.', style: TextStyle(color: brandMuted, fontSize: 12.5, height: 1.45)),
          const SizedBox(height: 22),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PousadaDemoPage())),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 300,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(colors: [Color(0xFF53A9C4), Color(0xFF1C6A52)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 22, offset: Offset(0, 11))],
              ),
              child: Stack(children: [
                Positioned(left: -48, bottom: -18, child: Icon(Icons.landscape_rounded, size: 330, color: const Color(0xFF174F3E).withValues(alpha: .9))),
                Positioned(right: -38, bottom: -10, child: Icon(Icons.landscape_rounded, size: 250, color: const Color(0xFF3A7C56).withValues(alpha: .86))),
                Positioned(top: 20, left: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(14)), child: const Text('PARCEIRO DESTAQUE', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1)))),
                Positioned(left: 22, right: 22, bottom: 22, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Pousada do Capão', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Vale do Capão • Chapada Diamantina', style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  Row(children: [
                    _tag(Icons.star_rounded, '4,9'),
                    const SizedBox(width: 8),
                    _tag(Icons.local_cafe_rounded, 'Café da manhã'),
                    const Spacer(),
                    const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF0C6B5C))),
                  ]),
                ])),
              ]),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
            child: const Row(children: [
              CircleAvatar(backgroundColor: Color(0xFFE7F2ED), child: Icon(Icons.add_business_rounded, color: Color(0xFF0C6B5C))),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Mais hospedagens em breve', style: TextStyle(fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('O modelo está pronto para receber novos parceiros do Vale.', style: TextStyle(fontSize: 10.5, color: brandMuted))])),
            ]),
          ),
        ],
      ),
    );
  }

  static Widget _tag(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(color: Colors.black.withValues(alpha: .22), borderRadius: BorderRadius.circular(12)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: Colors.white), const SizedBox(width: 5), Text(text, style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800))]),
  );
}

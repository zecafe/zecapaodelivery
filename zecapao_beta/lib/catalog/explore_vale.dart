import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core.dart';

class ExploreValePage extends StatefulWidget {
  const ExploreValePage({super.key});
  @override
  State<ExploreValePage> createState() => _ExploreValePageState();
}

class _ExploreValePageState extends State<ExploreValePage> {
  final client = Supabase.instance.client;
  late Future<Map<String, List<Map<String, dynamic>>>> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<Map<String, List<Map<String, dynamic>>>> _load() async {
    final r = await Future.wait([
      client.from('attractions').select().eq('is_active', true).order('sort_order'),
      client.from('guides').select().eq('is_active', true).order('sort_order'),
    ]);
    return {
      'attractions': (r[0] as List).map((e) => Map<String, dynamic>.from(e)).toList(),
      'guides': (r[1] as List).map((e) => Map<String, dynamic>.from(e)).toList(),
    };
  }

  IconData _kind(String k) => switch (k) {
        'cachoeira' => Icons.waterfall_chart_rounded,
        'guia' => Icons.explore_rounded,
        'passeio' => Icons.directions_car_rounded,
        'bem-estar' => Icons.spa_rounded,
        _ => Icons.hiking_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      appBar: AppBar(title: const Text('Explore o Vale')),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final attractions = snap.data?['attractions'] ?? [];
          final guides = snap.data?['guides'] ?? [];
          return RefreshIndicator(
            onRefresh: () async => setState(() => future = _load()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 34),
              children: [
                const Text('O que você quer viver hoje?', style: TextStyle(fontSize: 28, height: 1.02, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                const Text('Trilhas, cachoeiras, guias e experiências para descobrir o Vale do Capão.', style: TextStyle(color: brandMuted, height: 1.4)),
                const SizedBox(height: 22),
                SizedBox(
                  height: 106,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _shortcut('Trilhas', Icons.hiking_rounded),
                      _shortcut('Cachoeiras', Icons.waterfall_chart_rounded),
                      _shortcut('Guias', Icons.explore_rounded),
                      _shortcut('Experiências', Icons.auto_awesome_rounded),
                      _shortcut('Passeios', Icons.directions_car_rounded),
                      _shortcut('Bem-estar', Icons.spa_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Descubra lugares', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                if (attractions.isEmpty)
                  _empty('Atrativos em atualização')
                else
                  ...attractions.map((a) => _attraction(context, a, guides)),
                const SizedBox(height: 24),
                const Text('Guias locais', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                if (guides.isEmpty)
                  _empty('Guias em atualização')
                else
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: guides.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => _guide(guides[i]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _shortcut(String t, IconData i) => Container(
        width: 88,
        margin: const EdgeInsets.only(right: 10),
        child: Column(children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Icon(i, color: brandRed, size: 33)),
          const SizedBox(height: 7),
          Text(t, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
        ]),
      );

  Widget _empty(String t) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Text(t, style: const TextStyle(color: brandMuted)),
      );

  Widget _attraction(BuildContext context, Map<String, dynamic> a, List<Map<String, dynamic>> guides) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttractionDetailPage(attraction: a, guides: guides))),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            clipBehavior: Clip.antiAlias,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 170,
                width: double.infinity,
                child: (a['image_url'] ?? '').toString().isNotEmpty
                    ? Image.network('${a['image_url']}', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: brandBeige, child: Icon(_kind('${a['kind']}'), size: 54, color: brandRed)))
                    : Container(color: brandBeige, child: Icon(_kind('${a['kind']}'), size: 54, color: brandRed)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${a['name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text('${a['description'] ?? ''}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: brandMuted, fontSize: 12, height: 1.35)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    if ('${a['difficulty'] ?? ''}'.isNotEmpty) _pill(Icons.terrain_rounded, '${a['difficulty']}'),
                    if ('${a['duration_text'] ?? ''}'.isNotEmpty) _pill(Icons.schedule_rounded, '${a['duration_text']}'),
                    if (a['guide_recommended'] == true) _pill(Icons.explore_rounded, 'Guia recomendado'),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      );

  Widget _pill(IconData i, String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: appBg, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 14, color: brandRed), const SizedBox(width: 4), Text(t, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800))]),
      );

  Widget _guide(Map<String, dynamic> g) => Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Column(children: [
          CircleAvatar(
            radius: 37,
            backgroundColor: brandBeige,
            backgroundImage: (g['image_url'] ?? '').toString().isNotEmpty ? NetworkImage('${g['image_url']}') : null,
            child: (g['image_url'] ?? '').toString().isEmpty ? const Icon(Icons.person_rounded, color: brandRed, size: 34) : null,
          ),
          const SizedBox(height: 8),
          Text('${g['name']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('${g['bio'] ?? 'Guia local'}', maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, color: brandMuted)),
        ]),
      );
}

class AttractionDetailPage extends StatelessWidget {
  final Map<String, dynamic> attraction;
  final List<Map<String, dynamic>> guides;
  const AttractionDetailPage({super.key, required this.attraction, required this.guides});

  Future<void> _guide(BuildContext context) async {
    if (guides.isEmpty) return;
    final g = guides.first;
    final phone = '${g['whatsapp'] ?? g['phone'] ?? ''}'.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) return;
    final u = Uri.parse('https://wa.me/55$phone?text=${Uri.encodeComponent('Olá! Quero informações para visitar ${attraction['name']}.')}');
    await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final image = (attraction['image_url'] ?? '').toString();
    final guideRecommended = attraction['guide_recommended'] == true;
    return Scaffold(
      backgroundColor: appBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: image.isNotEmpty ? Image.network(image, fit: BoxFit.cover) : Container(color: brandBeige),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${attraction['name']}', style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('${attraction['description'] ?? ''}', style: const TextStyle(color: brandMuted, height: 1.5)),
                const SizedBox(height: 18),
                if ('${attraction['location_text'] ?? ''}'.isNotEmpty)
                  ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.location_on_rounded, color: brandRed), title: Text('${attraction['location_text']}')),
                if ('${attraction['difficulty'] ?? ''}'.isNotEmpty)
                  ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.terrain_rounded, color: brandRed), title: Text('Dificuldade: ${attraction['difficulty']}')),
                if ('${attraction['duration_text'] ?? ''}'.isNotEmpty)
                  ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.schedule_rounded, color: brandRed), title: Text('Duração: ${attraction['duration_text']}')),
                if (guideRecommended)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: brandRedSoft, borderRadius: BorderRadius.circular(18)),
                    child: const Row(children: [
                      Icon(Icons.explore_rounded, color: brandRed),
                      SizedBox(width: 10),
                      Expanded(child: Text('Para este atrativo, recomendamos acompanhamento de um guia local.', style: TextStyle(fontWeight: FontWeight.w800))),
                    ]),
                  ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: guideRecommended
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: FilledButton.icon(onPressed: () => _guide(context), icon: const Icon(Icons.explore_rounded), label: const Text('ENCONTRAR UM GUIA')),
              ),
            )
          : null,
    );
  }
}

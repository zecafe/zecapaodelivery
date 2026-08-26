from pathlib import Path

p=Path('lib/catalog/showcase_home.dart')
s=p.read_text()

if "import 'explore_vale.dart';" not in s:
    s=s.replace("import 'category_hub.dart';", "import 'category_hub.dart';\nimport 'explore_vale.dart';",1)

s=s.replace("const Text('Mais do que delivery', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),",
            "const Text('O Vale na palma da mão', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),\n          const SizedBox(height: 4),\n          const Text('Muito mais que delivery. Um jeito mais fácil de viver o Vale.', style: TextStyle(fontSize: 12, color: brandMuted, fontWeight: FontWeight.w600)),",1)

old="""          Row(children: [
            Expanded(child: _miniExplore('Hospedagens', Icons.hotel_rounded, const Color(0xFFE6EEFF))),
            const SizedBox(width: 10),
            Expanded(child: _miniExplore('Experiências', Icons.hiking_rounded, const Color(0xFFE1F5EE))),
            const SizedBox(width: 10),
            Expanded(child: _miniExplore('Eventos', Icons.local_activity_rounded, const Color(0xFFFFE4EC))),
          ]),"""
new="""          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: 150, child: InkWell(borderRadius: BorderRadius.circular(21), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreValePage())), child: _miniExplore('Explore o Vale', Icons.landscape_rounded, const Color(0xFFE1F5EE)))),
                const SizedBox(width: 10),
                SizedBox(width: 150, child: InkWell(borderRadius: BorderRadius.circular(21), onTap: () => openCategory('Serviços'), child: _miniExplore('Serviços do Vale', Icons.handyman_rounded, const Color(0xFFFFE9D9)))),
                const SizedBox(width: 10),
                SizedBox(width: 150, child: InkWell(borderRadius: BorderRadius.circular(21), onTap: () => openCategory('Hospedagem'), child: _miniExplore('Hospedagens', Icons.hotel_rounded, const Color(0xFFE6EEFF)))),
                const SizedBox(width: 10),
                SizedBox(width: 150, child: InkWell(borderRadius: BorderRadius.circular(21), onTap: () => openCategory('Eventos'), child: _miniExplore('Viva o Capão', Icons.auto_awesome_rounded, const Color(0xFFFFE4EC)))),
                const SizedBox(width: 10),
                SizedBox(width: 150, child: InkWell(borderRadius: BorderRadius.circular(21), onTap: () => openCategory('Experiências'), child: _miniExplore('Experiências', Icons.hiking_rounded, const Color(0xFFE8F4E7)))),
              ],
            ),
          ),"""
if old not in s:
    raise SystemExit('legacy more-than-delivery block not found')
s=s.replace(old,new,1)
p.write_text(s)
print('Ecosystem carousel + Explore o Vale linked')

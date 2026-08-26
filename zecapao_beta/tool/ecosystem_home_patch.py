from pathlib import Path

p=Path('lib/catalog/showcase_home.dart')
s=p.read_text()
old="const Text('Mais do que delivery', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),"
new="const Text('O Vale na palma da mão', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),\n                const SizedBox(height: 4),\n                const Text('Muito mais que delivery. Um jeito mais fácil de viver o Vale.', style: TextStyle(fontSize: 12, color: brandMuted, fontWeight: FontWeight.w600)),"
if old in s:s=s.replace(old,new,1)
# Replace legacy three-card row when present.
oldrow="Row(children: [\n                  Expanded(child: _explore('Hospedagens', Icons.hotel_rounded, () => openCategory('Hospedagem'))),\n                  const SizedBox(width: 10),\n                  Expanded(child: _explore('Experiências', Icons.hiking_rounded, () => openCategory('Experiências'))),\n                  const SizedBox(width: 10),\n                  Expanded(child: _explore('Eventos', Icons.local_activity_rounded, () => openCategory('Eventos'))),\n                ]),"
newrow="SizedBox(height:126,child:ListView(scrollDirection:Axis.horizontal,children:[\n                  SizedBox(width:168,child:_explore('Explore o Vale',Icons.landscape_rounded,()=>openCategory('Explore o Vale'))),const SizedBox(width:10),\n                  SizedBox(width:168,child:_explore('Serviços do Vale',Icons.handyman_rounded,()=>openCategory('Serviços'))),const SizedBox(width:10),\n                  SizedBox(width:168,child:_explore('Perto de você',Icons.near_me_rounded,()=>openCategory('Perto de você'))),const SizedBox(width:10),\n                  SizedBox(width:168,child:_explore('ValeCoin',Icons.toll_rounded,()=>openCategory('ValeCoin'))),const SizedBox(width:10),\n                  SizedBox(width:168,child:_explore('Viva o Capão',Icons.auto_awesome_rounded,()=>openCategory('Eventos'))),\n                ])),"
if oldrow in s:s=s.replace(oldrow,newrow,1)
# Also handle compact formatting from restored home.
s=s.replace("_explore('Hospedagens', Icons.hotel_rounded, () => openCategory('Hospedagem'))","_explore('Explore o Vale', Icons.landscape_rounded, () => openCategory('Explore o Vale'))")
s=s.replace("_explore('Experiências', Icons.hiking_rounded, () => openCategory('Experiências'))","_explore('Serviços do Vale', Icons.handyman_rounded, () => openCategory('Serviços'))")
s=s.replace("_explore('Eventos', Icons.local_activity_rounded, () => openCategory('Eventos'))","_explore('Viva o Capão', Icons.auto_awesome_rounded, () => openCategory('Eventos'))")
p.write_text(s)
print('Ecosystem branding section applied')

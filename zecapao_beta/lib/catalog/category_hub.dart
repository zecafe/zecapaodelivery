import 'package:flutter/material.dart';
import 'core.dart';
import 'branded_store.dart';

class CategoryHubPage extends StatefulWidget {
  final String category;
  final String customerName;
  final String phone;
  final Repo repo;
  const CategoryHubPage({
    super.key,
    required this.category,
    required this.customerName,
    required this.phone,
    required this.repo,
  });

  @override
  State<CategoryHubPage> createState() => _CategoryHubPageState();
}

class _CategoryHubPageState extends State<CategoryHubPage> {
  late Future<List<_StoreMatch>> future;
  String selectedSub = 'Todos';
  bool onlyOpen = false;
  bool onlyPromo = false;
  bool mostOrdered = false;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  List<String> get subs {
    switch (widget.category.toLowerCase()) {
      case 'comida':
        return ['Todos','Pizza','Hambúrguer','Açaí','Restaurantes','Cafés','Doces'];
      case 'café':
        return ['Todos','Cafeterias','Espresso','Cappuccino','Doces','Brunch'];
      case 'pizza':
        return ['Todos','Artesanal','Clássicas','Vegetarianas','Delivery'];
      case 'mercado':
        return ['Todos','Mercados','Orgânicos','Bebidas','Mercearia','Conveniência'];
      case 'hospedagem':
      case 'hospedagens':
        return ['Todos','Pousadas','Hostels','Casas','Camping','Boutique'];
      case 'experiências':
        return ['Todos','Trilhas','Guias','Passeios','Bem-estar','Aventura'];
      case 'eventos':
        return ['Todos','Hoje','Música','Cultura','Gastronomia','Esporte'];
      default:
        return ['Todos'];
    }
  }

  Future<List<_StoreMatch>> _load() async {
    final stores = await widget.repo.stores();
    final out = <_StoreMatch>[];
    for (final store in stores) {
      List<Product> products = const [];
      try { products = await widget.repo.products(store.id); } catch (_) {}
      final tags = <String>{};
      for (final p in products) {
        tags.add(p.category.toLowerCase());
        tags.add(p.name.toLowerCase());
        if (p.featured) tags.add('featured');
      }
      final haystack = '${store.name} ${store.slug} ${store.description} ${tags.join(' ')}'.toLowerCase();
      if (_belongsToMain(haystack)) {
        final featured = products.where((p) => p.featured).toList();
        out.add(_StoreMatch(store: store, products: products, haystack: haystack, featured: featured));
      }
    }
    return out;
  }

  bool _belongsToMain(String h) {
    final c = widget.category.toLowerCase();
    if (c == 'comida') return _has(h,['pizza','burger','hamb','aça','acai','restaurante','comida','cozinha','café','cafe','doce','lanche']);
    if (c == 'café') return _has(h,['café','cafe','espresso','cappuccino','capuccino','coffee','brunch']);
    if (c == 'pizza') return _has(h,['pizza','pizzaria']);
    if (c == 'mercado') return _has(h,['mercado','mercearia','orgânico','organico','conveniência','conveniencia']);
    if (c == 'hospedagem' || c == 'hospedagens') return _has(h,['pousada','hotel','hostel','hosped','camping','chalé','chale']);
    if (c == 'experiências') return _has(h,['trilha','guia','passeio','experiência','experiencia','turismo','aventura','massagem','yoga']);
    if (c == 'eventos') return _has(h,['evento','festival','música','musica','show','cultura']);
    return true;
  }

  bool _has(String text, List<String> terms) => terms.any(text.contains);

  bool _matchesSub(_StoreMatch m) {
    if (selectedSub == 'Todos') return true;
    final s = selectedSub.toLowerCase();
    final map = <String,List<String>>{
      'hambúrguer':['burger','hamb'], 'açaí':['aça','acai'], 'restaurantes':['restaurante','comida','cozinha'],
      'cafés':['café','cafe'], 'cafeterias':['café','cafe'], 'doces':['doce','bolo','cookie','banoffee'],
      'espresso':['espresso'], 'cappuccino':['cappuccino','capuccino'], 'brunch':['brunch'],
      'artesanal':['artesanal'], 'clássicas':['pizza'], 'vegetarianas':['vegetar'], 'delivery':['pizza'],
      'mercados':['mercado'], 'orgânicos':['orgânico','organico'], 'bebidas':['bebida'], 'mercearia':['mercearia'], 'conveniência':['conveni'],
      'pousadas':['pousada'], 'hostels':['hostel'], 'casas':['casa'], 'camping':['camping'], 'boutique':['boutique'],
      'trilhas':['trilha'], 'guias':['guia'], 'passeios':['passeio'], 'bem-estar':['yoga','massagem','bem-estar'], 'aventura':['aventura'],
      'música':['música','musica','show'], 'cultura':['cultura'], 'gastronomia':['gastro','comida'], 'esporte':['corrida','bike','trail','esporte'],
    };
    return _has(m.haystack, map[s] ?? [s]);
  }

  List<_StoreMatch> _filtered(List<_StoreMatch> all) {
    var list = all.where(_matchesSub).toList();
    if (onlyOpen) list = list.where((e) => e.store.isOpen).toList();
    if (onlyPromo) list = list.where((e) => e.featured.isNotEmpty).toList();
    if (mostOrdered) {
      list.sort((a,b) {
        final af = a.featured.length + (a.store.slug == 'zecafe' ? 2 : 0);
        final bf = b.featured.length + (b.store.slug == 'zecafe' ? 2 : 0);
        return bf.compareTo(af);
      });
    }
    return list;
  }

  Color get accent {
    switch (widget.category.toLowerCase()) {
      case 'comida': return const Color(0xFFFF6A3D);
      case 'café': return const Color(0xFF8B5E3C);
      case 'pizza': return const Color(0xFFE8452C);
      case 'mercado': return const Color(0xFF2F9A62);
      case 'hospedagem': return const Color(0xFF5677C7);
      case 'experiências': return const Color(0xFF27866D);
      case 'eventos': return const Color(0xFFC84671);
      default: return brandRed;
    }
  }

  IconData get categoryIcon {
    switch (widget.category.toLowerCase()) {
      case 'comida': return Icons.lunch_dining_rounded;
      case 'café': return Icons.coffee_rounded;
      case 'pizza': return Icons.local_pizza_rounded;
      case 'mercado': return Icons.shopping_basket_rounded;
      case 'hospedagem': return Icons.hotel_rounded;
      case 'experiências': return Icons.hiking_rounded;
      case 'eventos': return Icons.local_activity_rounded;
      default: return Icons.grid_view_rounded;
    }
  }

  Future<void> _open(Store store) async {
    if (!store.isOpen) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => BrandedStorePage(
      store: store,
      customerName: widget.customerName,
      phone: widget.phone,
      repo: widget.repo,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: SafeArea(
        child: FutureBuilder<List<_StoreMatch>>(
          future: future,
          builder: (_, snap) {
            final all = snap.data ?? const <_StoreMatch>[];
            final items = _filtered(all);
            return RefreshIndicator(
              onRefresh: () async => setState(() => future = _load()),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(17,12,17,32),
                children: [
                  Row(children: [
                    IconButton.filledTonal(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.category, style: const TextStyle(fontSize: 27,fontWeight: FontWeight.w900)),
                      const Text('Descubra o melhor do Vale', style: TextStyle(color: brandMuted,fontSize: 11)),
                    ])),
                    Container(width:46,height:46,decoration:BoxDecoration(color:accent.withValues(alpha:.12),borderRadius:BorderRadius.circular(15)),child:Icon(categoryIcon,color:accent)),
                  ]),
                  const SizedBox(height:18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(25)),
                    child: Row(children:[
                      Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                        Text('Tudo de ${widget.category.toLowerCase()} em um só lugar',style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900,height:1.05)),
                        const SizedBox(height:6),
                        const Text('Escolha uma subcategoria ou explore os parceiros abaixo.',style:TextStyle(color:Colors.white70,fontSize:10.5)),
                      ])),
                      Icon(categoryIcon,color:Colors.white.withValues(alpha:.9),size:62),
                    ]),
                  ),
                  const SizedBox(height:22),
                  const Text('O que você procura?',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
                  const SizedBox(height:11),
                  SizedBox(height:42,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:subs.length,separatorBuilder:(_,__)=>const SizedBox(width:8),itemBuilder:(_,i){final s=subs[i],active=s==selectedSub;return ChoiceChip(label:Text(s),selected:active,onSelected:(_)=>setState(()=>selectedSub=s),selectedColor:accent.withValues(alpha:.16),labelStyle:TextStyle(color:active?accent:brandInk,fontWeight:FontWeight.w800,fontSize:11),side:BorderSide(color:active?accent:const Color(0xFFE5DED4)));})),
                  const SizedBox(height:16),
                  Wrap(spacing:8,runSpacing:8,children:[
                    FilterChip(label:const Text('Abertos agora'),avatar:const Icon(Icons.schedule_rounded,size:16),selected:onlyOpen,onSelected:(v)=>setState(()=>onlyOpen=v)),
                    FilterChip(label:const Text('Promoções'),avatar:const Icon(Icons.local_offer_outlined,size:16),selected:onlyPromo,onSelected:(v)=>setState(()=>onlyPromo=v)),
                    FilterChip(label:const Text('Mais pedidos'),avatar:const Icon(Icons.local_fire_department_outlined,size:16),selected:mostOrdered,onSelected:(v)=>setState(()=>mostOrdered=v)),
                  ]),
                  const SizedBox(height:24),
                  Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                    const Text('Parceiros',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900)),
                    Text('${items.length} encontrados',style:const TextStyle(color:brandMuted,fontSize:10.5,fontWeight:FontWeight.w700)),
                  ]),
                  const SizedBox(height:10),
                  if (snap.connectionState == ConnectionState.waiting)
                    const Padding(padding:EdgeInsets.all(40),child:Center(child:CircularProgressIndicator()))
                  else if (items.isEmpty)
                    Container(padding:const EdgeInsets.all(30),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22)),child:const Column(children:[Icon(Icons.search_off_rounded,size:42,color:brandMuted),SizedBox(height:8),Text('Nenhum parceiro encontrado neste filtro.',textAlign:TextAlign.center,style:TextStyle(color:brandMuted,fontWeight:FontWeight.w700))]))
                  else
                    ...items.map(_partnerCard),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _partnerCard(_StoreMatch m) {
    final s=m.store;
    final promo=m.featured.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom:11),
      child: InkWell(
        onTap: s.isOpen ? () => _open(s) : null,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(21),boxShadow:const [BoxShadow(color:Color(0x0D000000),blurRadius:16,offset:Offset(0,7))]),
          child: Row(children:[
            Container(width:68,height:68,padding:const EdgeInsets.all(5),decoration:BoxDecoration(color:const Color(0xFFF4F0E9),borderRadius:BorderRadius.circular(18)),child:ClipRRect(borderRadius:BorderRadius.circular(14),child:s.logoUrl.isNotEmpty?Image.network(s.logoUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Image.asset(s.localLogo,fit:BoxFit.cover)):Image.asset(s.localLogo,fit:BoxFit.cover))),
            const SizedBox(width:12),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Row(children:[Expanded(child:Text(s.name,style:const TextStyle(fontSize:14,fontWeight:FontWeight.w900))),Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:s.isOpen?const Color(0xFFE6F8ED):const Color(0xFFF3ECEA),borderRadius:BorderRadius.circular(99)),child:Text(s.isOpen?'ABERTO':'FECHADO',style:TextStyle(color:s.isOpen?const Color(0xFF207D49):brandMuted,fontSize:8,fontWeight:FontWeight.w900)))]),
              const SizedBox(height:5),
              Text(s.description.isEmpty?'Parceiro local do Vale do Capão':s.description,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:brandMuted,fontSize:9.5)),
              const SizedBox(height:7),
              Wrap(spacing:8,runSpacing:5,children:[
                _meta(Icons.schedule_rounded,'${s.estimatedMinutes} min'),
                _meta(Icons.delivery_dining_rounded,'Frete ${money(s.deliveryFee)}'),
                if(promo)_meta(Icons.local_offer_rounded,'Promoção',color:brandRed),
                if(m.featured.length>1)_meta(Icons.local_fire_department_rounded,'Mais pedidos',color:const Color(0xFFFF7A28)),
              ]),
            ])),
            const SizedBox(width:5),
            Icon(Icons.chevron_right_rounded,color:s.isOpen?brandInk:brandMuted),
          ]),
        ),
      ),
    );
  }

  Widget _meta(IconData icon,String text,{Color color=brandMuted}) => Row(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:13,color:color),const SizedBox(width:3),Text(text,style:TextStyle(color:color,fontSize:8.5,fontWeight:FontWeight.w700))]);
}

class _StoreMatch {
  final Store store;
  final List<Product> products;
  final String haystack;
  final List<Product> featured;
  const _StoreMatch({required this.store,required this.products,required this.haystack,required this.featured});
}

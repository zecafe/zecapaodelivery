import 'package:flutter/material.dart';
import 'core.dart';
import 'branded_store.dart';
import 'taxonomy.dart';

class CategoryHubPage extends StatefulWidget {
  final String category;
  final String customerName;
  final String phone;
  final Repo repo;
  const CategoryHubPage({super.key,required this.category,required this.customerName,required this.phone,required this.repo});
  @override State<CategoryHubPage> createState()=>_CategoryHubPageState();
}

class _CategoryHubPageState extends State<CategoryHubPage>{
  late Future<_HubData> future;
  String? selectedSubId;
  final search=TextEditingController();
  bool onlyOpen=false;

  @override void initState(){super.initState();future=_load();}
  @override void dispose(){search.dispose();super.dispose();}

  Future<_HubData> _load() async {
    final taxonomy=await loadCategoryTaxonomy(widget.category);
    final stores=await widget.repo.stores();
    final out=<_StoreMatch>[];
    for(final store in stores){
      List<Product> products=const[];
      try{products=await widget.repo.products(store.id);}catch(_){}
      final haystack='${store.name} ${store.slug} ${store.description} ${products.map((p)=>'${p.name} ${p.category}').join(' ')}'.toLowerCase();
      final explicit=taxonomy.primaryStoreIds.contains(store.id)||taxonomy.storeSubcategoryIds.containsKey(store.id);
      if(explicit||_legacyBelongs(haystack)){
        out.add(_StoreMatch(store:store,products:products,haystack:haystack,subIds:taxonomy.storeSubcategoryIds[store.id]??const{}));
      }
    }
    return _HubData(taxonomy:taxonomy,stores:out);
  }

  bool _legacyBelongs(String h){
    final c=widget.category.toLowerCase();
    bool has(List<String> terms)=>terms.any(h.contains);
    if(c=='comida')return has(['pizza','burger','hamb','aça','acai','restaurante','comida','cozinha','doce','lanche']);
    if(c=='café')return has(['café','cafe','espresso','cappuccino','coffee','brunch']);
    if(c=='pizza')return has(['pizza','pizzaria']);
    if(c=='mercado')return has(['mercado','mercearia','orgânico','organico','conveniência','conveniencia']);
    if(c=='hospedagem'||c=='hospedagens')return has(['pousada','hotel','hostel','hosped','camping','chalé','chale']);
    if(c=='experiências')return has(['trilha','guia','passeio','experiência','experiencia','turismo','aventura','massagem','yoga']);
    if(c=='eventos')return has(['evento','festival','música','musica','show','cultura']);
    if(c=='serviços'||c=='servicos')return has(['serviço','servico','turismo','transporte','massagem','manutenção','manutencao']);
    return false;
  }

  List<_StoreMatch> _filtered(_HubData data){
    var list=data.stores.where((m){
      if(selectedSubId!=null&&m.subIds.isNotEmpty&&!m.subIds.contains(selectedSubId))return false;
      final q=search.text.trim().toLowerCase();
      if(q.isNotEmpty&&!m.haystack.contains(q))return false;
      if(onlyOpen&&!m.store.isOpen)return false;
      return true;
    }).toList();
    return list;
  }

  Color get accent{switch(widget.category.toLowerCase()){
    case 'comida':return const Color(0xFFFF6A3D);case 'café':return const Color(0xFF8B5E3C);case 'pizza':return const Color(0xFFE8452C);case 'mercado':return const Color(0xFF2F9A62);case 'hospedagem':return const Color(0xFF5677C7);case 'experiências':return const Color(0xFF27866D);case 'eventos':return const Color(0xFFC84671);case 'serviços':return const Color(0xFF6553B8);default:return brandRed;}}

  IconData _icon(String key){switch(key){
    case 'bakery_dining':return Icons.bakery_dining_rounded;case 'lunch_dining':return Icons.lunch_dining_rounded;case 'restaurant':return Icons.restaurant_rounded;case 'cake':return Icons.cake_rounded;case 'eco':return Icons.eco_rounded;case 'coffee':return Icons.coffee_rounded;case 'brunch_dining':return Icons.brunch_dining_rounded;case 'local_pizza':return Icons.local_pizza_rounded;case 'shopping_basket':return Icons.shopping_basket_rounded;case 'local_drink':return Icons.local_drink_rounded;case 'hotel':return Icons.hotel_rounded;case 'bed':return Icons.bed_rounded;case 'house':return Icons.house_rounded;case 'hiking':return Icons.hiking_rounded;case 'explore':return Icons.explore_rounded;case 'tour':return Icons.tour_rounded;case 'music_note':return Icons.music_note_rounded;case 'theater_comedy':return Icons.theater_comedy_rounded;case 'sports':return Icons.sports_rounded;case 'directions_car':return Icons.directions_car_rounded;case 'spa':return Icons.spa_rounded;case 'handyman':return Icons.handyman_rounded;default:return Icons.grid_view_rounded;}}

  Future<void> _open(Store store)async{if(!store.isOpen)return;await Navigator.push(context,MaterialPageRoute(builder:(_)=>BrandedStorePage(store:store,customerName:widget.customerName,phone:widget.phone,repo:widget.repo)));}

  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor:Colors.white,body:SafeArea(child:FutureBuilder<_HubData>(future:future,builder:(_,snap){
      final data=snap.data;
      final items=data==null?< _StoreMatch>[]:_filtered(data);
      final subs=data?.taxonomy.subcategories??const<CatalogSubcategory>[];
      return RefreshIndicator(onRefresh:()async=>setState(()=>future=_load()),child:ListView(padding:const EdgeInsets.fromLTRB(18,12,18,34),children:[
        Row(children:[IconButton.filledTonal(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_back_rounded)),Expanded(child:Text(widget.category,textAlign:TextAlign.center,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900))),IconButton.filledTonal(onPressed:(){},icon:const Icon(Icons.menu_rounded))]),
        const SizedBox(height:20),
        TextField(controller:search,onChanged:(_)=>setState((){}),decoration:InputDecoration(hintText:'Buscar em ${widget.category}',prefixIcon:const Icon(Icons.search_rounded),filled:true,fillColor:const Color(0xFFF5F5F5),border:OutlineInputBorder(borderRadius:BorderRadius.circular(24),borderSide:BorderSide.none))),
        const SizedBox(height:22),
        if(subs.isNotEmpty)...[
          SizedBox(height:112,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:subs.length,separatorBuilder:(_,__)=>const SizedBox(width:12),itemBuilder:(_,i){final s=subs[i],active=s.id==selectedSubId;return InkWell(onTap:()=>setState(()=>selectedSubId=active?null:s.id),borderRadius:BorderRadius.circular(20),child:SizedBox(width:82,child:Column(children:[Container(width:76,height:76,decoration:BoxDecoration(color:active?accent.withValues(alpha:.18):const Color(0xFFF5F3EF),borderRadius:BorderRadius.circular(19),border:Border.all(color:active?accent:Colors.transparent,width:1.5)),child:s.imageUrl.isNotEmpty?ClipRRect(borderRadius:BorderRadius.circular(18),child:Image.network(s.imageUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Icon(_icon(s.icon),size:38,color:accent))):Icon(_icon(s.icon),size:38,color:accent)),const SizedBox(height:7),Text(s.name,maxLines:1,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,style:TextStyle(fontSize:10.5,fontWeight:active?FontWeight.w900:FontWeight.w700,color:brandInk))])));})) ,
          const SizedBox(height:8),
        ],
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Parceiros',style:TextStyle(fontSize:23,fontWeight:FontWeight.w900)),FilterChip(label:const Text('Abertos'),selected:onlyOpen,onSelected:(v)=>setState(()=>onlyOpen=v))]),
        const SizedBox(height:12),
        if(snap.connectionState==ConnectionState.waiting)const Padding(padding:EdgeInsets.all(50),child:Center(child:CircularProgressIndicator()))
        else if(items.isEmpty)Container(padding:const EdgeInsets.all(28),decoration:BoxDecoration(color:const Color(0xFFF8F5EF),borderRadius:BorderRadius.circular(22)),child:const Column(children:[Icon(Icons.storefront_outlined,size:42,color:brandMuted),SizedBox(height:8),Text('Nenhum parceiro cadastrado nesta seleção.',style:TextStyle(color:brandMuted,fontWeight:FontWeight.w700))]))
        else ...items.map(_partnerCard),
      ]));
    })));
  }

  Widget _partnerCard(_StoreMatch m){final s=m.store;return Padding(padding:const EdgeInsets.only(bottom:14),child:InkWell(onTap:s.isOpen?()=>_open(s):null,borderRadius:BorderRadius.circular(22),child:Row(crossAxisAlignment:CrossAxisAlignment.center,children:[
    Container(width:82,height:82,padding:const EdgeInsets.all(5),decoration:BoxDecoration(color:const Color(0xFFF3F1ED),borderRadius:BorderRadius.circular(22)),child:ClipRRect(borderRadius:BorderRadius.circular(18),child:s.logoUrl.isNotEmpty?Image.network(s.logoUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Image.asset(s.localLogo,fit:BoxFit.cover)):Image.asset(s.localLogo,fit:BoxFit.cover))),
    const SizedBox(width:14),
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(s.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(s.description.isEmpty?'Parceiro local do Vale do Capão':s.description,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(color:brandMuted,fontSize:10.5,height:1.25)),const SizedBox(height:7),Wrap(spacing:7,runSpacing:4,children:[_meta(Icons.schedule_rounded,'${s.estimatedMinutes} min'),_meta(Icons.delivery_dining_rounded,s.deliveryFee<=0?'Grátis':'Frete ${money(s.deliveryFee)}'),if(!s.isOpen)_meta(Icons.schedule_outlined,'Fechado',color:brandRed)])]))
  ]))));}
  Widget _meta(IconData i,String t,{Color color=brandMuted})=>Row(mainAxisSize:MainAxisSize.min,children:[Icon(i,size:14,color:color),const SizedBox(width:3),Text(t,style:TextStyle(color:color,fontSize:9.5,fontWeight:FontWeight.w700))]);
}

class _HubData{final CategoryTaxonomy taxonomy;final List<_StoreMatch> stores;const _HubData({required this.taxonomy,required this.stores});}
class _StoreMatch{final Store store;final List<Product> products;final String haystack;final Set<String> subIds;const _StoreMatch({required this.store,required this.products,required this.haystack,required this.subIds});}

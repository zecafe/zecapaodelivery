import 'package:flutter/material.dart';
import 'core.dart';

class CategoryHub extends StatefulWidget {
  const CategoryHub({super.key, required this.repo, required this.taxonomy, required this.initialCategoryId});
  final Repo repo;
  final CategoryTaxonomy taxonomy;
  final String initialCategoryId;

  @override
  State<CategoryHub> createState() => _CategoryHubState();
}

class _CategoryHubState extends State<CategoryHub> {
  late String categoryId;
  String subId='all';
  bool loading=true;
  List<_StoreMatch> stores=[];

  @override
  void initState(){super.initState();categoryId=widget.initialCategoryId;_load();}

  Future<void> _load() async {
    setState(()=>loading=true);
    final allStores=await widget.repo.stores();
    final matches=< _StoreMatch>[];
    for(final s in allStores){
      final products=await widget.repo.productsFor(s.id);
      final hay='${s.name} ${s.description} ${products.map((e)=>'${e.name} ${e.description} ${e.category}').join(' ')}'.toLowerCase();
      final subs=<String>{};
      for(final c in widget.taxonomy.categories){
        for(final sub in c.subcategories){
          if(sub.keywords.any((k)=>hay.contains(k.toLowerCase()))) subs.add(sub.id);
        }
      }
      matches.add(_StoreMatch(store:s,products:products,haystack:hay,subIds:subs));
    }
    if(mounted)setState((){stores=matches;loading=false;});
  }

  Future<void> _open(Store s) async {
    await Navigator.of(context).push(MaterialPageRoute(builder:(_)=>StorePage(repo:widget.repo,store:s)));
  }

  Widget _categoryChip(CategoryDefinition c){
    final active=c.id==categoryId;
    return InkWell(onTap:(){setState((){categoryId=c.id;subId='all';});},borderRadius:BorderRadius.circular(16),child:Container(width:78,padding:const EdgeInsets.symmetric(vertical:9,horizontal:6),decoration:BoxDecoration(color:active?brandInk:const Color(0xFFF4F0E8),borderRadius:BorderRadius.circular(16),border:Border.all(color:active?brandInk:const Color(0xFFE8E1D6))),child:Column(children:[Icon(c.icon,size:22,color:active?Colors.white:c.color),const SizedBox(height:5),Text(c.label,textAlign:TextAlign.center,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:9,fontWeight:FontWeight.w800,color:active?Colors.white:brandInk))])));
  }

  Widget _subChip(String id,String label){
    final active=id==subId;
    return ChoiceChip(label:Text(label),selected:active,onSelected:(_)=>setState(()=>subId=id),showCheckmark:false,selectedColor:brandRed,labelStyle:TextStyle(color:active?Colors.white:brandInk,fontSize:10,fontWeight:FontWeight.w800),side:BorderSide.none,backgroundColor:const Color(0xFFF2EEE6));
  }

  List<_StoreMatch> _visible(){
    final cat=widget.taxonomy.categories.firstWhere((c)=>c.id==categoryId,orElse:()=>widget.taxonomy.categories.first);
    final keys=cat.keywords.map((e)=>e.toLowerCase()).toList();
    return stores.where((m){
      final categoryOk=keys.isEmpty||keys.any(m.haystack.contains)||m.store.categoryId==cat.id;
      final subOk=subId=='all'||m.subIds.contains(subId);
      return categoryOk&&subOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context){
    final cat=widget.taxonomy.categories.firstWhere((c)=>c.id==categoryId,orElse:()=>widget.taxonomy.categories.first);
    final items=_visible();
    return Scaffold(backgroundColor:Colors.white,appBar:AppBar(backgroundColor:Colors.white,elevation:0,foregroundColor:brandInk,title:Text(cat.label,style:const TextStyle(fontWeight:FontWeight.w900))),body:RefreshIndicator(onRefresh:_load,child:ListView(padding:const EdgeInsets.fromLTRB(18,10,18,30),children:[
      SizedBox(height:82,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:widget.taxonomy.categories.length,separatorBuilder:(_,__)=>const SizedBox(width:8),itemBuilder:(_,i)=>_categoryChip(widget.taxonomy.categories[i]))),
      const SizedBox(height:17),
      SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[_subChip('all','Tudo'),const SizedBox(width:7),...cat.subcategories.expand((s)=>[_subChip(s.id,s.label),const SizedBox(width:7)])])),
      const SizedBox(height:18),
      Text('${items.length} parceiros',style:const TextStyle(fontSize:12,color:brandMuted,fontWeight:FontWeight.w800)),
      const SizedBox(height:11),
      if(loading)const Padding(padding:EdgeInsets.all(30),child:Center(child:CircularProgressIndicator(color:brandRed)))
      else if(items.isEmpty)Container(padding:const EdgeInsets.all(28),decoration:BoxDecoration(color:const Color(0xFFF8F5EF),borderRadius:BorderRadius.circular(22)),child:const Column(children:[Icon(Icons.storefront_outlined,size:42,color:brandMuted),SizedBox(height:8),Text('Nenhum parceiro cadastrado nesta seleção.',style:TextStyle(color:brandMuted,fontWeight:FontWeight.w700))]))
      else ...items.map(_partnerCard),
    ])));
  }

  Widget _partnerCard(_StoreMatch m){final s=m.store;return Padding(padding:const EdgeInsets.only(bottom:14),child:InkWell(onTap:s.isOpen?()=>_open(s):null,borderRadius:BorderRadius.circular(22),child:Row(crossAxisAlignment:CrossAxisAlignment.center,children:[
    Container(width:82,height:82,padding:const EdgeInsets.all(5),decoration:BoxDecoration(color:const Color(0xFFF3F1ED),borderRadius:BorderRadius.circular(22)),child:ClipRRect(borderRadius:BorderRadius.circular(18),child:s.logoUrl.isNotEmpty?Image.network(s.logoUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Image.asset(s.localLogo,fit:BoxFit.cover)):Image.asset(s.localLogo,fit:BoxFit.cover))),
    const SizedBox(width:14),
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(s.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(s.description.isEmpty?'Parceiro local do Vale do Capão':s.description,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(color:brandMuted,fontSize:10.5,height:1.25)),const SizedBox(height:7),Wrap(spacing:7,runSpacing:4,children:[_meta(Icons.schedule_rounded,'${s.estimatedMinutes} min'),_meta(Icons.delivery_dining_rounded,s.deliveryFee<=0?'Grátis':'Frete ${money(s.deliveryFee)}'),if(!s.isOpen)_meta(Icons.schedule_outlined,'Fechado',color:brandRed)])]))
  ])));}
  Widget _meta(IconData i,String t,{Color color=brandMuted})=>Row(mainAxisSize:MainAxisSize.min,children:[Icon(i,size:14,color:color),const SizedBox(width:3),Text(t,style:TextStyle(color:color,fontSize:9.5,fontWeight:FontWeight.w700))]);
}

class _HubData{final CategoryTaxonomy taxonomy;final List<_StoreMatch> stores;const _HubData({required this.taxonomy,required this.stores});}
class _StoreMatch{final Store store;final List<Product> products;final String haystack;final Set<String> subIds;const _StoreMatch({required this.store,required this.products,required this.haystack,required this.subIds});}
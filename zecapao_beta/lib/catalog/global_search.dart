import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core.dart';
import 'branded_store.dart';
import 'category_hub.dart';

class GlobalSearchPage extends StatefulWidget {
  final String customerName, phone;
  final Repo repo;
  const GlobalSearchPage({super.key,required this.customerName,required this.phone,required this.repo});
  @override State<GlobalSearchPage> createState()=>_GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage>{
  final controller=TextEditingController();
  bool loading=false;
  List<_Hit> hits=[];

  @override void dispose(){controller.dispose();super.dispose();}

  String norm(String s)=>s.toLowerCase().replaceAll(RegExp(r'[áàâãä]'),'a').replaceAll(RegExp(r'[éèêë]'),'e').replaceAll(RegExp(r'[íìîï]'),'i').replaceAll(RegExp(r'[óòôõö]'),'o').replaceAll(RegExp(r'[úùûü]'),'u').replaceAll('ç','c');

  Future<void> run(String raw) async {
    final q=norm(raw.trim());
    if(q.length<2){setState(()=>hits=[]);return;}
    setState(()=>loading=true);
    final out=<_Hit>[];
    try{
      final stores=await widget.repo.stores();
      final client=Supabase.instance.client;
      final results=await Future.wait([
        client.from('categories').select('id,name,slug').eq('is_active',true),
        client.from('subcategories').select('id,category_id,name,slug').eq('is_active',true),
        client.from('events').select('id,title,subtitle,venue,location_text').eq('is_active',true),
      ]);
      final cats={for(final c in results[0] as List)'${c['id']}':Map<String,dynamic>.from(c)};
      final subs=(results[1] as List).map((e)=>Map<String,dynamic>.from(e)).toList();
      final links=await client.from('store_subcategories').select('store_id,subcategory_id');
      final subById={for(final s in subs)'${s['id']}':s};
      final storeSubs=<String,List<String>>{};
      for(final l in links as List){final sid='${l['store_id']}',sub=subById['${l['subcategory_id']}'];if(sub!=null)storeSubs.putIfAbsent(sid,()=>[]).add('${sub['name']}');}

      for(final s in stores){
        List<Product> products=[];try{products=await widget.repo.products(s.id);}catch(_){}
        final category=cats[s.categoryId]?['name']?.toString()??'';
        final subNames=storeSubs[s.id]??const[];
        final hay=norm([s.name,s.description,category,...subNames,...products.expand((p)=>[p.name,p.category,p.description])].join(' '));
        if(hay.contains(q))out.add(_Hit.store(s,detail:[category,...subNames].where((x)=>x.isNotEmpty).join(' • ')));
        for(final p in products){if(norm('${p.name} ${p.category} ${p.description} ${s.name}').contains(q))out.add(_Hit.product(s,p));}
      }
      for(final c in cats.values){if(norm('${c['name']} ${c['slug']}').contains(q))out.add(_Hit.category('${c['name']}'));}
      for(final s in subs){if(norm('${s['name']} ${s['slug']}').contains(q)){final cat=cats['${s['category_id']}'];out.add(_Hit.category('${cat?['name']??s['name']}',detail:'Subcategoria: ${s['name']}'));}}
      for(final e in results[2] as List){final m=Map<String,dynamic>.from(e);if(norm('${m['title']} ${m['subtitle']} ${m['venue']} ${m['location_text']}').contains(q))out.add(_Hit.event('${m['title']}',detail:'${m['venue']??''}'));}
    }catch(_){ }
    if(mounted)setState((){hits=out.take(50).toList();loading=false;});
  }

  Future<void> open(_Hit h) async {
    if(h.store!=null){await Navigator.push(context,MaterialPageRoute(builder:(_)=>BrandedStorePage(store:h.store!,customerName:widget.customerName,phone:widget.phone,repo:widget.repo)));return;}
    if(h.category!=null){await Navigator.push(context,MaterialPageRoute(builder:(_)=>CategoryHubPage(category:h.category!,customerName:widget.customerName,phone:widget.phone,repo:widget.repo)));}
  }

  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Buscar no Vale')),body:SafeArea(child:Column(children:[
    Padding(padding:const EdgeInsets.all(16),child:TextField(controller:controller,autofocus:true,onChanged:(v){Future.delayed(const Duration(milliseconds:250),(){if(controller.text==v)run(v);});},decoration:const InputDecoration(hintText:'Restaurante, pizza, hostel, café, evento...',prefixIcon:Icon(Icons.search_rounded)))),
    if(loading)const LinearProgressIndicator(minHeight:2),
    Expanded(child:hits.isEmpty?Center(child:Text(controller.text.trim().length<2?'Digite o que você procura no Vale.':'Nenhum resultado encontrado.',style:const TextStyle(color:brandMuted))):ListView.separated(padding:const EdgeInsets.fromLTRB(14,6,14,24),itemCount:hits.length,separatorBuilder:(_,__)=>const Divider(height:1),itemBuilder:(_,i){final h=hits[i];return ListTile(onTap:()=>open(h),leading:CircleAvatar(backgroundColor:brandRedSoft,child:Icon(h.icon,color:brandRed)),title:Text(h.title,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:h.detail.isEmpty?null:Text(h.detail),trailing:const Icon(Icons.chevron_right_rounded));}))
  ])));
}

class _Hit{
  final String title,detail;final IconData icon;final Store? store;final String? category;
  const _Hit(this.title,this.detail,this.icon,this.store,this.category);
  factory _Hit.store(Store s,{String detail=''})=>_Hit(s.name,detail,Icons.storefront_rounded,s,null);
  factory _Hit.product(Store s,Product p)=>_Hit(p.name,'${s.name} • ${money(p.price)}',Icons.shopping_bag_rounded,s,null);
  factory _Hit.category(String c,{String detail=''})=>_Hit(c,detail,Icons.grid_view_rounded,null,c);
  factory _Hit.event(String t,{String detail=''})=>_Hit(t,detail,Icons.local_activity_rounded,null,'Eventos');
}

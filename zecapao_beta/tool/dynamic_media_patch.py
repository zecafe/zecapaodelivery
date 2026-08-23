from pathlib import Path
import re

core=Path('lib/catalog/core.dart')
s=core.read_text()
if 'class CategoryItem{' not in s:
    marker='class ProductOption{'
    insert="""class CategoryItem{final String id,name,slug,icon;final int sortOrder;final bool isActive;const CategoryItem({required this.id,required this.name,required this.slug,required this.icon,required this.sortOrder,required this.isActive});CategoryItem.fromMap(Map<String,dynamic>m):id='${m['id']??''}',name='${m['name']??''}',slug='${m['slug']??''}',icon='${m['icon']??''}',sortOrder=m['sort_order']??0,isActive=m['is_active']??true;}\nclass EventItem{final String id,title,subtitle,imageUrl,venue,locationText,ctaLabel,targetUrl;final DateTime? startsAt;EventItem.fromMap(Map<String,dynamic>m):id='${m['id']??''}',title='${m['title']??''}',subtitle='${m['subtitle']??''}',imageUrl='${m['image_url']??''}',venue='${m['venue']??''}',locationText='${m['location_text']??''}',ctaLabel='${m['cta_label']??''}',targetUrl='${m['target_url']??''}',startsAt=DateTime.tryParse('${m['starts_at']??''}');}\n"""
    if marker not in s: raise SystemExit('core marker classes not found')
    s=s.replace(marker,insert+marker,1)
if 'Future<List<CategoryItem>> categories()' not in s:
    marker=" Future<List<CampaignBanner>> banners()async{final d=await client.from('campaign_banners').select().order('sort_order');return(d as List).map((e)=>CampaignBanner.fromMap(Map<String,dynamic>.from(e))).toList();}\n"
    add=marker+" Future<List<CategoryItem>> categories()async{final d=await client.from('categories').select().eq('is_active',true).order('sort_order');return(d as List).map((e)=>CategoryItem.fromMap(Map<String,dynamic>.from(e))).toList();}\n Future<List<EventItem>> events()async{final now=DateTime.now().toIso8601String();final d=await client.from('events').select().eq('is_active',true).gte('ends_at',now).order('sort_order');return(d as List).map((e)=>EventItem.fromMap(Map<String,dynamic>.from(e))).toList();}\n"
    if marker not in s: raise SystemExit('core marker repo not found')
    s=s.replace(marker,add,1)
core.write_text(s)

merchant=Path('lib/catalog/merchant_store_v2.dart')
s=merchant.read_text()
s=s.replace("if(isZecafe||widget.store.logoUrl.isEmpty)return local;","if(widget.store.logoUrl.isEmpty)return local;",1)
old="""  Widget merchantHero(){
    if(isZecafe)return zecafeHero();
    if(widget.store.coverUrl.isEmpty)return placeholderHero();
    return Image.network(widget.store.coverUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>placeholderHero());
  }"""
new="""  Widget merchantHero(){
    if(widget.store.coverUrl.isEmpty)return isZecafe?zecafeHero():placeholderHero();
    return Image.network(widget.store.coverUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>isZecafe?zecafeHero():placeholderHero());
  }"""
if old not in s: raise SystemExit('merchant hero marker not found')
s=s.replace(old,new,1)
old="""    if(isZecafe&&p.localImage.isNotEmpty)return ClipRRect(borderRadius:b,child:Image.asset(p.localImage,width:width,height:height,fit:BoxFit.cover,errorBuilder:(_,__,___)=>productFallback(width,height,b)));
    if(p.imageUrl.isEmpty)return productFallback(width,height,b);
    return ClipRRect(borderRadius:b,child:Image.network(p.imageUrl,width:width,height:height,fit:BoxFit.cover,errorBuilder:(_,__,___)=>p.localImage.isNotEmpty?Image.asset(p.localImage,width:width,height:height,fit:BoxFit.cover,errorBuilder:(_,__,___)=>productFallback(width,height,b)):productFallback(width,height,b)));"""
new="""    if(p.imageUrl.isNotEmpty)return ClipRRect(borderRadius:b,child:Image.network(p.imageUrl,width:width,height:height,fit:BoxFit.cover,errorBuilder:(_,__,___)=>p.localImage.isNotEmpty?Image.asset(p.localImage,width:width,height:height,fit:BoxFit.cover,errorBuilder:(_,__,___)=>productFallback(width,height,b)):productFallback(width,height,b)));
    if(p.localImage.isNotEmpty)return ClipRRect(borderRadius:b,child:Image.asset(p.localImage,width:width,height:height,fit:BoxFit.cover,errorBuilder:(_,__,___)=>productFallback(width,height,b)));
    return productFallback(width,height,b);"""
if old not in s: raise SystemExit('product image marker not found')
s=s.replace(old,new,1)
merchant.write_text(s)

home=Path('lib/catalog/showcase_home.dart')
s=home.read_text()
cat="""  Widget _categories() {
    return FutureBuilder<List<CategoryItem>>(
      future: repo.categories(),
      builder: (_, snap) {
        final items=snap.data??<CategoryItem>[];
        if(items.isEmpty)return const SizedBox(height:70,child:Center(child:Text('Categorias em atualização',style:TextStyle(color:brandMuted))));
        return SizedBox(height:122,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:items.length,separatorBuilder:(_,__)=>const SizedBox(width:12),itemBuilder:(_,i){final x=items[i];return InkWell(onTap:(){if(x.slug.contains('hosped')){Navigator.push(context,MaterialPageRoute(builder:(_)=>const HospedagensPage()));}else if(x.slug.contains('evento')){setState(()=>tab=3);}else{setState(()=>tab=1);}},borderRadius:BorderRadius.circular(23),child:SizedBox(width:76,child:Column(children:[Container(width:70,height:70,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(23),boxShadow:const [BoxShadow(color:Color(0x18000000),blurRadius:16,offset:Offset(0,9))]),child:x.icon.startsWith('http')?Image.network(x.icon,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const Icon(Icons.grid_view_rounded,color:brandRed,size:34)):const Icon(Icons.grid_view_rounded,color:brandRed,size:34)),const SizedBox(height:9),Text(x.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w800))]))); }));
      },
    );
  }

  Widget _zecafeHero"""
s,n=re.subn(r"  Widget _categories\(\) \{.*?\n  \}\n\n  Widget _zecafeHero",cat,s,count=1,flags=re.S)
if n!=1: raise SystemExit('categories block not found')
hero="""  Widget _zecafeHero(List<Store> stores) {
    Store? zecafe;
    for(final st in stores){if(st.slug=='zecafe')zecafe=st;}
    return FutureBuilder<List<CampaignBanner>>(
      future:repo.banners(),
      builder:(_,snap){
        final live=(snap.data??<CampaignBanner>[]).where((b)=>b.imageUrl.isNotEmpty).toList();
        if(live.isNotEmpty){return SizedBox(height:204,child:PageView.builder(controller:PageController(viewportFraction:.96),itemCount:live.length,itemBuilder:(_,i){final b=live[i];return Padding(padding:const EdgeInsets.only(right:8),child:ClipRRect(borderRadius:BorderRadius.circular(29),child:Stack(fit:StackFit.expand,children:[Image.network(b.imageUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:hexColor(b.backgroundHex,brandRed))),Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xB8000000),Color(0x22000000)],begin:Alignment.centerLeft,end:Alignment.centerRight))),Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Text(b.title,maxLines:2,style:TextStyle(color:hexColor(b.textHex,Colors.white),fontSize:27,height:1.02,fontWeight:FontWeight.w900)),if(b.subtitle.isNotEmpty)...[const SizedBox(height:7),SizedBox(width:250,child:Text(b.subtitle,maxLines:2,style:const TextStyle(color:Colors.white70,fontSize:11.5)))],if(b.ctaLabel.isNotEmpty)...[const SizedBox(height:12),Container(padding:const EdgeInsets.symmetric(horizontal:13,vertical:8),decoration:BoxDecoration(color:brandYellow,borderRadius:BorderRadius.circular(13)),child:Text(b.ctaLabel,style:const TextStyle(color:brandInk,fontSize:10,fontWeight:FontWeight.w900)))]]))]))); }));}
        if(zecafe?.coverUrl.isNotEmpty==true){return InkWell(onTap:()=>openStore(zecafe!),borderRadius:BorderRadius.circular(29),child:ClipRRect(borderRadius:BorderRadius.circular(29),child:Image.network(zecafe!.coverUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(height:204,color:const Color(0xFF715441),alignment:Alignment.center,child:const Text('Zecafé',style:TextStyle(color:Colors.white,fontSize:36,fontWeight:FontWeight.w900))))));}
        return Container(height:204,decoration:BoxDecoration(color:const Color(0xFF715441),borderRadius:BorderRadius.circular(29)),alignment:Alignment.center,child:const Text('Zecafé',style:TextStyle(color:Colors.white,fontSize:36,fontWeight:FontWeight.w900)));
      },
    );
  }

  Widget _partnerRail"""
s,n=re.subn(r"  Widget _zecafeHero\(List<Store> stores\) \{.*?\n  \}\n\n  Widget _partnerRail",hero,s,count=1,flags=re.S)
if n!=1: raise SystemExit('hero block not found')
events="""  Widget _events() {
    return FutureBuilder<List<EventItem>>(
      future:repo.events(),
      builder:(_,snap){final items=snap.data??<EventItem>[];if(items.isEmpty)return Container(height:150,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(24)),child:const Text('Agenda em atualização',style:TextStyle(color:brandMuted)));return SizedBox(height:190,child:PageView.builder(controller:PageController(viewportFraction:.93),itemCount:items.length,itemBuilder:(_,i){final e=items[i];return Padding(padding:const EdgeInsets.only(right:10),child:ClipRRect(borderRadius:BorderRadius.circular(28),child:Stack(fit:StackFit.expand,children:[e.imageUrl.isNotEmpty?Image.network(e.imageUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:brandNavy)):Container(color:brandNavy),Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xC7000000),Color(0x25000000)],begin:Alignment.centerLeft,end:Alignment.centerRight))),Padding(padding:const EdgeInsets.all(21),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.end,children:[Text(e.title,maxLines:2,style:const TextStyle(color:Colors.white,fontSize:25,height:1.0,fontWeight:FontWeight.w900)),if(e.subtitle.isNotEmpty)...[const SizedBox(height:6),Text(e.subtitle,maxLines:2,style:const TextStyle(color:Colors.white70,fontSize:11))],if(e.venue.isNotEmpty)...[const SizedBox(height:6),Text(e.venue,style:const TextStyle(color:brandYellow,fontSize:9,fontWeight:FontWeight.w900))]]))]))); }));},
    );
  }

  Widget _eventCard"""
s,n=re.subn(r"  Widget _events\(\) \{.*?\n  \}\n\n  Widget _eventCard",events,s,count=1,flags=re.S)
if n!=1: raise SystemExit('events block not found')
home.write_text(s)
print('Dynamic media patch applied')

# Build trigger: Zecapao MVP 0.2.7 dynamic media circuit

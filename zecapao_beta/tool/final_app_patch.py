from pathlib import Path
import re

core=Path('lib/catalog/core.dart')
s=core.read_text()
store_re=r"class Store\{.*?\}\nclass Product\{"
store_new="""class Store{final String id,name,slug,description,logoUrl,coverUrl,categoryId,partnerType,ctaLabel,ctaUrl,bookingWhatsapp,priceRange,address;final double deliveryFee,latitude,longitude;final int estimatedMinutes;final bool isOpen;final List<String> amenities,galleryUrls;Store.fromMap(Map<String,dynamic>m):id='${m['id']??''}',name=m['name']??'',slug=m['slug']??'',description=m['description']??'',logoUrl='${m['logo_url']??''}',coverUrl='${m['cover_url']??''}',categoryId='${m['category_id']??''}',partnerType='${m['partner_type']??'commerce'}',ctaLabel='${m['cta_label']??''}',ctaUrl='${m['cta_url']??''}',bookingWhatsapp='${m['booking_whatsapp']??''}',priceRange='${m['price_range']??''}',address='${m['address']??''}',deliveryFee=double.tryParse('${m['delivery_fee']??0}')??0,latitude=double.tryParse('${m['latitude']??0}')??0,longitude=double.tryParse('${m['longitude']??0}')??0,estimatedMinutes=m['estimated_minutes']??40,isOpen=m['is_open']??false,amenities=((m['amenities']??[])as List).map((e)=>'$e').toList(),galleryUrls=((m['gallery_urls']??[])as List).map((e)=>'$e').toList();String get localLogo=>{'zecafe':'Ativos/Marca/zecafe_logo_oficial.jpg','cafe-duvalle':'Ativos/Marca/cafe_duvalle.jpg','frutos':'Ativos/Marca/frutos.jpg','garimpo-burger':'Ativos/Marca/garimpo_burger.jpg','pizza-lab':'Ativos/Marca/pizza_lab.jpg','pico-acai':'Ativos/Marca/pico_acai.jpg','mandioca':'Ativos/Marca/mandioca.jpg','oxe':'Ativos/Marca/oxe.jpg','dona-beli':'Ativos/Marca/dona_beli.jpg'}[slug]??'Ativos/Marca/zecapao_app_icon.png';String get localCover=>slug=='zecafe'?'Ativos/Marca/zecafe_banner_oficial.jpg':'';}\nclass Product{"""
s,n=re.subn(store_re,store_new,s,count=1,flags=re.S)
if n!=1: raise SystemExit('Store class marker not found')
core.write_text(s)

home=Path('lib/catalog/showcase_home.dart')
s=home.read_text()
if "import 'global_search.dart';" not in s:
    s=s.replace("import 'category_hub.dart';", "import 'category_hub.dart';\nimport 'global_search.dart';\nimport 'hospitality_store.dart';",1)
s=s.replace("await Navigator.push(context, MaterialPageRoute(builder: (_) => BrandedStorePage(store: store, customerName: widget.customerName, phone: widget.phone, repo: repo)));", "await Navigator.push(context, MaterialPageRoute(builder: (_) => store.partnerType=='hospitality'?HospitalityStorePage(store:store):BrandedStorePage(store: store, customerName: widget.customerName, phone: widget.phone, repo: repo)));",1)
s=s.replace("onDestinationSelected: (i) => setState(() => tab = i),", "onDestinationSelected: (i) { if(i==1){Navigator.push(context,MaterialPageRoute(builder:(_)=>GlobalSearchPage(customerName:widget.customerName,phone:widget.phone,repo:repo)));return;} setState(() => tab = i); },",1)
old="""          Container(
            height: 58,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 18, offset: Offset(0, 7))]),
            child: const Row(children: [SizedBox(width: 18), Icon(Icons.search_rounded, size: 28), SizedBox(width: 14), Expanded(child: Text('O que você procura no Vale?', style: TextStyle(color: brandMuted, fontSize: 16)))]),
          ),"""
new="""          InkWell(
            onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>GlobalSearchPage(customerName:widget.customerName,phone:widget.phone,repo:repo))),
            borderRadius:BorderRadius.circular(19),
            child:Container(
              height:58,
              decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(19),boxShadow:const [BoxShadow(color:Color(0x10000000),blurRadius:18,offset:Offset(0,7))]),
              child:const Row(children:[SizedBox(width:18),Icon(Icons.search_rounded,size:28),SizedBox(width:14),Expanded(child:Text('O que você procura no Vale?',style:TextStyle(color:brandMuted,fontSize:16)))]),
            ),
          ),"""
if old in s:s=s.replace(old,new,1)
home.write_text(s)
print('Final app patch applied: search + hospitality + enriched stores')

from pathlib import Path

core=Path('lib/catalog/core.dart')
s=core.read_text()

if 'class CategoryItem{' not in s:
    marker='class ProductOption{'
    insert="""class CategoryItem{final String id,name,slug,icon;final int sortOrder;final bool isActive;const CategoryItem({required this.id,required this.name,required this.slug,required this.icon,required this.sortOrder,required this.isActive});CategoryItem.fromMap(Map<String,dynamic>m):id='${m['id']??''}',name='${m['name']??''}',slug='${m['slug']??''}',icon='${m['icon']??''}',sortOrder=m['sort_order']??0,isActive=m['is_active']??true;}\nclass EventItem{final String id,title,subtitle,imageUrl,venue,locationText,ctaLabel,targetUrl;final DateTime? startsAt;EventItem.fromMap(Map<String,dynamic>m):id='${m['id']??''}',title='${m['title']??''}',subtitle='${m['subtitle']??''}',imageUrl='${m['image_url']??''}',venue='${m['venue']??''}',locationText='${m['location_text']??''}',ctaLabel='${m['cta_label']??''}',targetUrl='${m['target_url']??''}',startsAt=DateTime.tryParse('${m['starts_at']??''}');}\n"""
    if marker not in s: raise SystemExit('core marker classes not found')
    s=s.replace(marker,insert+marker,1)

if 'Future<List<Store>> featuredStores()' not in s:
    marker=" Future<List<Store>> stores()async{final d=await client.from('stores').select().eq('is_active',true).order('name');return(d as List).map((e)=>Store.fromMap(Map<String,dynamic>.from(e))).toList();}\n"
    if marker in s:
        s=s.replace(marker,marker+" Future<List<Store>> featuredStores()async{final d=await client.from('stores').select().eq('is_active',true).eq('is_featured',true).order('featured_sort_order').order('name');return(d as List).map((e)=>Store.fromMap(Map<String,dynamic>.from(e))).toList();}\n",1)

if 'Future<List<CategoryItem>> categories()' not in s:
    marker=" Future<List<CampaignBanner>> banners()async{final d=await client.from('campaign_banners').select().order('sort_order');return(d as List).map((e)=>CampaignBanner.fromMap(Map<String,dynamic>.from(e))).toList();}\n"
    if marker in s:
        s=s.replace(marker,marker+" Future<List<CategoryItem>> categories()async{final d=await client.from('categories').select().eq('is_active',true).order('sort_order');return(d as List).map((e)=>CategoryItem.fromMap(Map<String,dynamic>.from(e))).toList();}\n Future<List<EventItem>> events()async{final now=DateTime.now().toIso8601String();final d=await client.from('events').select().eq('is_active',true).gte('ends_at',now).order('sort_order');return(d as List).map((e)=>EventItem.fromMap(Map<String,dynamic>.from(e))).toList();}\n",1)

core.write_text(s)

merchant=Path('lib/catalog/merchant_store_v2.dart')
if merchant.exists():
    m=merchant.read_text().replace("if(isZecafe||widget.store.logoUrl.isEmpty)return local;","if(widget.store.logoUrl.isEmpty)return local;",1)
    merchant.write_text(m)

print('Dynamic data patch applied; clean Home preserved')

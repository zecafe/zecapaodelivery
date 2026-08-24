import 'package:supabase_flutter/supabase_flutter.dart';

class CatalogSubcategory {
  final String id, name, slug, icon, imageUrl;
  final int sortOrder;
  const CatalogSubcategory({required this.id, required this.name, required this.slug, required this.icon, required this.imageUrl, required this.sortOrder});
  factory CatalogSubcategory.fromMap(Map<String,dynamic> m)=>CatalogSubcategory(
    id:'${m['id']}', name:'${m['name']??''}', slug:'${m['slug']??''}', icon:'${m['icon']??''}', imageUrl:'${m['image_url']??''}', sortOrder:m['sort_order']??0,
  );
}

class CategoryTaxonomy {
  final String? categoryId;
  final List<CatalogSubcategory> subcategories;
  final Set<String> primaryStoreIds;
  final Map<String,Set<String>> storeSubcategoryIds;
  const CategoryTaxonomy({required this.categoryId,required this.subcategories,required this.primaryStoreIds,required this.storeSubcategoryIds});
  static const empty=CategoryTaxonomy(categoryId:null,subcategories:<CatalogSubcategory>[],primaryStoreIds:<String>{},storeSubcategoryIds:<String,Set<String>>{});
}

String categorySlugForLabel(String label){
  switch(label.toLowerCase()){
    case 'comida': return 'comida';
    case 'café': case 'cafes': case 'cafés': return 'cafes';
    case 'pizza': return 'pizza';
    case 'mercado': return 'mercado';
    case 'hospedagem': case 'hospedagens': return 'pousadas';
    case 'experiências': case 'experiencias': return 'experiencias';
    case 'eventos': return 'eventos';
    case 'serviços': case 'servicos': return 'servicos';
    default: return label.toLowerCase();
  }
}

Future<CategoryTaxonomy> loadCategoryTaxonomy(String label) async {
  final client=Supabase.instance.client;
  final slug=categorySlugForLabel(label);
  final categoryRows=await client.from('categories').select('id,slug').eq('slug',slug).eq('is_active',true).limit(1);
  if((categoryRows as List).isEmpty) return CategoryTaxonomy.empty;
  final categoryId='${categoryRows.first['id']}';

  final results=await Future.wait([
    client.from('subcategories').select('id,name,slug,icon,image_url,sort_order').eq('category_id',categoryId).eq('is_active',true).order('sort_order'),
    client.from('stores').select('id').eq('category_id',categoryId).eq('is_active',true),
  ]);
  final subs=(results[0] as List).map((e)=>CatalogSubcategory.fromMap(Map<String,dynamic>.from(e))).toList();
  final primary=(results[1] as List).map((e)=>'${e['id']}').toSet();
  final subIds=subs.map((e)=>e.id).toList();
  final mapping=<String,Set<String>>{};
  if(subIds.isNotEmpty){
    final rows=await client.from('store_subcategories').select('store_id,subcategory_id').inFilter('subcategory_id',subIds);
    for(final row in (rows as List)){
      final storeId='${row['store_id']}',subId='${row['subcategory_id']}';
      mapping.putIfAbsent(storeId,()=> <String>{}).add(subId);
    }
  }
  return CategoryTaxonomy(categoryId:categoryId,subcategories:subs,primaryStoreIds:primary,storeSubcategoryIds:mapping);
}

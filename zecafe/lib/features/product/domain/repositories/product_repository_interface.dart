import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class ProductRepositoryInterface implements RepositoryInterface {

  Future<ProductModel?> getProduct({int? offset, String? type, DataSourceEnum? source, FilterDataModel? filterDataModel});

  @override
  Future<Product?> get(String? id, {bool isCampaign = false});
}
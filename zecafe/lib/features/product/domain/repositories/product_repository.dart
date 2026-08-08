import 'dart:convert';

import 'package:stackfood_multivendor/api/local_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/product/domain/repositories/product_repository_interface.dart';
import 'package:stackfood_multivendor/helper/filter_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get.dart';

class ProductRepository implements ProductRepositoryInterface {
  final ApiClient apiClient;
  ProductRepository({required this.apiClient});

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Product?> get(String? id, {bool isCampaign = false}) async {
    Product? product;
    Response response = await apiClient.getData('${AppConstants.productDetailsUri}$id${isCampaign ? '?campaign=true' : ''}');
    if (response.statusCode == 200) {
      product = Product.fromJson(response.body);
    }
    return product;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<ProductModel?> getProduct({int? offset, String? type, DataSourceEnum? source, FilterDataModel? filterDataModel}) async {
    ProductModel? popularProductModel;
    String productFilter = (
        '&sort_by=${FilterHelper.getSortTypeFromIndex(filterDataModel?.sortIndex ?? -1, isRestaurant: false)}'
            '${'&min_price=${(filterDataModel?.minPrice??0) > 0 ? (filterDataModel?.minPrice??0.0) : "0.0"}&max_price=${(filterDataModel?.maxPrice??0) > 0 ? (filterDataModel?.maxPrice ?? 0.0) : ""}'}'
            '${(filterDataModel?.deliveryTypes?.contains(0) ?? false) ?  '&order_type[]=all' : "${(filterDataModel?.deliveryTypes?.contains(1) ?? false) ? '&order_type[]=delivery' : ''}${(filterDataModel?.deliveryTypes?.contains(2) ?? false) ? '&order_type[]=take_away' : ''}${(filterDataModel?.deliveryTypes?.contains(3) ?? false) ? '&order_type[]=dine_in' : ''}"}'
            '${(FilterHelper.foodType(filterDataModel?.veg ?? false, filterDataModel?.nonVeg ?? false) != '') ? '&filter_by[]=${FilterHelper.foodType(filterDataModel?.veg ?? false, filterDataModel?.nonVeg ?? false)}' : ''}'
            '&rating_1_plus=${filterDataModel?.rating == 1 ? '1' : '0'}'
            '&rating_2_plus=${filterDataModel?.rating == 2 ? '1' : '0'}'
            '&rating_3_plus=${filterDataModel?.rating == 3 ? '1' : '0'}'
            '&rating_4_plus=${filterDataModel?.rating == 4 ? '1' : '0'}'
            '&rating_5=${filterDataModel?.rating == 5 ? '1' : '0'}'
            '${(filterDataModel?.freeDelivery ?? false) ? '&filter_by[]=free_delivery' : ''}'
            '${(filterDataModel?.isAvailable ?? false) ? '&filter_by[]=currently_available' : ''}'
            '${(filterDataModel?.isNew ?? false) ? '&filter_by[]=new_arrivals' : ''}'
            '${(filterDataModel?.discounted ?? false)  ? '&filter_by[]=discounted' : ''}'
            // '${(filterDataModel?.isPopular ?? false) ? '&filter_by[]=popular' : ''}'
            '&cuisine=${filterDataModel?.selectedCuisines??[]}'
    );
    String cacheId = '${AppConstants.popularProductUri}?$productFilter';

    switch (source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.popularProductUri}?$productFilter');
        if (response.statusCode == 200) {
          popularProductModel = null;
          popularProductModel = ProductModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if (cacheResponseData != null) {
          popularProductModel = null;
          popularProductModel = ProductModel.fromJson(jsonDecode(cacheResponseData));
        }
    }
    return popularProductModel;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }
}
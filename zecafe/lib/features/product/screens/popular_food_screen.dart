import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_additional_data_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/public_filter_widget.dart';
import 'package:stackfood_multivendor/common/widgets/filter_icon_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularFoodScreen extends StatefulWidget {
  final bool isPopular;
  final bool fromIsRestaurantFood;
  final int? restaurantId;
  const PopularFoodScreen({super.key, required this.isPopular, required this.fromIsRestaurantFood, this.restaurantId});

  @override
  State<PopularFoodScreen> createState() => _PopularFoodScreenState();
}

class _PopularFoodScreenState extends State<PopularFoodScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if(widget.isPopular) {
      Get.find<ProductController>().getPopularProductList(true, false);
    } else if(widget.fromIsRestaurantFood) {
      Get.find<RestaurantController>().getRestaurantRecommendedItemList(widget.restaurantId, false);
    } else {
      Get.find<ReviewController>().getReviewedProductList(true, Get.find<ReviewController>().reviewType, false);
    }
  }
  @override
  Widget build(BuildContext context) {

    return GetBuilder<ProductController>(builder: (productController) {
      return GetBuilder<ReviewController>(builder: (reviewController) {
        return Scaffold(
          appBar: CustomAppBarWidget(
            title: widget.isPopular ? widget.fromIsRestaurantFood? 'popular_in_this_restaurant'.tr : 'popular_foods_nearby'.tr : 'best_reviewed_food'.tr,
            showCart: true,
            type: widget.isPopular ? productController.popularType : reviewController.reviewType,
            // onVegFilterTap: widget.isPopular ? null : widget.fromIsRestaurantFood ? null : (String type) {
            //   if(widget.isPopular) {
            //     // productController.getPopularProductList(true, type, true);
            //   }else {
            //     reviewController.getReviewedProductList(true, type, true);
            //   }
            // },
            actions: [

              if(widget.isPopular) Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: CustomInkWellWidget(
                  onTap: (){
                    showFilterBottomSheetOrDialog(
                      context, false, filterAdditionalDataModel: FilterAdditionalDataModel(
                      callback: (data){
                        productController.setFilterDataModel(data);
                        productController.getPopularProductList(true, true);
                      },
                      fromPopularRestaurant: true,
                    ),
                      filterDataModel: productController.getFilterDataModel,
                    );
                  },
                  child: FilterIconWidget(fromAppBar: true, iconColor: Theme.of(context).primaryColor,),
                ),
              ),
            ],
          ),
          endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
          body: SingleChildScrollView(controller: scrollController, child: FooterViewWidget(
            child: Column(children: [

              WebScreenTitleWidget(title: widget.isPopular ? widget.fromIsRestaurantFood? 'popular_in_this_restaurant'.tr : 'popular_foods_nearby'.tr : 'best_reviewed_food'.tr),

              Center(child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: GetBuilder<ProductController>(builder: (productController) {
                  return GetBuilder<RestaurantController>(
                    builder: (restaurantController) {

                      return ProductViewWidget(
                        isRestaurant: false, restaurants: null,
                        products: widget.isPopular ? productController.popularProductList : widget.fromIsRestaurantFood ? restaurantController.recommendedProductModel?.products : reviewController.reviewedProductList,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      );
                    }
                  );
                }),
              )),
            ]),
          )),
        );
      });
    });
  }
}

import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomCartWidget extends StatelessWidget {
  final int? restaurantId;
  final bool fromDineIn;
  final bool showGlobalCardWise;
  const BottomCartWidget({super.key, this.restaurantId, this.fromDineIn = false, required this.showGlobalCardWise});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
        return SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: GetPlatform.isIOS ? 100 : 90,
              width: Get.width > 600 ? 600 : Get.width,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                boxShadow: [BoxShadow(color: const Color(0xFF2A2A2A).withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(children: [

              if(showGlobalCardWise)...[
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${'item'.tr}: ${cartController.itemCountOfGlobalCart()}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    '${'total'.tr}: ${PriceConverter.convertPrice(cartController.calculationCartGlobal())}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ])),
              ]
              else Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${'item'.tr}: ${cartController.cartList(restaurantId!).length}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  '${'total'.tr}: ${PriceConverter.convertPrice(cartController.calculationCart(restaurantId!))}',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ])),

              const SizedBox(width: Dimensions.paddingSizeDefault),
              CustomButtonWidget(buttonText: 'view_cart'.tr, width: 150, height: 55, onPressed: () async {
                await Get.toNamed(showGlobalCardWise ? RouteHelper.getCartBundleListRoute() : RouteHelper.getCartRoute(fromDineIn: fromDineIn, restaurantId: restaurantId!));
                if(showGlobalCardWise) {
                  return;
                }
                Get.find<RestaurantController>().makeEmptyRestaurant();
                if(restaurantId != null) {
                  Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantId));
                }
              })
            ]),
            ),
          ),
        );
      });
  }
}

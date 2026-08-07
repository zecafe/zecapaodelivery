import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_bundle_model.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import '../../../common/models/restaurant_model.dart' as restaurant_common;

class CartBundleWidget extends StatelessWidget {
  final CartBundleModel cartBundleWidget;
  const CartBundleWidget({super.key, required this.cartBundleWidget});

  @override
  Widget build(BuildContext context) {
    final Restaurant? restaurant = cartBundleWidget.restaurant;
    if (restaurant == null) {
      return const SizedBox();
    }

    final List<String?> itemImages = cartBundleWidget.carts?.map((e) => e.product?.imageFullUrl ?? '').toList() ?? [];

    return GetBuilder<CartController>(builder: (cartController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(
            children: [
              Expanded(
                child: Row(children: [

                  ClipOval(
                    child: CustomImageWidget(
                      image: restaurant.logoFullUrl ?? '',
                      height: 32, width: 32, isRestaurant: true,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Flexible(
                    child: Row(
                      children: [
                        Flexible(
                          child: InkWell(
                            onTap: () => _openRestaurant(restaurant),
                            child: Text(
                              restaurant.name ?? '',
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        if(restaurant.verifiedSeller == true) ...[
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          const RestaurantVerifiedIconWidget(),
                        ],

                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text(
                    '(${restaurant.itemCount ?? 0})',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),


                ]),
              ),

              PopupMenuButton<String>(
                tooltip: '',
                padding: EdgeInsets.zero,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                enabled: !(cartController.isDeleting && cartController.deletingRestaurantId == restaurant.id),
                icon: cartController.isDeleting && cartController.deletingRestaurantId == restaurant.id
                    ? Icon(Icons.more_vert, size: 22, color: Theme.of(context).hintColor.withValues(alpha: 0.4))
                    : Icon(Icons.more_vert, size: 22, color: Theme.of(context).hintColor),
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDelete(context, restaurant.id!);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    height: 30,
                    child: Row(children: [
                      Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(
                        'delete'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error),
                      ),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (itemImages.isNotEmpty) SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            itemCount: itemImages.length,
            separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: CustomImageWidget(
                  image: itemImages[index] ?? '',
                  height: 70, width: 70, isFood: true,
                  placeholder: Images.foodPlaceholder,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Divider(height: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            CustomInkWellWidget(
              onTap: () => _openRestaurant(restaurant),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  'add_more_items'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                ),
              ]),
            ),

            CustomButtonWidget(
              width: 100,
              height: 40,
              onPressed: () {
                Get.toNamed(
                  RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.name ?? ''),
                  arguments: RestaurantScreen(
                    restaurant: restaurant_common.Restaurant(id: restaurant.id, name: restaurant.name),
                    viewCartAutoNavigate: true,
                  ),
                );
              },
              radius: Dimensions.radiusSmall,
              buttonText: 'view_cart'.tr,
              fontSize: Dimensions.fontSizeSmall,
            ),

          ]),
        ),

      ]),
    );
    });
  }

  void _openRestaurant(Restaurant restaurant){
    Get.toNamed(
      RouteHelper.getRestaurantRoute(restaurant.id,),
    );
  }

  void _confirmDelete(BuildContext context, int restaurantId) {
    Get.dialog(ConfirmationDialogWidget(
      icon: Images.warning,
      title: 'are_you_sure_to_delete'.tr,
      description: 'all_items_from_this_restaurant_will_be_removed_from_your_cart'.tr,
      isLogOut: true,
      isDelete: true,
      onYesPressed: () {
        Get.back();
        Get.find<CartController>().removeCartBundle(restaurantId);
      },
    ), barrierDismissible: false);
  }
}

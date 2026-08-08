import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/stacked_order_images_widget.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class HomeLastOrderCardWidget extends StatelessWidget {
  final OrderModel order;
  const HomeLastOrderCardWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

          Container(
            height: 56, width: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.15)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImageWidget(
                image: order.restaurant?.logoFullUrl ?? '',
                height: 56, width: 56,
                isRestaurant: true,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: InkWell(
                    onTap: () => _onRestaurantTap(),
                    child: Text(
                      order.restaurant?.name ?? '',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if(order.restaurant?.verifiedSeller == true) ...[
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  const RestaurantVerifiedIconWidget(),
                ],
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(
                order.createdAt != null ? DateConverter.dateTimeStringToDateOnly(order.createdAt!) : '',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              ),
            ]),
          ),

        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Row(children: [

                  StackedOrderImagesWidget(
                    imageUrls: (order.itemImages ?? const []) + List.generate((order.totalItemCount ?? 0) - (order.itemImages ?? const []).length, (_)=> 'X'),
                    totalCount: order.totalItemCount ?? 0,
                    showCountAsOverlay: false,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Text(
                      PriceConverter.convertPrice(order.orderAmount),
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                ]),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            AspectRatio(
              aspectRatio: 1,
              child: GetBuilder<OrderController>(builder: (orderController) {
                final bool isReordering = orderController.isLoading && orderController.reorderingOrderId == order.id;
                return InkWell(
                  onTap: isReordering ? null : () => _onReorderTap(),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (order.campaign != true) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    alignment: Alignment.center,
                    child: isReordering
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.refresh, color: Colors.white, size: 24),
                  ),
                );
              }),
            ),

          ]),
        ),

      ]),
    );
  }

  Future<void> _onReorderTap() async {
    if(order.campaign == true) return;
    await Get.find<OrderController>().reorderFromLastOrder(order.id);
  }

  void _onRestaurantTap() {
    final int? restaurantId = order.restaurant?.id;
    if(restaurantId == null) {
      return;
    }
    Get.toNamed(RouteHelper.getRestaurantRoute(restaurantId, slug: order.restaurant?.name ?? ''));
  }
}

// localization keys used:
// (none)

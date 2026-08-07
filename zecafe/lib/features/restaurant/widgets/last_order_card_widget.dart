import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/stacked_order_images_widget.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class LastOrderCardWidget extends StatelessWidget {
  final OrderModel order;
  const LastOrderCardWidget({super.key, required this.order,});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.white.withAlpha(10) : Color(0xffF3F5FF),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          Expanded(
            child: Text(
              '${'order_id'.tr} #${order.id}',
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            order.createdAt != null ? DateConverter.dateTimeStringToDateOnly(order.createdAt!) : '',
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
          child: Row(children: [

            StackedOrderImagesWidget(
              imageUrls: (order.itemImages ?? const []) + List.generate((order.totalItemCount ?? 0) - (order.itemImages ?? const []).length, (_)=> 'X'),
              totalCount: order.totalItemCount ?? 0,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(
              child: Text(
                PriceConverter.convertPrice(order.orderAmount),
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            order.campaign != true ? GetBuilder<OrderController>(builder: (orderController) {
              final bool isReordering = orderController.isLoading && orderController.reorderingOrderId == order.id;
              return InkWell(
                onTap: isReordering ? null : () => _onReorderTap(),
                customBorder: const CircleBorder(),
                child: Container(
                  height: 36, width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  alignment: Alignment.center,
                  child: isReordering
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.refresh, color: Colors.white, size: 20),
                ),
              );
            }) : SizedBox.shrink(),

          ]),
        ),

      ]),
    );
  }

  Future<void> _onReorderTap() async {
    await Get.find<OrderController>().reorderFromLastOrder(order.id);
  }
}

// localization keys used:
// order_id

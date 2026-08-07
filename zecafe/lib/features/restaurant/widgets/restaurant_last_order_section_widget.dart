import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/last_order_card_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class RestaurantLastOrderSectionWidget extends StatefulWidget {
  final int restaurantId;
  const RestaurantLastOrderSectionWidget({super.key, required this.restaurantId,});

  @override
  State<RestaurantLastOrderSectionWidget> createState() => _RestaurantLastOrderSectionWidgetState();
}

class _RestaurantLastOrderSectionWidgetState extends State<RestaurantLastOrderSectionWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      final controller = Get.find<OrderController>();
      final total = controller.restaurantLastOrdersPageSize ?? 0;
      final loaded = controller.restaurantLastOrders?.length ?? 0;
      if (!controller.restaurantLastOrdersPaginating && loaded < total) {
        controller.showLastOrderLoader(isHome: false);
        controller.getRestaurantLastOrders(widget.restaurantId, offset: controller.restaurantLastOrdersOffset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      final orders = orderController.restaurantLastOrders;
      if (orders == null || orders.isEmpty) {
        return const SizedBox.shrink();
      }
      final bool hasMore = (orderController.restaurantLastOrdersPageSize ?? 0) > orders.length;
      return Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: const EdgeInsets.only(
              top: Dimensions.paddingSizeLarge, left: Dimensions.paddingSizeDefault,
              bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeDefault,
            ),
            child: Row(children: [
              Expanded(
                child: Text(
                  'last_order'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w700),
                ),
              ),
              const ArrowIconButtonWidget(onTap: null),
            ]),
          ),

          SizedBox(
            height: 100,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: orders.length + (hasMore ? 1 : 0),
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              itemBuilder: (context, index) {
                if (index == orders.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  );
                }
                return Center(
                  child: LastOrderCardWidget(
                    order: orders[index],
                  ),
                );
              },
            ),
          ),

        ]),
      );
    });
  }
}

// localization keys used:
// last_order

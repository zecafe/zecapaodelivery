import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_last_order_card_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class HomeLastOrderSectionWidget extends StatefulWidget {
  const HomeLastOrderSectionWidget({super.key});

  @override
  State<HomeLastOrderSectionWidget> createState() => _HomeLastOrderSectionWidgetState();
}

class _HomeLastOrderSectionWidgetState extends State<HomeLastOrderSectionWidget> {
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
      final total = controller.homeLastOrdersPageSize ?? 0;
      final loaded = controller.homeLastOrders?.length ?? 0;
      if (!controller.homeLastOrdersPaginating && loaded < total) {
        controller.showLastOrderLoader(isHome: true);
        controller.getHomeLastOrders(offset: controller.homeLastOrdersOffset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      final orders = orderController.homeLastOrders;
      if (orders == null || orders.isEmpty) {
        return const SizedBox.shrink();
      }
      final bool hasMore = (orderController.homeLastOrdersPageSize ?? 0) > orders.length;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault),
          child: Text(
            'last_order'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        SizedBox(
          height: 145,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: orders.length + (hasMore ? 1 : 0),
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault),
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
                child: HomeLastOrderCardWidget(order: orders[index]),
              );
            },
          ),
        ),

      ]);
    });
  }
}

// localization keys used:
// last_order

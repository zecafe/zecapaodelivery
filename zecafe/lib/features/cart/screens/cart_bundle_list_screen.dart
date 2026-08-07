import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/screens/cart_bundle_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class CartBundleListScreen extends StatefulWidget {
  final bool fromNav;
  const CartBundleListScreen({super.key, this.fromNav = false});

  @override
  State<CartBundleListScreen> createState() => _CartBundleListScreenState();
}

class _CartBundleListScreenState extends State<CartBundleListScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      Get.find<CartController>().getCartBundleList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWidget(title: 'cart_list'.tr, isBackButtonExist: !widget.fromNav),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<CartController>(builder: (cartController) {

        if (cartController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = cartController.cartBundleList;
        if (list.isEmpty) {
          return NoDataScreen(isEmptyCart: true, title: 'you_have_not_add_to_cart_yet'.tr);
        }

        final bool isDesktop = ResponsiveHelper.isDesktop(context);
        return RefreshIndicator(
          onRefresh: () => cartController.getCartBundleList(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FooterViewWidget(
              child: Column(children: [

                WebScreenTitleWidget(title: 'cart_list'.tr),

                Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: isDesktop
                      ? GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: list.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 230,
                          ),
                          itemBuilder: (context, index) {
                            return CartBundleWidget(cartBundleWidget: list[index]);
                          },
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return CartBundleWidget(cartBundleWidget: list[index]);
                          },
                        ),
                  ),
                ),

              ]),
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_additional_data_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/public_filter_widget.dart';
import 'package:stackfood_multivendor/common/widgets/filter_icon_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/custom_debouncer_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AllRestaurantScreen extends StatefulWidget {
  final bool isPopular;
  final bool isRecentlyViewed;
  final bool isOrderAgain;
  const AllRestaurantScreen({super.key, required this.isPopular, required this.isRecentlyViewed, required this.isOrderAgain});

  @override
  State<AllRestaurantScreen> createState() => _AllRestaurantScreenState();
}

class _AllRestaurantScreenState extends State<AllRestaurantScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final customDebounceHelper = CustomDebounceHelper(milliseconds: 1500);

  @override
  void initState() {
    super.initState();

    if (widget.isPopular) {
      Get.find<RestaurantController>().getPopularRestaurantList(false, false);
    } else if (widget.isRecentlyViewed) {
      Get.find<RestaurantController>().getRecentlyViewedRestaurantList(
          false, 'all', false);
    } else if (widget.isOrderAgain) {
      Get.find<RestaurantController>().getOrderAgainRestaurantList(false);
    } else {
      Get.find<RestaurantController>().getLatestRestaurantList(
          false, 'all', false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      Get.find<RestaurantController>().getPopularRestaurantList(true, false, withFilter: false);
    });
    _searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<RestaurantController>(
      builder: (restController) {
        return Scaffold(
          appBar: CustomAppBarWidget(
            title: widget.isPopular ? 'popular_restaurants'.tr : widget.isRecentlyViewed
                ? 'recently_viewed_restaurants'.tr : widget.isOrderAgain ? 'order_again'.tr
                : '${'new_on'.tr} ${AppConstants.appName}',
            type: restController.type,
            onVegFilterTap: widget.isOrderAgain ? null : widget.isPopular ? null : (String type) {
              if(widget.isPopular) {
                restController.getPopularRestaurantList(true, true);
              }else {
                if(widget.isRecentlyViewed){
                  restController.getRecentlyViewedRestaurantList(true, type, true);
                }else{
                  restController.getLatestRestaurantList(true, type, true);
                }
              }
            },
            actions: widget.isPopular ? [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: CustomInkWellWidget(
                  onTap: (){
                    showFilterBottomSheetOrDialog(
                      context, true, filterAdditionalDataModel:  FilterAdditionalDataModel(
                        callback: (data){
                          restController.setFilterDataModel(data);
                          restController.getPopularRestaurantList(true, true);
                        },
                        showPriceWidget: false,
                        fromPopularRestaurant: true,
                      ),
                      filterDataModel: restController.getFilterDataModel,
                    );
                  },
                  child: FilterIconWidget(fromAppBar: true, iconColor: Theme.of(context).primaryColor,),
                ),
              ),
            ] : null,
          ),
          endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
          body: RefreshIndicator(
            onRefresh: () async {
              if(widget.isPopular) {
                await Get.find<RestaurantController>().getPopularRestaurantList(
                  true, false,
                );
              } else if(widget.isRecentlyViewed){
                Get.find<RestaurantController>().getRecentlyViewedRestaurantList(true, Get.find<RestaurantController>().type, false);
              } else if(widget.isOrderAgain) {
                Get.find<RestaurantController>().getOrderAgainRestaurantList(false);
              } else{
                await Get.find<RestaurantController>().getLatestRestaurantList(true, Get.find<RestaurantController>().type, false);
              }
            },
            child: SingleChildScrollView(controller: scrollController, child: FooterViewWidget(
              child: Column(
                children: [

                  if(widget.isPopular && !ResponsiveHelper.isDesktop(context)) _searchSection(context),

                  WebScreenTitleWidget(title: 'restaurants'.tr),

                  Center(child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: ProductViewWidget(
                      isRestaurant: true, products: null, noDataText: 'no_restaurant_available'.tr,
                      restaurants: widget.isPopular ? restController.popularRestaurantList : widget.isRecentlyViewed
                          ? restController.recentlyViewedRestaurantList : widget.isOrderAgain
                          ? restController.orderAgainRestaurantList : restController.latestRestaurantList,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    ),
                  )),
                ],
              ),
            )),
          ),
        );
      }
    );
  }

  Widget _searchSection(BuildContext context) {

    if (ResponsiveHelper.isDesktop(context)) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeExtraLarge,
        ),
        height: 64,
        width: Dimensions.webMaxWidth,
        color: Theme
            .of(context)
            .primaryColor
            .withValues(alpha: 0.10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('search_restaurants'.tr, style: robotoSemiBold),
            SizedBox(
              height: 35,
              width: 250,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, child) {
                  final bool hasText = value.text
                      .trim()
                      .isNotEmpty;

                  return SearchBar(
                    controller: _searchController,
                    backgroundColor: WidgetStatePropertyAll(
                      Theme
                          .of(context)
                          .cardColor,
                    ),
                    elevation: const WidgetStatePropertyAll(0),
                    side: WidgetStatePropertyAll(
                      BorderSide(
                        color: Theme
                            .of(
                          context,
                        )
                            .hintColor
                            .withValues(alpha: 0.15),
                      ),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    overlayColor: WidgetStateColor.transparent,
                    onChanged: (value) {
                      onSearchAction();
                    },
                    hintText: 'search_restaurants'.tr,
                    hintStyle: WidgetStatePropertyAll(
                      robotoRegular.copyWith(
                        color: Theme
                            .of(context)
                            .disabledColor,
                      ),
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    leading: Icon(
                      CupertinoIcons.search,
                      size: 16,
                      color: Theme
                          .of(context)
                          .hintColor
                          .withValues(alpha: 0.5),
                    ),
                    trailing: hasText
                        ? [
                      InkWell(
                        child: Icon(
                          Icons.clear,
                          size: 16,
                          color: Theme
                              .of(
                            context,
                          )
                              .hintColor
                              .withValues(alpha: 0.5),
                        ),
                        onTap: () {
                          _searchController.clear();
                          onSearchAction();
                        },
                      ),
                    ]
                        : [const SizedBox()],
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
        top: Dimensions.paddingSizeDefault,
      ),
      child: SizedBox(
        height: 47,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child) {
            final bool hasText = value.text.trim().isNotEmpty;

            return SearchBar(
              controller: _searchController,
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).cardColor,
              ),
              elevation: const WidgetStatePropertyAll(0),
              side: WidgetStatePropertyAll(
                BorderSide(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                ),
              ),
              onChanged: (value) {
                onSearchAction();
              },
              hintText: 'search_restaurants'.tr,
              hintStyle: WidgetStatePropertyAll(
                robotoRegular.copyWith(color: Theme.of(context).disabledColor),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
              leading: Icon(
                CupertinoIcons.search,
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
              trailing: hasText ? [
                InkWell(
                  child: Icon(
                    Icons.clear,
                    color: Theme.of(
                      context,
                    ).hintColor.withValues(alpha: 0.5),
                  ),
                  onTap: () {
                    _searchController.clear();
                    onSearchAction();
                  },
                ),
              ] : [const SizedBox()],
            );
          },
        ),
      ),
    );
  }

  void onSearchAction(){
    customDebounceHelper.run((){
      Get.find<RestaurantController>().getPopularRestaurantList(true, true, query: _searchController.text);
    });
  }
}

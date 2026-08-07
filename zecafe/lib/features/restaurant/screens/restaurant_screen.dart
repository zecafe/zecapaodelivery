import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/bottom_cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/veg_filter_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:stackfood_multivendor/features/auth/widgets/auth_dialog_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_card_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/screens/subscription_plan_screen.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/restaurant_category_foods_model.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/pro_plan_banner_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_category_section_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_info_section_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_last_order_section_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_screen_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant? restaurant;
  final String slug;
  final bool fromDineIn;
  final bool viewCartAutoNavigate;
  const RestaurantScreen({super.key, required this.restaurant, this.slug = '', this.fromDineIn = false, this.viewCartAutoNavigate = false});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  // Tracks active category index; only the category bar rebuilds when this changes
  final ValueNotifier<int> _activeCategoryNotifier = ValueNotifier(0);
  final GlobalKey _scrollViewKey = GlobalKey();
  Timer? _autoCartTimer;
  bool _autoCartScheduled = false;
  // Section keys and pre-calculated absolute scroll offsets (one per category)
  List<GlobalKey> _sectionKeys = [];
  List<double> _sectionOffsets = [];
  // Guard so offsets are recalculated only when the loaded model changes
  RestaurantCategoryFoodsModel? _lastModel;
  bool _isScrollingToCategory = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    _initDataCall();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    _activeCategoryNotifier.dispose();
    _autoCartTimer?.cancel();
    super.dispose();
    scrollController.dispose();
  }

  void _scheduleAutoCartNavigation() {
    if (_autoCartScheduled) return;
    _autoCartScheduled = true;
    _autoCartTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      Get.toNamed(RouteHelper.getCartRoute(restaurantId: widget.restaurant?.id ?? Get.find<RestaurantController>().restaurant!.id!));
    });
  }

  Future<void> _initDataCall() async {
    if(Get.find<RestaurantController>().isSearching) {
      Get.find<RestaurantController>().changeSearchStatus(isUpdate: false);
    }
    await Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: widget.restaurant?.id), /*slug: widget.slug*/);
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true, search: '');
    }
    Get.find<CouponController>().getRestaurantCouponList(restaurantId: widget.restaurant?.id ?? Get.find<RestaurantController>().restaurant!.id!);
    Get.find<RestaurantController>().getRestaurantRecommendedItemList(widget.restaurant?.id ?? Get.find<RestaurantController>().restaurant!.id!, false);
    Get.find<RestaurantController>().getRestaurantCategoryFoods(widget.restaurant?.id ?? Get.find<RestaurantController>().restaurant!.id!, 'all');
    if (AuthHelper.isLoggedIn() && (Get.find<SplashController>().configModel?.repeatOrderOption ?? false)) {
      Get.find<OrderController>().getRestaurantLastOrders(widget.restaurant?.id ?? Get.find<RestaurantController>().restaurant!.id!);
    }
  }

  // Calculates absolute scroll offset for each section once after layout.
  // Stored in _sectionOffsets so _onScroll never touches the render tree.
  void _calculateSectionOffsets() {
    if (!mounted) return;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    // SliverAppBar(primary:true) collapsed height = toolbarHeight + status-bar height
    final double statusBarHeight = isDesktop ? 0.0 : MediaQuery.of(context).viewPadding.top;
    final double collapsedAppBarHeight = (isDesktop ? 150.0 : 90.0) + statusBarHeight;
    final scrollViewBox = _scrollViewKey.currentContext?.findRenderObject() as RenderBox?;
    final double viewportTop = scrollViewBox?.localToGlobal(Offset.zero).dy ?? 0.0;
    final List<double> offsets = [];
    for (final key in _sectionKeys) {
      final ctx = key.currentContext;
      if (ctx == null) { offsets.add(0); continue; }
      final renderBox = ctx.findRenderObject() as RenderBox?;
      if (renderBox == null) { offsets.add(0); continue; }
      final screenY = renderBox.localToGlobal(Offset.zero).dy;
      offsets.add(scrollController.offset + screenY - viewportTop - collapsedAppBarHeight - 98);
    }
    _sectionOffsets = offsets;
  }

  // O(n) comparison against pre-calculated offsets — zero render-tree work per frame.
  void _onScroll() {
    if (_isScrollingToCategory || _sectionOffsets.isEmpty) return;
    final double offset = scrollController.offset;
    int activeIndex = 0;
    for (int i = 0; i < _sectionOffsets.length; i++) {
      if (offset >= _sectionOffsets[i] - 4) activeIndex = i;
    }
    if (_activeCategoryNotifier.value != activeIndex) {
      _activeCategoryNotifier.value = activeIndex;
    }
  }

  Future<void> _scrollToCategory(int index) async {
    if (index >= _sectionKeys.length) return;
    _activeCategoryNotifier.value = index;

    double targetOffset;
    if (_sectionOffsets.length > index) {
      targetOffset = _sectionOffsets[index];
    } else {
      // Fallback before offsets are calculated
      final ctx = _sectionKeys[index].currentContext;
      if (ctx == null) return;
      final renderBox = ctx.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      final bool isDesktop = ResponsiveHelper.isDesktop(context);
      final double statusBarHeight = isDesktop ? 0.0 : MediaQuery.of(context).viewPadding.top;
      final double collapsedAppBarHeight = (isDesktop ? 150.0 : 90.0) + statusBarHeight;
      final scrollViewBox = _scrollViewKey.currentContext?.findRenderObject() as RenderBox?;
      final double viewportTop = scrollViewBox?.localToGlobal(Offset.zero).dy ?? 0.0;
      targetOffset = scrollController.offset + renderBox.localToGlobal(Offset.zero).dy - viewportTop - collapsedAppBarHeight - 98 - 4;
    }

    _isScrollingToCategory = true;
    await scrollController.animateTo(
      targetOffset.clamp(0.0, scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
    _isScrollingToCategory = false;
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      appBar: isDesktop ? WebMenuBar(fromDineIn: widget.fromDineIn) : null,
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<RestaurantController>(builder: (restController) {
        return GetBuilder<CouponController>(builder: (couponController) {
            final RestaurantCategoryFoodsModel? categoryFoodsModel = restController.restaurantCategoryFoodsModel;
            Restaurant? restaurant;
            if (restController.restaurant != null && restController.restaurant!.name != null && categoryFoodsModel != null) {
              restaurant = restController.restaurant;
              if (widget.viewCartAutoNavigate) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleAutoCartNavigation());
              }
            }
            bool hasCoupon = (couponController.couponList!= null && couponController.couponList!.isNotEmpty);

            final categories = categoryFoodsModel?.categories ?? [];
            print("restaurant:   ${restController.restaurant?.id}");
            print("restaurant:   ${restController.restaurant?.name}");

            return (restController.restaurant != null && restController.restaurant!.name != null && categoryFoodsModel != null) ? Stack(children: [
              CustomScrollView(
              key: _scrollViewKey,
              physics: const AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              slivers: [

                RestaurantInfoSectionWidget(restaurant: restaurant!, restController: restController, hasCoupon: hasCoupon),

                SliverToBoxAdapter(child: Center(child: Container(
                  width: Dimensions.webMaxWidth,
                  color: Theme.of(context).cardColor,
                  child: Column(children: [
                    restaurant.discount != null ? Container(
                      width: context.width,
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).primaryColor),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                        Text(
                          restaurant.discount!.discountType == 'percent' ? '${restaurant.discount!.discount}% ${'off'.tr}'
                              : '${PriceConverter.convertPrice(restaurant.discount!.discount)} ${'off'.tr}',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor),
                        ),

                        Text(
                          restaurant.discount!.discountType == 'percent'
                              ? '${'enjoy'.tr} ${restaurant.discount!.discount}% ${'off_on_all_categories'.tr}'
                              : '${'enjoy'.tr} ${PriceConverter.convertPrice(restaurant.discount!.discount)}'
                              ' ${'off_on_all_categories'.tr}',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                        ),
                        SizedBox(height: (restaurant.discount!.minPurchase != 0 || restaurant.discount!.maxDiscount != 0) ? 5 : 0),

                        restaurant.discount!.minPurchase != 0 ? Text(
                          '[ ${'minimum_purchase'.tr}: ${PriceConverter.convertPrice(
                              restaurant.discount!.minPurchase)} ]',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                        ) : const SizedBox(),

                        restaurant.discount!.maxDiscount != 0 ? Text(
                          '[ ${'maximum_discount'.tr}: ${PriceConverter.convertPrice(restaurant.discount!.maxDiscount)} ]',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                        ) : const SizedBox(),

                        Text(
                          '[ ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(restaurant.discount!.startTime!)} '
                              '- ${DateConverter.convertTimeToTime(restaurant.discount!.endTime!)} ]',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                        ),

                      ]),
                    ) : const SizedBox(),
                    SizedBox(height: (restaurant.announcementActive! && restaurant.announcementMessage != null) ? 0 : Dimensions.paddingSizeSmall),

                    ResponsiveHelper.isMobile(context) ? (restaurant.announcementActive! && restaurant.announcementMessage != null) ? Container(
                      decoration: const BoxDecoration(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      child: Row(children: [

                        Image.asset(Images.announcement, height: 26, width: 26),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Flexible(child: Text(
                          restaurant.announcementMessage ?? '',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                        )),

                      ]),
                    ) : const SizedBox() : const SizedBox(),

                    Get.find<SplashController>().proStaus ? ProPlanBannerWidget(
                      onSubscribe: (){
                        if(AuthHelper.isLoggedIn()){
                          Get.find<ProController>().saveCurrentPath();
                          if(ResponsiveHelper.isDesktop(context)){
                            SubscriptionPlanScreen.open();
                          }
                          else{
                            Get.toNamed(RouteHelper.getSubscriptionPlanRoute());
                          }
                        }
                        else{
                          if(ResponsiveHelper.isDesktop(context)){
                            Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: false, backFromThis: false)), barrierDismissible: false,);
                          }else{
                            Get.toNamed(RouteHelper.signIn);
                          }
                        }
                      },
                    ) : const SizedBox(),

                    if(AuthHelper.isLoggedIn() && (Get.find<SplashController>().configModel?.repeatOrderOption ?? false)) ...[
                      RestaurantLastOrderSectionWidget(restaurantId: restaurant.id!),
                    ],

                    SizedBox(height: Dimensions.paddingSizeSmall),
                    restController.recommendedProductModel != null && restController.recommendedProductModel!.products!.isNotEmpty ? Container(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Padding(
                          padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeLarge, left: Dimensions.paddingSizeLarge,
                            bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeLarge,
                          ),
                          child: Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('recommend_for_you'.tr, style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w700)),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Text('here_is_what_you_might_like_to_test'.tr, style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                              ]),
                            ),

                            ArrowIconButtonWidget(
                              onTap: () => Get.toNamed(RouteHelper.getPopularFoodRoute(false, fromIsRestaurantFood: true, restaurantId: widget.restaurant!.id
                                  ?? Get.find<RestaurantController>().restaurant!.id!)),
                            ),
                          ]),
                        ),

                        SizedBox(
                          height: ResponsiveHelper.isDesktop(context) ? 307 : 305, width: context.width,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: restController.recommendedProductModel!.products!.length,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall,
                                bottom: Dimensions.paddingSizeExtraSmall,
                                right: Dimensions.paddingSizeDefault),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                                child: ItemCardWidget(
                                  product: restController.recommendedProductModel!.products![index],
                                  isBestItem: false,
                                  isPopularNearbyItem: false,
                                  width: ResponsiveHelper.isDesktop(context) ? 200 : MediaQuery.of(context).size.width * 0.53,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                      ]),
                    ) : const SizedBox(),
                  ]),
                ))),

                // all food title and filters
                categories.isNotEmpty ? SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverDelegate(height: 98, child: Center(child: Container(
                    width: Dimensions.webMaxWidth,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: isDesktop ? [] : [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    child: Column(children: [
                      Padding(padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
                        child: Row(children: [

                          Text('all_food_items'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          const Expanded(child: SizedBox()),

                          isDesktop ? Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            height: 35, width: 320,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Theme.of(context).cardColor,
                              border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                      hintText: 'search_for_your_food'.tr,
                                      hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), borderSide: BorderSide.none),
                                      filled: true,
                                      fillColor: Theme.of(context).cardColor,
                                      isDense: true,
                                      prefixIcon: InkWell(
                                        onTap: () {
                                          if (!restController.isSearching) {
                                            Get.find<RestaurantController>().getRestaurantSearchProductList(
                                              _searchController.text.trim(), Get.find<RestaurantController>().restaurant!.id.toString(), 1, restController.type,
                                            );
                                          } else {
                                            _searchController.text = '';
                                            restController.initSearchData();
                                            restController.changeSearchStatus();
                                          }
                                        },
                                        child: Icon(restController.isSearching ? Icons.clear : CupertinoIcons.search,
                                            color: Theme.of(context).primaryColor.withValues(alpha: 0.50)),
                                      ),
                                    ),
                                    onSubmitted: (String? value) {
                                      if (value!.isNotEmpty) {
                                        restController.getRestaurantSearchProductList(
                                          _searchController.text.trim(), Get.find<RestaurantController>().restaurant!.id.toString(), 1, restController.type,
                                        );
                                      }
                                    },
                                    onChanged: (String? value) {},
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                              ],
                            ),
                          ) : InkWell(
                            onTap: () async {
                              await Get.toNamed(RouteHelper.getSearchRestaurantProductRoute(restaurant!.id));
                              if (restController.isSearching) {
                                restController.changeSearchStatus();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall - 2),
                              child: Image.asset(Images.search, height: 20, width: 20, color: Theme.of(context).primaryColor, fit: BoxFit.cover),
                            ),
                          ),

                          restController.type.isNotEmpty ? VegFilterWidget(
                            type: restController.type,
                            iconColor: Theme.of(context).primaryColor,
                            onSelected: (String type) {
                              restController.getRestaurantCategoryFoods(restController.restaurant!.id!, type);
                            },
                          ) : const SizedBox(),

                        ]),
                      ),
                      const Divider(thickness: 0.2, height: 10),

                      // Only the category tabs rebuild when _activeCategoryNotifier changes
                      ValueListenableBuilder<int>(
                        valueListenable: _activeCategoryNotifier,
                        builder: (context, activeIndex, _) {
                          return SizedBox(
                            height: 32,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final bool isSelected = index == activeIndex;
                                return InkWell(
                                  onTap: () => _scrollToCategory(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,
                                        vertical: Dimensions.paddingSizeExtraSmall),
                                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                                    ),
                                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Text(
                                        categories[index].name ?? '',
                                        style: isSelected
                                            ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                            : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                      ),
                                    ]),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ]),
                  ))),
                ) : const SliverToBoxAdapter(child: SizedBox()),

                // food list
                SliverToBoxAdapter(child: FooterViewWidget(
                  child: Center(child: Container(
                    width: Dimensions.webMaxWidth,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                    child: restController.isSearching
                      ? PaginatedListViewWidget(
                          scrollController: scrollController,
                          onPaginate: (int? offset) {
                            restController.getRestaurantSearchProductList(
                              restController.searchText, Get.find<RestaurantController>().restaurant!.id.toString(), offset!, restController.type,
                            );
                          },
                          totalSize: restController.restaurantSearchProductModel?.totalSize,
                          offset: restController.restaurantSearchProductModel?.offset,
                          productView: ProductViewWidget(
                            isRestaurant: false,
                            restaurants: null,
                            products: restController.restaurantSearchProductModel?.products,
                            inRestaurantPage: true,
                          ),
                        )
                      : _buildGroupedFoodList(categoryFoodsModel, categories),
                  )),
                )),

                if(!ResponsiveHelper.isDesktop(context)) const SliverToBoxAdapter(child: SizedBox(height: 120)),

              ],
              ),
              GetBuilder<CartController>(builder: (cartController) {
                int? restaurantId = widget.restaurant?.id ?? Get.find<RestaurantController>().restaurant?.id;
                return AnimatedBuilder(
                  animation: scrollController,
                  builder: (context, child) {
                    final bool isAtBottom = isDesktop && scrollController.hasClients && scrollController.position.hasContentDimensions && scrollController.position.pixels >= (scrollController.position.maxScrollExtent - 2);
                    return cartController.cartList(restaurantId!).isNotEmpty && !isAtBottom ? Positioned(
                      left: 0, right: 0, bottom: 0,
                      child: BottomCartWidget(restaurantId:restaurantId, fromDineIn: widget.fromDineIn, showGlobalCardWise: false,),
                    ) : const SizedBox();
                  },
                );
              }),
            ]) : const RestaurantScreenShimmerWidget();
        });
      }),
    );
  }

  Widget _buildGroupedFoodList(RestaurantCategoryFoodsModel? model, List<RestaurantCategoryItem> categories) {
    if (model == null || categories.isEmpty) {
      return ProductViewWidget(
        isRestaurant: false,
        restaurants: null,
        products: const [],
        inRestaurantPage: true,
      );
    }

    // Regenerate keys and schedule offset calculation only when the model instance changes
    if (model != _lastModel) {
      _lastModel = model;
      _sectionKeys = List.generate(categories.length, (_) => GlobalKey());
      _sectionOffsets = [];
      _activeCategoryNotifier.value = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculateSectionOffsets());
    }

    final foodsMap = model.categoryWiseFoods ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(categories.length, (i) {
        return RestaurantCategorySectionWidget(
          key: _sectionKeys[i],
          category: categories[i],
          products: foodsMap[categories[i].id.toString()] ?? [],
        );
      }),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}

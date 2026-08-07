import 'package:stackfood_multivendor/api/api_checker.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/cart_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_bundle_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/services/cart_service_interface.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class CartController extends GetxController implements GetxService {
  final CartServiceInterface cartServiceInterface;
  CartController({required this.cartServiceInterface});

  List<CartModel> cartList(int restaurantId) {
    int bundleIndex = getBundleIndexByRestaurantId(restaurantId);
    if(bundleIndex == -1) return [];
    return _cartBundleList[bundleIndex].carts ?? [];
  }

  double _subTotal = 0;
  double get subTotal => _subTotal;

  double _itemPrice = 0;
  double get itemPrice => _itemPrice;

  double _itemDiscountPrice = 0;
  double get itemDiscountPrice => _itemDiscountPrice;

  double _addOnsPrice = 0;
  double get addOns => _addOnsPrice;

  List<List<AddOns>> _addOnsList = [];
  List<List<AddOns>> get addOnsList => _addOnsList;

  List<bool> _availableList = [];
  List<bool> get availableList => _availableList;

  bool _addCutlery = false;
  bool get addCutlery => _addCutlery;

  int _notAvailableIndex = -1;
  int get notAvailableIndex => _notAvailableIndex;

  List<String> notAvailableList = ['Remove it from my cart', 'I’ll wait until it’s restocked', 'Please cancel the order', 'Call me ASAP', 'Notify me when it’s back'];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _variationPrice = 0;
  double get variationPrice => _variationPrice;

  bool _needExtraPackage = true;
  bool get needExtraPackage => _needExtraPackage;

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  List<CartBundleModel> _cartBundleList = [];
  List<CartBundleModel> get cartBundleList => _cartBundleList;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  int? _deletingRestaurantId;
  int? get deletingRestaurantId => _deletingRestaurantId;


  void toggleExtraPackage({bool willUpdate = true}) {
    _needExtraPackage = !_needExtraPackage;
    if(willUpdate) {
      update();
    }
  }

  void setNeedExtraPackage(bool needExtraPackage) {
    _needExtraPackage = needExtraPackage;
    update();
  }

  double calculationCart(int restaurantId){
    _itemPrice = 0 ;
    _itemDiscountPrice = 0;
    _subTotal = 0;
    _addOnsPrice = 0;
    _availableList= [];
    _addOnsList = [];
    _variationPrice = 0;
    double variationWithoutDiscountPrice = 0;
    double variationPrice = 0;
    int currentBundleIndex = getBundleIndexByRestaurantId(restaurantId);
    List<CartModel> currentCartList = currentBundleIndex == -1 ? [] : (_cartBundleList[currentBundleIndex].carts ?? []);
    for (var cartModel in currentCartList) {

      variationWithoutDiscountPrice = 0;
      variationPrice = 0;

      double? discount = cartModel.product!.restaurantDiscount == 0 ? cartModel.product!.discount : cartModel.product!.restaurantDiscount;
      String? discountType = cartModel.product!.restaurantDiscount == 0 ? cartModel.product!.discountType : 'percent';

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      _addOnsList.add(addOnList);
      _availableList.add(DateConverter.isAvailable(cartModel.product!.availableTimeStarts, cartModel.product!.availableTimeEnds));

      _addOnsPrice = cartServiceInterface.calculateAddonsPrice(addOnList, _addOnsPrice, cartModel);

      variationWithoutDiscountPrice = cartServiceInterface.calculateVariationWithoutDiscountPrice(cartModel, variationWithoutDiscountPrice, discount, discountType);
      variationPrice = cartServiceInterface.calculateVariationPrice(cartModel, variationPrice);

      double price = (cartModel.product!.price! * cartModel.quantity!);
      double discountPrice =  (price - (PriceConverter.convertWithDiscount(cartModel.product!.price!, discount, discountType)! * cartModel.quantity!));

      _variationPrice += variationPrice;
      _itemPrice = _itemPrice + price;
      _itemDiscountPrice = _itemDiscountPrice + discountPrice + (variationPrice - variationWithoutDiscountPrice);

      debugPrint('==check : ${currentCartList.indexOf(cartModel)} ====> $_itemDiscountPrice = $_itemDiscountPrice + $discountPrice + ($variationPrice - $variationWithoutDiscountPrice)');
    }
    _subTotal = (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;

    if (Get.find<RestaurantController>().restaurant != null && Get.find<RestaurantController>().restaurant!.discount != null) {
      if (Get.find<RestaurantController>().restaurant!.discount!.maxDiscount != 0 && Get.find<RestaurantController>().restaurant!.discount!.maxDiscount! < _itemDiscountPrice) {
        _itemDiscountPrice = Get.find<RestaurantController>().restaurant!.discount!.maxDiscount!;
        _subTotal = (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;
      }
      if (Get.find<RestaurantController>().restaurant!.discount!.minPurchase != 0 && Get.find<RestaurantController>().restaurant!.discount!.minPurchase! > _subTotal) {
        _itemDiscountPrice = 0;
        _subTotal = (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;
      }
    }
    return _subTotal;
  }

  double calculationCartGlobal(){
    double totalPrice = 0.0;
    for(int i =0; i< cartBundleList.length; i++){
      double itemPrice = 0 ;
      double itemDiscountPrice = 0;
      double subTotal = 0;
      double addOnsPrice = 0;
      List availableList= [];
      List addOnsList = [];
      double variationPrice0 = 0;
      double variationWithoutDiscountPrice = 0;
      double variationPrice = 0;
      for (var cartModel in cartBundleList[i].carts!) {

        variationWithoutDiscountPrice = 0;
        variationPrice = 0;

        double? discount = cartModel.product!.restaurantDiscount == 0 ? cartModel.product!.discount : cartModel.product!.restaurantDiscount;
        String? discountType = cartModel.product!.restaurantDiscount == 0 ? cartModel.product!.discountType : 'percent';

        List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

        addOnsList.add(addOnList);
        availableList.add(DateConverter.isAvailable(cartModel.product!.availableTimeStarts, cartModel.product!.availableTimeEnds));

        addOnsPrice = cartServiceInterface.calculateAddonsPrice(addOnList, addOnsPrice, cartModel);

        variationWithoutDiscountPrice = cartServiceInterface.calculateVariationWithoutDiscountPrice(cartModel, variationWithoutDiscountPrice, discount, discountType);
        variationPrice = cartServiceInterface.calculateVariationPrice(cartModel, variationPrice);

        double price = (cartModel.product!.price! * cartModel.quantity!);
        double discountPrice =  (price - (PriceConverter.convertWithDiscount(cartModel.product!.price!, discount, discountType)! * cartModel.quantity!));

        variationPrice0 += variationPrice;
        itemPrice = itemPrice + price;
        itemDiscountPrice = itemDiscountPrice + discountPrice + (variationPrice - variationWithoutDiscountPrice);

        debugPrint('==check : ${cartBundleList[i].carts!.indexOf(cartModel)} ====> $itemDiscountPrice = $itemDiscountPrice + $discountPrice + ($variationPrice - $variationWithoutDiscountPrice)');
      }
      subTotal = (itemPrice - itemDiscountPrice) + addOnsPrice + variationPrice0;

      if (Get.find<RestaurantController>().restaurant != null && Get.find<RestaurantController>().restaurant!.discount != null) {
        if (Get.find<RestaurantController>().restaurant!.discount!.maxDiscount != 0 && Get.find<RestaurantController>().restaurant!.discount!.maxDiscount! < itemDiscountPrice) {
          itemDiscountPrice = Get.find<RestaurantController>().restaurant!.discount!.maxDiscount!;
          subTotal = (itemPrice - itemDiscountPrice) + addOnsPrice + variationPrice0;
        }
        if (Get.find<RestaurantController>().restaurant!.discount!.minPurchase != 0 && Get.find<RestaurantController>().restaurant!.discount!.minPurchase! > subTotal) {
          itemDiscountPrice = 0;
          subTotal = (itemPrice - itemDiscountPrice) + addOnsPrice + variationPrice0;
        }
      }
      totalPrice += subTotal;
    }
    return totalPrice;
  }

  Future<int?> reorderAddToCart(List<OnlineCart> cartList) async {
    return _addMultipleCartItemOnline(cartList);
  }

  int itemCountOfGlobalCart(){
    int count = 0;
    for(int i =0; i < cartBundleList.length; i++){
      count += cartBundleList[i].carts?.length ?? 0;
    }
    return count;
  }

  int getBundleIndexByRestaurantId(int restaurantId){
    for (int bIndex = 0; bIndex < (cartBundleList.length); bIndex++) {
      if (cartBundleList[bIndex].restaurant?.id == restaurantId) {
        return bIndex;
      }
    }
    return -1;
  }

  Future<void> setQuantity(bool isIncrement, CartModel cart, {int? cartIndex, required int restaurantId, int? bundleIndex}) async {
    if(_isLoading) return; // block concurrent quantity change
    bundleIndex ??= getBundleIndexByRestaurantId(restaurantId);
    _isLoading = true;
    update();
    int index = cartIndex ?? _cartBundleList[bundleIndex].carts!.indexOf(cart);
    _cartBundleList[bundleIndex].carts![index].quantity = await cartServiceInterface.decideProductQuantity(_cartBundleList[bundleIndex].carts!, isIncrement, index);
    cartServiceInterface.addToSharedPrefCartList(_cartBundleList);

    calculationCart(restaurantId);
    await updateCartQuantityOnline(_cartBundleList[bundleIndex].carts![index].id!, _cartBundleList[bundleIndex].carts![index].price!, _cartBundleList[bundleIndex].carts![index].quantity!, restaurantId);
    _isLoading = false;
    update();
  }

  Future<void> removeFromCart({required int cartIndex, required int restaurantId}) async {
    if(_isLoading) return; // block concurrent remove
    _isLoading = true;
    int bIndex = getBundleIndexByRestaurantId(restaurantId);
    int cartId = _cartBundleList[bIndex].carts![cartIndex].id!;
    _cartBundleList[bIndex].carts!.removeAt(cartIndex);
    update();
    await removeCartItemOnline(cartId, restaurantId);
  }

  Future<void> clearCartList() async {
    _cartBundleList = [];
    update();
  }

  void removeAddOn(int bundleIndex, int index, int addOnIndex) {
    _cartBundleList[bundleIndex].carts![index].addOnIds!.removeAt(addOnIndex);
    cartServiceInterface.addToSharedPrefCartList(_cartBundleList);
    calculationCart(_cartBundleList[bundleIndex].restaurant!.id!);
    update();
  }

  (int bundleIndex, int cartIndex) isExistInCart(int? productID, int restaurantId,) {
    return cartServiceInterface.isExistInCart(productID, restaurantId, cartBundleList);
  }

  void updateCutlery({bool isUpdate = true}){
    _addCutlery = !_addCutlery;
    if(isUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool willUpdate = true}){
    _notAvailableIndex = cartServiceInterface.setAvailableIndex(index, _notAvailableIndex);
    if(willUpdate) {
      update();
    }
  }

  int cartQuantity(int productID, int restaurantId) {
    return cartServiceInterface.cartQuantity(productID, restaurantId, _cartBundleList);
  }

  Future<void> addToCartOnline(OnlineCart onlineCart, {CartModel? existCartData, bool fromDirectlyAdd = false}) async {
    if(AddressHelper.getAddressFromSharedPref() == null) {
      Get.find<SplashController>().navigateToLocationScreen('home');
      return;
    }

    _isLoading = true;
    update();
    Response response = await cartServiceInterface.addToCartOnline(onlineCart, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());

    if(response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      List<CartModel> tempCartList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
      await _updateGlobalCartData(onlineCart.restaurantId!, tempCartList);
      calculationCart(onlineCart.restaurantId!);
      if(!fromDirectlyAdd) {
        Get.back();
      }
      if(!Get.currentRoute.contains(RouteHelper.restaurant)) {
        showCartSnackBarWidget(restaurantId: onlineCartList.first.product?.restaurantId);
      }
    } else if(response.statusCode == 403 && response.body['errors'][0]['code'] == 'stock_out') {
      showCustomSnackBar(response.body['errors'][0]['message']);
      Get.find<ProductController>().getProductDetails(onlineCart.itemId!, existCartData);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<void> _updateGlobalCartData(int restaurantId, List<CartModel> cartList)async{
    int bundleIndex = getBundleIndexByRestaurantId(restaurantId);
    if(bundleIndex == -1){
      await getCartBundleList();
    }else{
      _cartBundleList[bundleIndex].carts = cartList;
      _cartBundleList[bundleIndex].restaurant?.itemCount = cartList.length;
    }
  }

  Future<int?> _addMultipleCartItemOnline(List<OnlineCart> cartList) async {
    _isLoading = true;
    update();
    Response response = await cartServiceInterface.addMultipleCartItemOnline(cartList);
    if(response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      List<CartModel> tempCartList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
      await _updateGlobalCartData(cartList.first.restaurantId!, tempCartList);
      calculationCart(cartList.first.restaurantId!);
    }
    _isLoading = false;
    update();
    return response.statusCode;
  }

  Future<void> updateCartOnline(OnlineCart onlineCart, {CartModel? existCartData}) async {
    _isLoading = true;
    update();
    Response response = await cartServiceInterface.updateCartOnline(onlineCart, AuthHelper.isLoggedIn() ? null : int.parse(AuthHelper.getGuestId()));
    if(response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      List<CartModel> tempCartList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
      await _updateGlobalCartData(onlineCart.restaurantId!, tempCartList);
      calculationCart(onlineCart.restaurantId!);
      Get.back();
      if(!Get.currentRoute.contains(RouteHelper.restaurant)) {
        showCartSnackBarWidget();
      }
    } else if(response.statusCode == 403 && response.body['errors'][0]['code'] == 'stock_out') {
      showCustomSnackBar(response.body['errors'][0]['message']);
      Get.find<ProductController>().getProductDetails(onlineCart.itemId!, existCartData);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateCartQuantityOnline(int cartId, double price, int quantity, int restaurantId) async {
    bool success = await cartServiceInterface.updateCartQuantityOnline(cartId, price, quantity, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(), restaurantId: restaurantId);
    if(success) {
      await getCartDataOnline(restaurantId);
      calculationCart(restaurantId);
    }
  }

  Future<void> getCartDataOnline(int restaurantId) async {
    _isLoading = true;
    List<OnlineCartModel> onlineCartList = await cartServiceInterface.getCartDataOnline(AuthHelper.isLoggedIn() ? null : int.tryParse(AuthHelper.getGuestId()), restaurantId);
    List<CartModel> tempCartList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
    await _updateGlobalCartData(restaurantId, tempCartList);
    calculationCart(restaurantId);
    _isLoading = false;
    update();
  }

  Future<bool> removeCartItemOnline(int cartId, int restaurantId) async {
    _isLoading = true;
    update();
    bool isSuccess = await cartServiceInterface.removeCartItemOnline(cartId, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(), restaurantId);
    await getCartDataOnline(restaurantId,);
    _isLoading = false;
    update();
    return isSuccess;
  }

  void setExpanded(bool setExpand) {
    _isExpanded = setExpand;
    update();
  }

  Future<void> getCartBundleList() async {
    _isLoading = true;
    update();
    _cartBundleList = await cartServiceInterface.getCartBundleList(
      guestId: AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(),
    )??[];
    _isLoading = false;
    update();
  }

  Future<bool> removeCartBundle(int restaurantId) async {
    _isDeleting = true;
    _deletingRestaurantId = restaurantId;
    update();
    bool success = await cartServiceInterface.removeCartBundle(
      restaurantId,
      guestId: AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(),
    );
    if (success) {
      _cartBundleList.removeWhere((cart) => cart.restaurant?.id == restaurantId);
    }
    _isDeleting = false;
    _deletingRestaurantId = null;
    update();
    return success;
  }

}
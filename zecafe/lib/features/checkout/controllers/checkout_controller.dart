import 'package:country_code_picker/country_code_picker.dart';
import 'package:stackfood_multivendor/api/api_checker.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/offline_method_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/timeslote_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/order_successfull_dialog_widget.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/partial_pay_dialog.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:universal_html/html.dart' as html;

class CheckoutController extends GetxController implements GetxService {
  final CheckoutServiceInterface checkoutServiceInterface;
  CheckoutController({required this.checkoutServiceInterface});

  AddressModel? _address;
  AddressModel? get address => _address;

  Restaurant? _restaurant;
  Restaurant? get restaurant => _restaurant;

  String _preferableTime = '';
  String get preferableTime => _preferableTime;

  List<OfflineMethodModel>? _offlineMethodList;
  List<OfflineMethodModel>? get offlineMethodList => _offlineMethodList;

  int _selectedOfflineBankIndex = 0;
  int get selectedOfflineBankIndex => _selectedOfflineBankIndex;

  bool _isPartialPay = false;
  bool get isPartialPay => _isPartialPay;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDistanceLoading = false;
  bool get isDistanceLoading => _isDistanceLoading;

  int _selectedTips = 0;
  int get selectedTips => _selectedTips;

  double _tips = 0.0;
  double get tips => _tips;

  final TextEditingController couponController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController tipController = TextEditingController(text: '0');
  String addressType = '';
  final TextEditingController addressController = TextEditingController();
  final TextEditingController streetNumberController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();

  bool _customDateRestaurantClose = false;
  bool get customDateRestaurantClose => _customDateRestaurantClose;

  DateTime? _selectedCustomDate;
  DateTime? get selectedCustomDate => _selectedCustomDate;

  int? _mostDmTipAmount;
  int? get mostDmTipAmount => _mostDmTipAmount;

  String _orderType = 'delivery';
  String get orderType => _orderType;

  bool _subscriptionOrder = false;
  bool get subscriptionOrder => _subscriptionOrder;

  DateTimeRange? _subscriptionRange;
  DateTimeRange? get subscriptionRange => _subscriptionRange;

  String? _subscriptionType = 'daily';
  String? get subscriptionType => _subscriptionType;

  int _subscriptionTypeIndex = 0;
  int get subscriptionTypeIndex => _subscriptionTypeIndex;

  List<DateTime?> _selectedDays = [null];
  List<DateTime?> get selectedDays => _selectedDays;

  double? _distance;
  double? get distance => _distance;

  double? _extraCharge;
  double? get extraCharge => _extraCharge;

  double _viewTotalPrice = 0;
  double? get viewTotalPrice => _viewTotalPrice;

  int _paymentMethodIndex = -1;
  int get paymentMethodIndex => _paymentMethodIndex;

  List<TextEditingController> informationControllerList = [];

  List<FocusNode> informationFocusList = [];

  List<TimeSlotModel>? _timeSlots;
  List<TimeSlotModel>? get timeSlots => _timeSlots;

  List<TimeSlotModel>? _allTimeSlots;
  List<TimeSlotModel>? get allTimeSlots => _allTimeSlots;

  List<int>? _slotIndexList;
  List<int>? get slotIndexList => _slotIndexList;

  int _selectedDateSlot = 0;
  int get selectedDateSlot => _selectedDateSlot;

  int? _selectedTimeSlot = 0;
  int? get selectedTimeSlot => _selectedTimeSlot;

  AddressModel? _guestAddress;
  AddressModel? get guestAddress => _guestAddress;

  bool _isDmTipSave = false;
  bool get isDmTipSave => _isDmTipSave;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  String? countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
      : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode ?? Get.find<LocalizationController>().locale.countryCode;

  int _selectedInstruction = -1;
  int get selectedInstruction => _selectedInstruction;

  bool _canShowTimeSlot = false;
  bool get canShowTimeSlot => _canShowTimeSlot;

  bool _canShowTipsField = false;
  bool get canShowTipsField => _canShowTipsField;

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  bool _isLoadingUpdate = false;
  bool get isLoadingUpdate => _isLoadingUpdate;

  String? _estimateDineInTime;
  String? get estimateDineInTime => _estimateDineInTime;

  DateTime? _selectedDineInDate;
  DateTime? get selectedDineInDate => _selectedDineInDate;

  DateTime? _orderPlaceDineInDateTime;
  DateTime? get orderPlaceDineInDateTime => _orderPlaceDineInDateTime;

  double _exchangeAmount = 0;
  double get exchangeAmount => _exchangeAmount;

  bool _isFirstTime = true;
  bool get isFirstTime => _isFirstTime;

  bool _isCashBackFirstTime = true;
  bool get isCashBackFirstTime => _isCashBackFirstTime;

  double? _orderTax = 0.0;
  double? get orderTax => _orderTax;

  int? _taxIncluded;
  int? get taxIncluded => _taxIncluded;

  bool _showMoreDetails = false;
  bool get showMoreDetails => _showMoreDetails;

  bool _showChangeAmount = true;
  bool get showChangeAmount => _showChangeAmount;

  String? _saverDeliveryType = 'standard';
  String? get saverDeliveryType => _saverDeliveryType;

  ZoneData? _saverZoneData;
  ZoneData? get saverZoneData => _saverZoneData;

  ZoneData? _getRestaurantZoneData(Restaurant? restaurant) {
    try {
      return AddressHelper.getAddressFromSharedPref()?.zoneData?.firstWhere((zone) => zone.id == restaurant?.zoneId);
    } catch (_) {
      return null;
    }
  }

  DeliveryOptions? get selectedSaverDeliveryOption {
    if(_saverZoneData?.deliveryOptions == null) {
      return null;
    }
    for(final deliveryOption in _saverZoneData!.deliveryOptions!) {
      if(deliveryOption.deliveryType == _saverDeliveryType) {
        return deliveryOption;
      }
    }
    return null;
  }

  double getSaverDeliveryChargeAdjustment({DeliveryOptions? deliveryOption}) {
    if(deliveryOption == null) {
      return 0;
    }
    if(deliveryOption.extraCharge != null) {
      return deliveryOption.extraCharge!;
    }
    if(deliveryOption.reduceCharge != null) {
      return -deliveryOption.reduceCharge!;
    }
    return 0;
  }

  double? getCalculatedDeliveryCharge({
    required Restaurant? restaurant,
    required double orderAmount,
    bool returnDeliveryCharge = true,
    bool returnMaxCodOrderAmount = false,
  }) {
    final zoneData = _getRestaurantZoneData(restaurant);

    if(restaurant == null || zoneData == null || distance == null) {
      return null;
    }

    double perKmCharge = restaurant.selfDeliverySystem == 1 ? restaurant.perKmShippingCharge!
        : zoneData.perKmShippingCharge ?? 0;

    double minimumCharge = restaurant.selfDeliverySystem == 1 ? restaurant.minimumShippingCharge!
        : zoneData.minimumShippingCharge ?? 0;

    double? maximumCharge = restaurant.selfDeliverySystem == 1 ? restaurant.maximumShippingCharge
        : zoneData.maximumShippingCharge;

    double deliveryCharge = distance! * perKmCharge;
    double charge = distance! * perKmCharge;

    if(deliveryCharge < minimumCharge) {
      deliveryCharge = minimumCharge;
      charge = minimumCharge;
    }

    if(restaurant.selfDeliverySystem == 0 && extraCharge != null){
      deliveryCharge = deliveryCharge + extraCharge!;
      charge = charge + extraCharge!;
    }
    if(maximumCharge != null && deliveryCharge > maximumCharge){
      deliveryCharge = maximumCharge;
      charge = maximumCharge;
    }

    if(restaurant.selfDeliverySystem == 0 && zoneData.increasedDeliveryFeeStatus == 1){
      deliveryCharge = deliveryCharge + (deliveryCharge * (zoneData.increasedDeliveryFee!/100));
      charge = charge + charge * (zoneData.increasedDeliveryFee!/100);
    }

    if(restaurant.selfDeliverySystem == 0 && _matchedBusinessSetupSpecificCriteria(orderAmount: orderAmount)) {
      deliveryCharge = 0;
      charge = 0;
    }

    if(restaurant.selfDeliverySystem == 1 && restaurant.freeDeliveryDistanceStatus! && restaurant.freeDeliveryDistanceValue! >= distance!){
      deliveryCharge = 0;
      charge = 0;
    }

    if(returnMaxCodOrderAmount) {
      return zoneData.maxCodOrderAmount;
    }

    return returnDeliveryCharge ? deliveryCharge : charge;
  }

  bool _matchedBusinessSetupSpecificCriteria({required double orderAmount}) {
    ConfigModel? configModel = Get.find<SplashController>().configModel;
    if(configModel?.adminFreeDelivery?.type == 'free_delivery_to_all_store') return true;

    final bool isSpecificCriteriaFreeDelivery = configModel?.adminFreeDelivery?.status == true
        && configModel?.adminFreeDelivery?.type == 'free_delivery_by_specific_criteria';
    final double freeDeliveryOver = configModel?.adminFreeDelivery?.freeDeliveryOver ?? 0;
    final double freeDeliveryDistance = configModel?.adminFreeDelivery?.freeDeliveryDistance ?? 0;
    final bool hasAmountCriteria = freeDeliveryOver > 0;
    final bool hasDistanceCriteria = freeDeliveryDistance > 0;
    final bool amountCriteriaMatched = hasAmountCriteria && orderAmount >= freeDeliveryOver;
    final bool distanceCriteriaMatched = hasDistanceCriteria && freeDeliveryDistance >= (distance ?? 0);
    final bool specificCriteriaMatched = isSpecificCriteriaFreeDelivery && (
        (hasAmountCriteria && hasDistanceCriteria && amountCriteriaMatched && distanceCriteriaMatched)
            || (hasAmountCriteria && !hasDistanceCriteria && amountCriteriaMatched)
            || (!hasAmountCriteria && hasDistanceCriteria && distanceCriteriaMatched)
    );

    return specificCriteriaMatched;
  }

  // double? getSaverOptionTotalDeliveryCharge({
  //   required Restaurant? restaurant,
  //   DeliveryOptions? deliveryOption,
  // }) {
  //   final double? baseDeliveryCharge = getCalculatedDeliveryCharge(
  //     restaurant: restaurant,
  //     returnDeliveryCharge: true,
  //   );
  //
  //   if(baseDeliveryCharge == null) {
  //     return null;
  //   }
  //
  //   return math.max(0, baseDeliveryCharge + getSaverDeliveryChargeAdjustment(
  //     deliveryOption: deliveryOption,
  //   ));
  // }


  void setSaverDeliveryType(String type) {
    _saverDeliveryType = type;
    update();
  }

  void _setSaverDeliveryData() {
    _saverZoneData = AddressHelper.getAddressFromSharedPref()?.zoneData?.firstWhere((zone) => zone.id == restaurant?.zoneId);
    if(_saverZoneData != null && _saverZoneData!.additionalDeliveryOptionStatus!) {
      _saverDeliveryType = _saverZoneData?.deliveryOptions?.first.deliveryType??'';
    }
  }

  void setShowChangeAmount(bool value){
    _showChangeAmount = value;
    update();
  }

  void setShowMoreDetails(bool value, {bool willUpdate = true}) {
    _showMoreDetails = value;
    if(willUpdate) {
      update();
    }
  }

  void updateFirstTime() {
    _isFirstTime = true;
    update();
  }

  void setExchangeAmount(double value) {
    _exchangeAmount = value;
  }

  void setSelectedDineInDate(DateTime? date, {bool willUpdate = true}) {
    _estimateDineInTime = null;
    _selectedDineInDate = date;
    if(willUpdate) {
      update();
    }
  }

  void setOrderPlaceDineInDateTime(DateTime? value) {
    _orderPlaceDineInDateTime = value;
  }

  void setEstimateDineInTime(String? value) {
    _estimateDineInTime = value;
    update();
  }

  void initDineInSetup() {
    _estimateDineInTime = null;
    _selectedDineInDate = null;
    _orderPlaceDineInDateTime = null;
  }

  void showTipsField(){
    _canShowTipsField = !_canShowTipsField;
    update();
  }

  void showHideTimeSlot(){
    _canShowTimeSlot = !_canShowTimeSlot;
    update();
  }

  void setInstruction(int index, {bool willUpdate = true}){
    _selectedInstruction = checkoutServiceInterface.selectInstruction(index, _selectedInstruction);
    if(willUpdate) {
      update();
    }
  }

  void setDateCloseRestaurant(bool status) {
    _customDateRestaurantClose = status;
    update();
  }

  void changeDigitalPaymentName(String name){
    _digitalPaymentName = name;
    update();
  }

  Future<bool> saveOfflineInfo(String data) async {
    _isLoading = true;
    update();
    bool success = await checkoutServiceInterface.saveOfflineInfo(data, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    if (success) {
      _isLoading = false;
      _guestAddress = null;
    }
    update();
    return success;
  }

  void setGuestAddress(AddressModel? address) {
    _guestAddress = address;
    update();
  }

  void expandedUpdate(bool status){
    _isExpanded = status;
    update();
  }

  void setPaymentMethod(int index, {bool willUpdate = true}) {
    _paymentMethodIndex = index;
    index == 0 ? _showChangeAmount = true : _showChangeAmount = false;

    if(willUpdate) update();
  }

  void selectOfflineBank(int index){
    _selectedOfflineBankIndex = index;
    update();
  }

  void changesMethod() {
    List<MethodInformations>? methodInformation = offlineMethodList![selectedOfflineBankIndex].methodInformations!;

    informationControllerList = checkoutServiceInterface.generateTextControllerList(methodInformation);
    informationFocusList = checkoutServiceInterface.generateFocusList(methodInformation);

    update();
  }

  Future<double?> getExtraCharge(double? distance) async {
    _extraCharge = await checkoutServiceInterface.getExtraCharge(distance);
    return _extraCharge;
  }

  void setTotalAmount(double amount){
    _viewTotalPrice = amount;
  }

  Future<void> setRestaurantDetails({int? restaurantId}) async {
    if(Get.find<RestaurantController>().restaurant == null) {
      await Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantId));
    }
    _restaurant = Get.find<RestaurantController>().restaurant;
    _setSaverDeliveryData();
    Future.delayed(const Duration(milliseconds: 600), () => update());
  }

  Future<void> initCheckoutData(int? restaurantID) async {
    Get.find<CouponController>().removeCouponData(false);
    await Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantID));
    initializeTimeSlot(Get.find<RestaurantController>().restaurant!);
    insertAddresses(null);
  }

  bool isRestaurantClosed(DateTime dateTime, bool active, List<Schedules>? schedules, {int? customDateDuration}) {
    return Get.find<RestaurantController>().isRestaurantClosed(dateTime, active, schedules);
  }

  Future<void> getDmTipMostTapped() async {
    _mostDmTipAmount = await checkoutServiceInterface.getDmTipMostTapped();
    update();
  }

  void setPreferenceTimeForView(String time, bool instanceOrder, {bool isUpdate = true}){
    _preferableTime = checkoutServiceInterface.setPreferenceTimeForView(time, instanceOrder);
    if(isUpdate) {
      update();
    }
  }

  void setCustomDate(DateTime? date, bool instanceOrder, {bool canUpdate = true}) {
    _selectedCustomDate = date;
    // _selectedTimeSlot = checkoutServiceInterface.selectTimeSlot(instanceOrder);

    if(canUpdate) {
      update();
    }
  }

  Future<void> getOfflineMethodList() async {
    _offlineMethodList = await checkoutServiceInterface.getOfflineMethodList();
    update();
  }

  void changePartialPayment({bool isUpdate = true}){
    _isPartialPay = !_isPartialPay;
    if(isUpdate) {
      update();
    }
  }

  void stopLoader({bool isUpdate = true}) {
    _isLoading = false;
    if(isUpdate) {
      update();
    }
  }

  void updateTimeSlot(int? index, bool instanceOrder, {bool notify = true}) {
    if(!instanceOrder) {
      if(index == 0) {
        if(notify) {
          showCustomSnackBar('instance_order_is_not_active'.tr);
        }
      } else {
        _selectedTimeSlot = index;
      }
    } else {
      _selectedTimeSlot = index;
    }
    if(notify) {
      update();
    }
  }

  void updateTips(int index, {bool notify = true}) {
    _selectedTips = index;
    _tips = checkoutServiceInterface.updateTips(index, _selectedTips);

    if(notify) {
      update();
    }
  }

  Future<void> addTips(double tips, {bool notify = true}) async {
    _tips = tips;
    if(notify) {
      update();
    }
  }

  void setOrderType(String type, {bool notify = true}) {
    _orderType = type;
    if(type == 'dine_in') {
      if(_restaurant != null) {
        final today = DateTime.now();
        final isClosed = isRestaurantClosed(today, _restaurant!.active!, _restaurant!.schedules);
        if(!isClosed) {
          // Auto-select today's date and prime time slots for schedule validation
          _selectedDineInDate = today;
          updateDateSlot(today, true);
        }
        // If closed today, leave date null so user picks manually
      }
    } else {
      // Reset dine-in selection when switching to another order type
      _selectedDineInDate = null;
      _estimateDineInTime = null;
      _orderPlaceDineInDateTime = null;
    }
    if(notify) {
      update();
    }
  }

  void setSubscription(bool isSubscribed) {
    _subscriptionOrder = isSubscribed;
    _orderType = 'delivery';
    update();
  }

  void setSubscriptionRange(DateTimeRange range) {
    _subscriptionRange = range;
    update();
  }

  void setSubscriptionType(String? type, int index) {
    _subscriptionType = type;
    _selectedDays = [];
    for(int index=0; index < (type == 'weekly' ? 7 : type == 'monthly' ? 31 : 1); index++) {
      _selectedDays.add(null);
    }
    _subscriptionTypeIndex = index;
    update();
  }

  void addDay(int index, TimeOfDay? time) {
    if(time != null) {
      _selectedDays[index] = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);
    }else {
      _selectedDays[index] = null;
    }
    update();
  }

  Future<bool> checkBalanceStatus(double totalPrice, {double discount = 0, double extraCharge = 0}) async {
    totalPrice = (totalPrice - discount) + extraCharge;
    if(isPartialPay){
      changePartialPayment();
    }
    setPaymentMethod(-1);
    debugPrint('--total : $totalPrice , compare balance : ${Get.find<ProfileController>().userInfoModel!.walletBalance! < totalPrice}');
    if((Get.find<ProfileController>().userInfoModel!.walletBalance! < totalPrice) && (Get.find<ProfileController>().userInfoModel!.walletBalance! != 0.0)){
      Get.dialog(PartialPayDialog(isPartialPay: true, totalPrice: totalPrice), useSafeArea: false,);
    }else{
      Get.dialog(PartialPayDialog(isPartialPay: false, totalPrice: totalPrice), useSafeArea: false,);
    }

    update();
    return true;
  }

  void insertAddresses(AddressModel? addressModel, {bool notify = false}){
    _address = addressModel;

    addressType = _address?.addressType ?? '';
    addressController.text = _address?.address ?? '';
    streetNumberController.text = _address?.road ?? '';
    houseController.text = _address?.house ?? '';
    floorController.text = _address?.floor ?? '';
    if(notify) update();
  }

  Future<void> initializeTimeSlot(Restaurant restaurant) async {
    _timeSlots = await checkoutServiceInterface.initializeTimeSlot(restaurant, Get.find<SplashController>().configModel!.scheduleOrderSlotDuration);
    _allTimeSlots = await checkoutServiceInterface.initializeTimeSlot(restaurant, Get.find<SplashController>().configModel!.scheduleOrderSlotDuration);

    _validateSlot(_allTimeSlots!, DateTime.now(), notify: false);
  }

  void updateDateSlot(DateTime date, bool instanceOrder) {
    if(!instanceOrder && _selectedTimeSlot == 0) {
      _selectedTimeSlot = 1;
    }
    if(_allTimeSlots != null) {
      _validateSlot(_allTimeSlots!, date);
    }
    update();
  }

  void updateDateSlotIndex(int index) {
    _selectedDateSlot = index;
    update();
  }

  void _validateSlot(List<TimeSlotModel> slots, DateTime date, {bool notify = true}) {
    _timeSlots = checkoutServiceInterface.validateTimeSlot(slots, date);
    _slotIndexList = checkoutServiceInterface.validateSlotIndexes(slots, date);

    if(notify) {
      update();
    }
  }

  Future<double?> getDistanceInKM(LatLng originLatLng, LatLng destinationLatLng, {bool isDuration = false, bool isRiding = false, bool fromDashboard = false}) async {
    _isDistanceLoading = true;
    update();
    _distance = await checkoutServiceInterface.getDistanceInKM(originLatLng, destinationLatLng, isDuration: isDuration);

    if(!fromDashboard) {
      await getExtraCharge(_distance);
    }
    _isDistanceLoading = false;
    update();
    return _distance;
  }

  Future<String> placeOrder(PlaceOrderBodyModel placeOrderBody, int? zoneID, double amount, double? maximumCodOrderAmount, bool fromCart,
      bool isCashOnDeliveryActive, {bool isOfflinePay = false, int? restaurantId, double proDiscount = 0}) async {
    print("############order place order : $proDiscount");

    _isLoading = true;
    update();
    String orderID = '';
    Response response = await checkoutServiceInterface.placeOrder(placeOrderBody);
    _isLoading = false;
    if (response.statusCode == 200) {
      String? message = response.body['message'];
      orderID = response.body['order_id'].toString();
      noteController.clear();

      Response notificationResponse = await checkoutServiceInterface.sendNotificationRequest(orderID, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
      bool reloadHome = notificationResponse.body['reload_home'];

      if(reloadHome) {
        await HomeScreen.loadData(true);
      }
      Get.find<CartController>().getCartBundleList().then((_){
        print("---------->${Get.find<CartController>().cartBundleList}");
      });

      if(!isOfflinePay) {
        _callback(true, message, orderID, zoneID, amount, maximumCodOrderAmount, fromCart, isCashOnDeliveryActive, placeOrderBody.contactPersonNumber, placeOrderBody.orderType == 'dine_in', placeOrderBody.orderType == 'delivery', proDiscount: proDiscount);
      } else {
        Get.find<CartController>().getCartDataOnline(restaurantId!);
      }
      if (kDebugMode) {
        print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      if(!isOfflinePay){
        _callback(false, response.statusText, '-1', zoneID, amount, maximumCodOrderAmount, fromCart, isCashOnDeliveryActive, placeOrderBody.contactPersonNumber, placeOrderBody.orderType == 'dine_in' , placeOrderBody.orderType == 'delivery');
      }else{
        showCustomSnackBar(response.statusText);
      }
    }
    update();
    return orderID;
  }

  void _callback(bool isSuccess, String? message, String orderID, int? zoneID, double amount, double? maximumCodOrderAmount, bool fromCart, bool isCashOnDeliveryActive,
      String? contactNumber, bool isDineInOrder, bool isDeliveryOrder, {double proDiscount = 0}) async {
    if(isSuccess) {
      if(fromCart) {
        // Get.find<CartController>().clearCartList();
      }
      setGuestAddress(null);
      stopLoader();
      if(paymentMethodIndex == 0 || paymentMethodIndex == 1) {
        double total = ((amount / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
        Get.find<LoyaltyController>().saveEarningPoint(total.toStringAsFixed(0));
        if(isDineInOrder) {
          Get.offNamed(RouteHelper.getOrderDetailsRoute(int.parse(orderID), fromDineIn: true, contactNumber: contactNumber));
        } else if(ResponsiveHelper.isDesktop(Get.context)) {
          Get.offNamed(RouteHelper.getInitialRoute());
          Future.delayed(const Duration(seconds: 2) , () => Get.dialog(Center(child: SizedBox(height: 350, width : 500, child: OrderSuccessfulDialogWidget(orderID: orderID, contactNumber: contactNumber, isDeliveryOrder: isDeliveryOrder, proDiscount: proDiscount,)))));
        } else {
          Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, 'success', amount, contactNumber, isDeliveryOrder: isDeliveryOrder, proDiscount: proDiscount));
        }

      }else {
        if(GetPlatform.isWeb) {
          await Get.find<AuthController>().saveGuestNumber(contactNumber ?? '');
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl = '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID&customer_id=${Get.find<ProfileController>().userInfoModel?.id ?? Get.find<AuthController>().getGuestId()}'
              '&payment_method=$digitalPaymentName&payment_platform=web&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&amount=$amount&pro_discount=$proDiscount&status=';
          html.window.open(selectedUrl,"_self");
        } else{
          Get.offNamed(RouteHelper.getPaymentRoute(
            OrderModel(id: int.parse(orderID), userId: Get.find<ProfileController>().userInfoModel?.id ?? 0, orderAmount: amount, restaurant: Get.find<RestaurantController>().restaurant),
            digitalPaymentName, guestId: Get.find<AuthController>().getGuestId(), contactNumber: contactNumber,
          ),
          );
        }
      }
      clearPrevData();
      updateTips(0);
      Get.find<CouponController>().removeCouponData(false);
    }else {
      showCustomSnackBar(message);
    }
  }

  void clearPrevData() {
    _distance = null;
    _paymentMethodIndex = -1;
    _selectedDateSlot = 0;
    _selectedTimeSlot = 0;
    _subscriptionOrder = false;
    _selectedDays = [null];
    _subscriptionType = 'daily';
    _subscriptionRange = null;
    _isDmTipSave = false;
    _isCashBackFirstTime = true;
  }

  void toggleDmTipSave() {
    _isDmTipSave = !_isDmTipSave;
    update();
  }

  Future<bool> updateOfflineInfo(String data) async {
    _isLoadingUpdate = true;
    update();
    bool success = await checkoutServiceInterface.updateOfflineInfo(data, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    if (success) {
      _isLoadingUpdate = false;
    }
    update();
    return success;
  }

  Future<bool> checkRestaurantValidation({required Map<String, dynamic> data}) async {
    _isLoading = true;
    update();
    bool success = await checkoutServiceInterface.checkRestaurantValidation(data: data, guestId: Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    _isLoading = false;
    update();
    return success;
  }

  void saveDmTipIndex(String i){
    checkoutServiceInterface.saveDmTipIndex(i);
  }

  String getDmTipIndex() {
    return checkoutServiceInterface.getDmTipIndex();
  }

  Future<void> getOrderTax(PlaceOrderBodyModel placeOrderBody) async {
     Response response = await checkoutServiceInterface.getOrderTax(placeOrderBody);
    if(response.statusCode == 200) {
      _isFirstTime = false;
      _orderTax = double.tryParse(response.body['tax_amount'].toString()) ?? 0.0;
      _taxIncluded = response.body['tax_included'];
    } else {
      _isFirstTime = false;
      ApiChecker.checkApi(response);
    }
    update();
  }

  void makeFalseCashBackFirstTime() {
    _isCashBackFirstTime = false;
  }

}

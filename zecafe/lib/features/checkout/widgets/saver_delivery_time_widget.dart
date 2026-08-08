import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SaverDeliveryTimeWidget extends StatelessWidget {
  final CheckoutController checkoutController;
  final double deliveryCharge;
  final double originalDeliveryCharge;
  const SaverDeliveryTimeWidget({super.key, required this.checkoutController, required this.deliveryCharge, required this.originalDeliveryCharge});

  @override
  Widget build(BuildContext context) {
    final ZoneData? saverZoneData = checkoutController.saverZoneData;
    final bool isFreeDeliveryCouponApplied = Get.find<CouponController>().freeDelivery;
    final bool belowOriginalDeliveryCharge = saverZoneData?.minimumDeliveryCharge != null
        && originalDeliveryCharge >= 0
        && originalDeliveryCharge < saverZoneData!.minimumDeliveryCharge!;
    final bool belowCurrentDeliveryCharge = saverZoneData?.minimumDeliveryCharge != null
        && deliveryCharge >= 0
        && deliveryCharge < saverZoneData!.minimumDeliveryCharge!;
    final bool hasCurrentEligibleDeliveryCharge = deliveryCharge > 0 && !belowCurrentDeliveryCharge;
    final bool hadEligibleOriginalDeliveryCharge = originalDeliveryCharge > 0 && !belowOriginalDeliveryCharge;
    final bool disableSaverOptions = isFreeDeliveryCouponApplied && deliveryCharge == 0 && hadEligibleOriginalDeliveryCharge;

    final ProActiveBenefit? proBenefit = Get.find<ProController>().activeOfferModel?.benefit;
    final bool isPro = (Get.find<SplashController>().proStaus) && (Get.find<ProfileController>().isPro);
    // Full free delivery only applies once the pro min order amount (if any) is met.
    final bool meetsProMinOrder = proBenefit?.minOrderStatus != true
        || Get.find<CartController>().subTotal >= (proBenefit?.minOrderAmount ?? 0);
    final bool isProFullFreeDelivery = isPro && proBenefit?.type == ProBenefitType.deliveryFee
        && (proBenefit?.offerType == ProOfferType.fullFree || (proBenefit?.chargeDiscountPercentage ?? 0) >= 100)
        && meetsProMinOrder;

    bool canShow = checkoutController.orderType == 'delivery'
        && !checkoutController.subscriptionOrder
        && !isProFullFreeDelivery
        && saverZoneData != null
        && saverZoneData.deliveryOptions != null
        && saverZoneData.status == 1
        && saverZoneData.additionalDeliveryOptionStatus!
        && (hasCurrentEligibleDeliveryCharge || disableSaverOptions);

    if(disableSaverOptions && checkoutController.saverDeliveryType != 'standard') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(checkoutController.saverDeliveryType != 'standard') {
          checkoutController.setSaverDeliveryType('standard');
        }
      });
    }

    return canShow ? Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Divider(),

        AbsorbPointer(
          absorbing: disableSaverOptions,
          child: Opacity(
            opacity: disableSaverOptions ? 0.55 : 1,
            child: RadioGroup<String>(
              groupValue: checkoutController.saverDeliveryType,
              onChanged: (String? value) {
                if(value != null && !disableSaverOptions) {
                  checkoutController.setSaverDeliveryType(value);
                }
              },
              child: ResponsiveHelper.isDesktop(context) ? SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                    itemCount: checkoutController.saverZoneData!.deliveryOptions!.length,
                    itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    child: SizedBox(
                      width: 270,
                      child: saverCard(context, index),
                    ),
                  );
                }),
              ) : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: checkoutController.saverZoneData!.deliveryOptions!.length,
                  itemBuilder: (context, index) {

                return saverCard(context, index);
              }),
            ),
          ),
        ),
        if(disableSaverOptions) ...[
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 18,),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Expanded(
                child: Text(
                  'free_delivery_applies_to_this_order_amount_so_delivery_type_charge_options_are_disabled'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ) : const SizedBox();
  }

  Widget saverCard(BuildContext context, int index) {
    DeliveryOptions deliveryOption = checkoutController.saverZoneData!.deliveryOptions![index];
    final bool isFreeDeliveryCouponApplied = Get.find<CouponController>().freeDelivery;
    bool select = checkoutController.saverDeliveryType == deliveryOption.deliveryType;
    String storeDeliveryTime = _finalizeDeliveryTime(checkoutController.restaurant?.deliveryTime??'', deliveryOption);
    double totalDeliveryCharge = checkoutController.getSaverDeliveryChargeAdjustment(
      deliveryOption: deliveryOption,
    ) + (isFreeDeliveryCouponApplied ? originalDeliveryCharge : deliveryCharge);
    totalDeliveryCharge = totalDeliveryCharge < 0 ? 0 : totalDeliveryCharge;
    String deliveryChargeText = PriceConverter.convertPrice(totalDeliveryCharge);

    return InkWell(
      onTap: deliveryOption.deliveryType == null ? null : () {
        checkoutController.setSaverDeliveryType(deliveryOption.deliveryType!);
      },
      child: Container(
        decoration: BoxDecoration(
          color: select ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: select ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: deliveryOption.deliveryType ?? '',
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: Theme.of(context).primaryColor,
              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            Expanded(
              child: ResponsiveHelper.isDesktop(context) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${deliveryOption.deliveryType?.replaceAll('_', ' ').capitalize} ${'delivery'.tr}', maxLines: 1, style: select ? robotoMedium : robotoRegular),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                FittedBox(
                  child: Text(
                    storeDeliveryTime,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium!.color),
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  '${'charge'.tr}: $deliveryChargeText',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                ),
              ]) : Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(children: [
                        Text('${deliveryOption.deliveryType?.replaceAll('_', ' ').capitalize} ${'delivery'.tr}', style: select ? robotoMedium : robotoRegular),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text(
                          storeDeliveryTime,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium!.color),
                        ),
                      ]),
                      const SizedBox(height: 2),
                      Text(
                        '${'charge'.tr}: $deliveryChargeText',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            SizedBox(width: Dimensions.paddingSizeSmall,),

            if(deliveryOption.extraCharge != null || deliveryOption.reduceCharge != null)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                ),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                child: Text(
                  deliveryOption.extraCharge != null ? '+ ${PriceConverter.convertPrice(deliveryOption.extraCharge)}'
                      : deliveryOption.reduceCharge != null ? '- ${PriceConverter.convertPrice(deliveryOption.reduceCharge)}'
                      : '',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _finalizeDeliveryTime(String storeDeliveryTime, DeliveryOptions deliveryOption) {
    String time = '';
    if(storeDeliveryTime.isNotEmpty) {
      int minTime = 0;
      int maxTime = 0;
      try {
        List<String> timeList = storeDeliveryTime.split('-'); // ['15', '20']
        minTime = int.parse(timeList[0]);
        maxTime = int.parse(timeList[1]);
        String timeUnit = timeList[2];

        minTime = _convertToMinutes(minTime, timeUnit);
        maxTime = _convertToMinutes(maxTime, timeUnit);

        int saverMinTime = checkoutController.saverZoneData!.minimumDeliveryTime?.value ?? 0;
        String saverMinTimeType = checkoutController.saverZoneData!.minimumDeliveryTime?.unit ?? 'min';
        saverMinTime = _convertToMinutes(saverMinTime, saverMinTimeType);

        if(minTime > saverMinTime) {
          minTime = saverMinTime;
        }

        if(maxTime < saverMinTime) {
          maxTime = saverMinTime;
        }

        if(deliveryOption.deliveryType == 'standard') {
          time = _formatDeliveryTime(minTime, maxTime);
        } else if(deliveryOption.deliveryType == 'express') {
          int reduceTime = deliveryOption.reduceDeliveryTime?.value??0;
          String reduceTimeType = deliveryOption.reduceDeliveryTime?.unit??timeUnit;
          reduceTime = _convertToMinutes(reduceTime, reduceTimeType);
          time = _formatDeliveryTime(minTime, (maxTime - reduceTime).clamp(minTime, 9999999));
        } else if(deliveryOption.deliveryType == 'slightly_delay') {
          int addTime = deliveryOption.addDeliveryTime?.value??0;
          String addTimeType = deliveryOption.addDeliveryTime?.unit??timeUnit;
          addTime = _convertToMinutes(addTime, addTimeType);
          time = _formatDeliveryTime(minTime, maxTime + addTime);
        }
      }catch(_) {}

    }

    return time;

  }

  int _convertToMinutes(int value, String? unit) {
    final String normalizedUnit = unit?.toLowerCase() ?? 'min';
    return normalizedUnit.contains('hour') ? value * 60 : value;
  }

  String _formatDeliveryTime(int minTime, int maxTime,) { // as minute

    String left = getSlidTime(minTime);
    String right = getSlidTime(maxTime);

    bool isLeftContainMin = left.contains('min');
    bool isRightContainMin = right.contains('min');
    bool isLeftContainHour = left.contains('hr');
    bool isRightContainHour = right.contains('hr');

    // if both contain only min
    if(isLeftContainMin && isRightContainMin && !isLeftContainHour && !isRightContainHour){
      left = left.replaceAll(' min', '');
      right = right.replaceAll(' min', '');
      if(left == right) {
        return '(${'upto'.tr} $left min)';
      }
      return '($left - $right) min';
    }
    // if both contain only hour
    if(!isLeftContainMin && !isRightContainMin && isLeftContainHour && isRightContainHour){
      left = left.replaceAll(' hr', '');
      right =  right.replaceAll(' hr', '');
      if(left == right) {
        return '(${'upto'.tr} $left hr)';
      }
      return '($left - $right) hr';
    }
    if(left == right) {
      return '(${'upto'.tr} $left)';
    }
    return '($left - $right)';
  }

  String getSlidTime(int value){
    if(value >=60){
      int h = value ~/ 60;
      int m = value % 60;
      if(m == 0){
        return '$h hr';
      }
      return '$h hr $m min';
    }
    return '$value min';
  }

}

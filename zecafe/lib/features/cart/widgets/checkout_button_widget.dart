import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/auth_dialog_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/features/pro/screens/subscription_plan_screen.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/pro_plan_banner_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutButtonWidget extends StatelessWidget {
  final CartController cartController;
  final List<bool> availableList;
  final bool isRestaurantOpen;
  final bool fromDineIn;
  final int restaurantId;
  const CheckoutButtonWidget({super.key, required this.cartController, required this.availableList, required this.isRestaurantOpen, this.fromDineIn = false, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    double percentage = 0;
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: Dimensions.webMaxWidth,
      padding:  const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
      decoration: isDesktop ? null : BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: SafeArea(
        child: GetBuilder<RestaurantController>(builder: (restaurantController) {
          if(restaurantController.restaurant != null && restaurantController.restaurant!.freeDelivery != null && !restaurantController.restaurant!.freeDelivery!
           && (Get.find<SplashController>().configModel?.adminFreeDelivery?.status == true && (Get.find<SplashController>().configModel?.adminFreeDelivery?.type != null && Get.find<SplashController>().configModel?.adminFreeDelivery?.type == 'free_delivery_by_specific_criteria') && (Get.find<SplashController>().configModel!.adminFreeDelivery?.freeDeliveryOver != null))){
            percentage = cartController.subTotal/Get.find<SplashController>().configModel!.adminFreeDelivery!.freeDeliveryOver!;
          }
          return Column(mainAxisSize: MainAxisSize.min, children: [
            // pro member how much save card (only when the pro feature is enabled in config)
            if(Get.find<SplashController>().proStaus) ...[
              GetBuilder<ProfileController>(builder: (_){
                return GetBuilder<ProController>(builder: (_){
                  return _proMemerDiscountWidget(Get.find<ProfileController>().isPro, context);
                });
              }),
              SizedBox(height: Dimensions.paddingSizeSmall,),
            ],

            (restaurantController.restaurant != null && restaurantController.restaurant!.freeDelivery != null && !restaurantController.restaurant!.freeDelivery!
             && (Get.find<SplashController>().configModel?.adminFreeDelivery?.status == true && (Get.find<SplashController>().configModel?.adminFreeDelivery?.type != null && Get.find<SplashController>().configModel?.adminFreeDelivery?.type == 'free_delivery_by_specific_criteria') && (Get.find<SplashController>().configModel!.adminFreeDelivery?.freeDeliveryOver != null)) && percentage < 1)
            ? Padding(
              padding: EdgeInsets.only(bottom: isDesktop ? Dimensions.paddingSizeLarge : 0),
              child: Column(children: [
                Row(children: [
                  Image.asset(Images.percentTag, height: 20, width: 20),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  PriceConverter.convertAnimationPrice(
                    Get.find<SplashController>().configModel!.adminFreeDelivery!.freeDeliveryOver! - cartController.subTotal,
                    textStyle: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text('more_for_free_delivery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                LinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  value: percentage,
                ),
              ]),
            ) : const SizedBox(),


            !isDesktop ? Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('subtotal'.tr, style: robotoSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  PriceConverter.convertAnimationPrice(cartController.subTotal, textStyle: robotoSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                ],
              ),
            ) : const SizedBox(),

            GetBuilder<CartController>(builder: (cartController) {
              return CustomButtonWidget(
                radius: 10,
                buttonText: 'confirm_delivery_details'.tr,
                onPressed: cartController.isLoading || restaurantController.restaurant == null ? null : () {
                  Get.find<CheckoutController>().updateFirstTime();
                  _processToCheckoutButtonPressed(restaurantController);
                },
              );
            }),
            SizedBox(height: isDesktop ? Dimensions.paddingSizeExtraLarge : 0),
          ]);
        }),
      ),
    );
  }

  void _processToCheckoutButtonPressed(RestaurantController restaurantController) {
    if(!cartController.cartList(restaurantId).first.product!.scheduleOrder! && cartController.availableList.contains(false)) {
      showCustomSnackBar('one_or_more_product_unavailable'.tr);
    } else if(restaurantController.restaurant!.freeDelivery == null || restaurantController.restaurant!.cutlery == null) {
      showCustomSnackBar('restaurant_is_unavailable'.tr);
    }else {
      Get.find<CouponController>().removeCouponData(false);
      Get.toNamed(RouteHelper.getCheckoutRoute('cart', fromDineIn: fromDineIn, restaurantId: cartController.cartList(restaurantId).first.product!.restaurantId));
    }
  }

  Widget _proMemerDiscountWidget(bool isPro, BuildContext context) {
    if (!isPro) {
      return PromoBanner(
        onSubscribe: () {
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
        }
      );
    }

    return GetBuilder<ProController>(builder: (proController) {
      final benefit = proController.activeOfferModel?.benefit;
      if (benefit == null || benefit.type == null) return const SizedBox();
      return GetBuilder<CartController>(builder: (cc) {
        return _buildProBenefitBanner(benefit, cc.subTotal);
      });
    });
  }

  Widget _buildProBenefitBanner(ProActiveBenefit benefit, double subtotal) {
    final textStyle = robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall);
    final boldStyle = robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall);
    final gap = const SizedBox(width: Dimensions.paddingSizeExtraSmall);

    Widget content;

    if (benefit.type == ProBenefitType.coupon) {
      content = Text(
        'You have a coupon as a pro member',
        style: textStyle, maxLines: 2, overflow: TextOverflow.ellipsis,
      );

    } else if (benefit.type == ProBenefitType.discount) {
      final meetsMinOrder = benefit.minOrderStatus != true || subtotal >= (benefit.minOrderAmount ?? 0);
      if (!meetsMinOrder) {
        final remaining = (benefit.minOrderAmount ?? 0) - subtotal;
        content = Row(
          children: [
            PriceConverter.convertAnimationPrice(remaining, textStyle: boldStyle),
            gap,
            Flexible(
              child: Text(
                'more to unlock pro discount',
                style: textStyle, maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      } else {
        double discount = subtotal * ((benefit.percentage ?? 0) / 100);
        if (benefit.maxAmount != null && discount > benefit.maxAmount!) {
          discount = benefit.maxAmount!;
        }
        if (discount > subtotal) discount = subtotal;
        content = Row(
          children: [
            Text('You save', style: textStyle),
            gap,
            PriceConverter.convertAnimationPrice(discount, textStyle: boldStyle),
            gap,
            Flexible(
              child: Text(
                'as a pro member',
                style: textStyle, maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }

    } else if (benefit.type == ProBenefitType.deliveryFee) {
      if (benefit.offerType == ProOfferType.fullFree) {
        final minOrderText = (benefit.minOrderStatus ?? false)
            ? ', minimum order amount ${PriceConverter.convertPrice(benefit.minOrderAmount)}'
            : '';
        content = Text(
          'You get free delivery as a pro member$minOrderText',
          style: textStyle, maxLines: 2, overflow: TextOverflow.ellipsis,
        );
      } else {
        content = Text(
          'You get ${(benefit.chargeDiscountPercentage ?? 0).toStringAsFixed(0)}% off on delivery charge as a pro member',
          style: textStyle, maxLines: 2, overflow: TextOverflow.ellipsis,
        );
      }

    } else {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: const Color(0xFFB57BEE),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('\u{1F451}', style: TextStyle(fontSize: 12)),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class PromoBanner extends StatelessWidget {
  final VoidCallback? onSubscribe;

  const PromoBanner({super.key, this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB06FE8), Color(0xFF9B4FD8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Crown icon circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '👑',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Text
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'Enjoy extra savings on every order with a '),
                  TextSpan(
                    text: 'Pro Plan',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Subscribe Now button
          UnderlinedTextButton(label: 'Subscribe Now', color: Colors.white, onTap: onSubscribe, fontSize: Dimensions.fontSizeSmall,)
        ],
      ),
    );
  }
}


class UnderlinedTextButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const UnderlinedTextButton({
    super.key,
    required this.label,
    this.onTap,
    this.color = const Color(0xFF9B4FD8),
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
  });

  @override
  State<UnderlinedTextButton> createState() => _UnderlinedTextButtonState();
}

class _UnderlinedTextButtonState extends State<UnderlinedTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _isHovered ? 0.7 : 1.0,
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.color,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              decoration: TextDecoration.underline,
              decorationColor: widget.color,
              decorationThickness: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ProPlanBannerWidget extends StatelessWidget {
  final VoidCallback? onSubscribe;
  const ProPlanBannerWidget({super.key, this.onSubscribe,});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GetBuilder<ProController>(
      builder: (proController) {
      final bool hasProPlan = Get.find<ProfileController>().isPro;
      final activeOfferModel = proController.activeOfferModel;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A1F4A) : const Color(0xFFEFEAFB),
            image: isDark ? null : DecorationImage(image: AssetImage(Images.proBanner)),
            borderRadius: ResponsiveHelper.isDesktop(context) ? BorderRadius.circular(Dimensions.radiusDefault) : null
          ),
          child: Stack(children: [

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(children: [

                Container(
                  height: 32, width: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFC107),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(Images.proPlanCrown, fit: BoxFit.contain),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: hasProPlan
                          ? '${'order_now_to_enjoy_exclusive_offer_with_your'.tr} '
                          : '${'enjoy_extra_savings_on_every_order_with_a'.tr} ',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      children: [
                        TextSpan(
                          text: 'pro_plan'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                        if(hasProPlan && activeOfferModel?.benefit?.type != null)
                          TextSpan(
                            text: ' - ${_getBenefitDisplayName()} ${'benefit_unlocked'.tr}',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                !hasProPlan ? Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  child: InkWell(
                    onTap: onSubscribe,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B4DFF),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Text(
                        'subscribe_now'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ) : const SizedBox(),

              ]),
            ),

          ]),
        );
      }
    );
  }

  String _getBenefitDisplayName() {
    final benefitType = Get.find<ProController>().activeOfferModel?.benefit?.type;
    if (benefitType == ProBenefitType.discount) {
      return 'pro_discount'.tr;
    } else if (benefitType == ProBenefitType.deliveryFee) {
      return 'pro_delivery_fee'.tr;
    } else if (benefitType == ProBenefitType.coupon) {
      return 'pro_coupon'.tr;
    }
    return 'pro_benefit'.tr;
  }
}

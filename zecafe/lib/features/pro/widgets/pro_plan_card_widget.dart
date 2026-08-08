import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_plan_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ProPlanCardWidget extends StatelessWidget {
  final ProPlanModel? model;
  const ProPlanCardWidget({super.key, required this.model,});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> benefitItems = _buildBenefitItems(model?.benefits);
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffDFDFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(100),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular( Dimensions.radiusExtraLarge), top: Radius.circular(Dimensions.radiusLarge)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                      child: Image.asset(Images.proPlanCrown, width: 24, height: 24, color: Theme.of(context).cardColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      model?.proBrand ?? 'stackfood_pro'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      'save_more_on_every_order'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],
                ),
              ),

              if (benefitItems.isNotEmpty) Padding(
                padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    ...benefitItems.map((item) => _buildBenefitsRow(context, item['title']!, item['subtitle']!)),
                  ],
                ),
              )
            ],
          ),
        )

      ],
    );

    return column;
  }

  Widget _buildBenefitsRow(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white , shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Color(0xFF4CAF50), size: 12,),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black)),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _buildBenefitItems(PlanBenefits? benefits) {
    final List<Map<String, String>> items = [];
    if (benefits == null) return items;
    if (benefits.discount?.active == 1) {
      final double pct = benefits.discount?.percentage ?? 0;
      final double max = benefits.discount?.maxAmount ?? 0;
      items.add({
        'title': '${'discount_on_all_orders'.tr} (${pct.toStringAsFixed(0)}%)',
        'subtitle': '${'get_up_to'.tr} ${PriceConverter.convertPrice(max)} ${'discount'.tr}',
      });
    }
    if (benefits.deliveryFee?.active == 1) {
      items.add({'title': 'free_delivery'.tr, 'subtitle': 'enjoy_unlimited_free_deliveries'.tr});
    }
    if (benefits.coupon?.active == true) {
      items.add({'title': 'exclusive_coupon_on_order'.tr, 'subtitle': 'unlock_exclusive_coupon_deals'.tr});
    }
    return items;
  }
}

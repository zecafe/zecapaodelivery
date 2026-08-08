import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_plan_model.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_payment_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ProSubscriptionActionsWidget extends StatelessWidget {
  final List<PlanItem>? plans;
  final VoidCallback? onRenew;
  const ProSubscriptionActionsWidget({super.key, this.plans, this.onRenew});

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = Color(0xffA16BFF);
    final bool hasPlans = plans != null && plans!.isNotEmpty;

    return GetBuilder<ProController>(builder: (proController) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: proController.isCancelLoading ? null : () => _onCancelPressed(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                elevation: 0,
              ),
              child: proController.isCancelLoading
                  ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).hintColor))
                  : Text('cancel_subscription'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: ElevatedButton(
              onPressed: hasPlans ? () => _onRenewPressed(context) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                backgroundColor: hasPlans ? buttonColor : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                elevation: 0,
              ),
              child: Text(
                'renew_subscription'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: hasPlans ? Theme.of(context).cardColor : Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _onCancelPressed(BuildContext context) {
    Get.dialog(ConfirmationDialogWidget(
      icon: Images.warning,
      title: 'cancel_subscription'.tr,
      description: 'are_you_sure_to_cancel_subscription'.tr,
      onYesPressed: () {
        Get.back();
        Get.find<ProController>().cancelSubscription();
      },
    ), barrierDismissible: false);
  }

  void _onRenewPressed(BuildContext context) {
    if (onRenew != null) {
      print("------------>");

      onRenew!();
    } else {
      final int? planId = Get.find<ProController>().activeOfferModel?.benefit?.planId;
      final PlanItem? plan = Get.find<ProController>().planModel?.plans?.firstWhereOrNull((p) => p.id == planId && p.status == true);
      if (plan == null) {
        showCustomSnackBar('no_data_found'.tr);
        return;
      }
      _onSubscribePressed(context, plan, true);
    }
  }

  void _onSubscribePressed(BuildContext context, PlanItem plan, bool isRenew) {
    if ((plan.price ?? 0) <= 0) {
      Get.find<ProController>().subscribePlan(plan, 'free_trial', 'free_trial', isRenew);
      return;
    }
    if (ResponsiveHelper.isDesktop(context)) {
      Get.dialog(Dialog(backgroundColor: Colors.transparent, child: ProPaymentBottomSheetWidget(plan: plan, isRenew:  isRenew)));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ProPaymentBottomSheetWidget(plan: plan, isRenew: isRenew,),
      );
    }
  }
}

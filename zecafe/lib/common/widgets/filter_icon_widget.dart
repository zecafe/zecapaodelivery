import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class FilterIconWidget extends StatelessWidget {
  final bool fromAppBar;
  final Color? iconColor;
  const FilterIconWidget({super.key, required this.fromAppBar, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: fromAppBar ? BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).primaryColor, width: 1.2),
      ) : BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(color: iconColor ?? Theme.of(context).textTheme.bodyMedium!.color!, width: 0.5),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      child: Icon(Icons.tune_sharp, size: fromAppBar ? 18 : 24, color: iconColor ?? Theme.of(context).textTheme.bodyMedium!.color),
    );
  }
}

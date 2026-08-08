import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';

class CustomCheckBoxWidget extends StatelessWidget {
  final String title;
  final bool value;
  final Function onClick;
  final bool isRadioButton;
  final List<String>? ratingList;
  final bool checkBoxAlignRight;
  const CustomCheckBoxWidget({super.key, required this.title, required this.value, required this.onClick, this.isRadioButton = false, this.ratingList, this.checkBoxAlignRight = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: InkWell(
        onTap: onClick as void Function()?,
        child: Row(children: [
          if(!checkBoxAlignRight) Row(
            children: [
              SizedBox(
                height: 24, width: 24,
                child: Checkbox(
                  value: value,
                  onChanged: (bool? isActive) => onClick(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(color: Theme.of(context).hintColor),
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(
                width: Dimensions.paddingSizeDefault,
              )
            ],
          ),

          Text(title, style: robotoRegular. copyWith(fontSize: Dimensions.fontSizeSmall)),
          Spacer(),

          if(checkBoxAlignRight) isRadioButton ? Container(
            height: 20, width: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
              border: Border.all(color: value ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 2),
            ),
            padding: EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
              ),
            ),
          ) : SizedBox(
            height: 24, width: 24,
            child: Checkbox(
              value: value,
              onChanged: (bool? isActive) => onClick(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: Theme.of(context).hintColor),
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
        ]),
      ),
    );
  }
}

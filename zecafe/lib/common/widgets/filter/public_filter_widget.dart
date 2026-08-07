import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/filter/controller/public_filter_controller.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_additional_data_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/search/widgets/custom_check_box_widget.dart';
import 'package:stackfood_multivendor/features/search/widgets/filter_section_wrapper.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class PublicFilterWidget extends StatefulWidget {
  final bool isRestaurant;
  final FilterAdditionalDataModel? filterAdditionalDataModel;
  final FilterDataModel? filterDataModel;
  const PublicFilterWidget({super.key, required this.isRestaurant, this.filterAdditionalDataModel, this.filterDataModel});

  @override
  State<PublicFilterWidget> createState() => _PublicFilterWidgetState();
}

class _PublicFilterWidgetState extends State<PublicFilterWidget> {
  bool showAllCuisine = false;
  List<String> ratings = ['5_rating', '4_rating', '3_rating', '2_rating', '1_rating'];
  @override
  void initState() {
    super.initState();

    PublicFilterController? publicFilterController;
    publicFilterController = Get.find<PublicFilterController>();


    if(Get.find<CuisineController>().cuisineModel?.cuisines?.isEmpty ?? true) {
      Get.find<CuisineController>().getCuisineList();
    }

    publicFilterController.setSearchMode(filterDataModel: widget.filterDataModel, canUpdate: false);
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      constraints: BoxConstraints(maxHeight: context.height*0.85, minHeight: context.height*0.6),
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), blurRadius: 10)]
      ) : BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
      ) ,
      child: GetBuilder<PublicFilterController>(builder: (publicFilterController) {
        List<String> sortListData = widget.isRestaurant ? publicFilterController.restaurantSortList : publicFilterController.sortList;

        return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          // title bar
          if(!ResponsiveHelper.isDesktop(context)) Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width : 30 + (Dimensions.paddingSizeDefault * 2),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                    child: Text('filter_data'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle
                  ),
                  child: CustomInkWellWidget(
                    onTap: ()=> Get.back(),
                    child: const Center(child: Icon(Icons.close)),
                  ),
                )
              ],
            ),

            Divider(
              color: Theme.of(context).scaffoldBackgroundColor,
              thickness: 1,
              height: 3,
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]),

          Flexible(
            child: SingleChildScrollView(
              // padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

                // sorting
                SectionWrapper(
                  title: 'sorting'.tr,
                  child:  Wrap(
                    runSpacing: Dimensions.paddingSizeSmall,
                    children: sortListData.map((sort) {
                      int index = sortListData.indexOf(sort);
                      bool isSelected = widget.isRestaurant ? (index == publicFilterController.restaurantSortIndex) : (index == publicFilterController.sortIndex);
                      return CustomCheckBoxWidget( title: sort, value: isSelected, isRadioButton: true,
                        onClick: () {
                          if(widget.isRestaurant) {
                            publicFilterController.setRestSortIndex(index);
                          } else {
                            publicFilterController.setSortIndex(index);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),

                // price
                if(!widget.isRestaurant) SectionWrapper(
                  title: '${'price'.tr} ${'(${PriceConverter.convertPrice(publicFilterController.lowerValue)} - ${PriceConverter.convertPrice(publicFilterController.upperValue)})'}'.tr,
                  child: RangeSlider(
                    values: RangeValues(
                      publicFilterController.lowerValue.clamp(publicFilterController.lowerLimit, publicFilterController.upperLimit),
                      publicFilterController.upperValue.clamp(publicFilterController.lowerLimit, publicFilterController.upperLimit),
                    ),
                    max: publicFilterController.upperLimit,
                    min: publicFilterController.lowerLimit,
                    divisions: ((publicFilterController.upperLimit) + 100).toInt(),
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                    labels: RangeLabels(publicFilterController.lowerValue.toInt().toString(), publicFilterController.upperValue.toInt().toString()),
                    onChanged: (RangeValues rangeValues) {
                      publicFilterController.setLowerAndUpperValue(rangeValues.start.floor().toDouble(), rangeValues.end.ceil().toDouble());
                    },

                  ),
                ),

                // food type
                SectionWrapper(
                  title: 'food_type'.tr,
                  child: Row(
                    children: [
                      Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Expanded(
                        child: CustomCheckBoxWidget(
                          checkBoxAlignRight: false,
                          title: 'veg'.tr,
                          value: widget.isRestaurant ? publicFilterController.restaurantVeg : publicFilterController.productVeg,
                          onClick: () {
                            if(widget.isRestaurant) {
                              publicFilterController.toggleResVeg();
                            } else {
                              publicFilterController.toggleVeg();
                            }
                          },
                        ),
                      ) : const SizedBox(),

                      Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Expanded(
                        child: CustomCheckBoxWidget(
                          checkBoxAlignRight: false,
                          title: 'non_veg'.tr,
                          value: widget.isRestaurant ? publicFilterController.restaurantNonVeg : publicFilterController.productNonVeg,
                          onClick: () {
                            if(widget.isRestaurant) {
                              publicFilterController.toggleResNonVeg();
                            } else {
                              publicFilterController.toggleNonVeg();
                            }
                          },
                        ),
                      ) : const SizedBox(),
                    ],
                  ),
                ),

                // order type
                SectionWrapper(
                  title: 'order_type'.tr,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: publicFilterController.getOrderTypeList.length,
                      itemBuilder: (context, index){
                        return CustomCheckBoxWidget(
                          title: publicFilterController.getOrderTypeList[index],
                          value: widget.isRestaurant ? publicFilterController.getSelectedOrderTypeRest.contains(index) : publicFilterController.getSelectedOrderType.contains(index),
                          onClick: () {
                            widget.isRestaurant ? publicFilterController.setSelectedOrderTypeRest(index): publicFilterController.setSelectedOrderType(index);
                          },
                        );
                      }
                  ),
                ),

                // rating
                SectionWrapper(
                  title: 'rating'.tr,
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: ratings.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      bool isSelected = false;
                      if(widget.isRestaurant) {
                        isSelected = publicFilterController.restaurantRating == (5 - index);
                      } else {
                        isSelected = publicFilterController.rating == (5 - index);
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: CustomCheckBoxWidget(
                          title: ratings[index].tr,
                          value: isSelected,
                          isRadioButton: true,
                          ratingList: ratings,
                          onClick: () {
                            if(widget.isRestaurant) {
                              publicFilterController.setRestaurantRating(5 - index);
                            } else {
                              publicFilterController.setRating(5 - index);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // filter by
                SectionWrapper(
                  title: 'filter_by'.tr,
                  child: Column(
                    children: [

                      CustomCheckBoxWidget(
                        title: 'free_delivery'.tr,
                        value: widget.isRestaurant ? publicFilterController.isFreeDeliveryRestaurant : publicFilterController.isFreeDelivery,
                        onClick: () {
                          if(widget.isRestaurant){
                            publicFilterController.toggleFreeDeliveryRestaurant();
                          }
                          else{
                            publicFilterController.toggleFreeDeliveryProduct();
                          }
                        },
                      ),

                      if(!widget.isRestaurant)CustomCheckBoxWidget(
                        title: 'currently_available_foods'.tr,
                        value: publicFilterController.isAvailableFoods,
                        onClick: () {
                          publicFilterController.toggleAvailableFoods();
                        },
                      ),

                      widget.isRestaurant ? CustomCheckBoxWidget(
                        title: 'open_restaurants'.tr,
                        value: publicFilterController.isOpenRestaurant,
                        onClick: () {
                          publicFilterController.toggleOpenRestaurant();
                        },
                      ) : const SizedBox(),

                      CustomCheckBoxWidget(
                        title: 'new_arrivals'.tr,
                        value: widget.isRestaurant ? publicFilterController.isNewArrivalsRestaurant : publicFilterController.isNewArrivalsFoods,
                        onClick: () {
                          if(widget.isRestaurant) {
                            publicFilterController.toggleNewArrivalRestaurant();
                          } else {
                            publicFilterController.toggleNewArrivalFoods();
                          }
                        },
                      ),

                      CustomCheckBoxWidget(
                        title: 'discounted'.tr,
                        value: widget.isRestaurant ? publicFilterController.isDiscountedRestaurant : publicFilterController.isDiscountedFoods,
                        onClick: () {
                          if(widget.isRestaurant) {
                            publicFilterController.toggleDiscountedRestaurant();
                          } else {
                            publicFilterController.toggleDiscountedFoods();
                          }
                        },
                      ),

                      if(widget.filterAdditionalDataModel?.fromPopularRestaurant != true)
                      CustomCheckBoxWidget(
                        title: 'popular'.tr,
                        value: widget.isRestaurant ? publicFilterController.isPopularRestaurant : publicFilterController.isPopularFood,
                        onClick: () {
                          if(widget.isRestaurant) {
                            publicFilterController.togglePopularRestaurant();
                          } else {
                            publicFilterController.togglePopularFoods();
                          }
                        },
                      ),

                    ],
                  ),
                ),

                // cuisines
                if(widget.filterAdditionalDataModel?.showCuisines != false && widget.isRestaurant)
                GetBuilder<CuisineController>(
                    builder: (cuisineController) {
                      const int snapCount = 3;
                      return cuisineController.cuisineModel != null && cuisineController.cuisineModel!.cuisines!.isNotEmpty ?
                      SectionWrapper(
                        title: '${'cuisines'.tr} ',
                        child:  ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: showAllCuisine ? cuisineController.cuisineModel!.cuisines!.length
                              : cuisineController.cuisineModel!.cuisines!.length > (snapCount+1) ? (snapCount+1) : cuisineController.cuisineModel!.cuisines!.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            bool isSelected = widget.isRestaurant ? publicFilterController.selectedCuisinesRestaurant.contains(cuisineController.cuisineModel!.cuisines![index].id!) : publicFilterController.selectedCuisinesProduct.contains(cuisineController.cuisineModel!.cuisines![index].id!);;
                            if(!showAllCuisine && index == snapCount && cuisineController.cuisineModel!.cuisines!.length > (snapCount+1)) {
                              return InkWell(
                                onTap: (){
                                  setState(() {
                                    showAllCuisine = !showAllCuisine;
                                  });
                                },
                                child: Center(child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${'see_more'.tr} (${cuisineController.cuisineModel!.cuisines!.length - snapCount})", style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.tertiary)),
                                  ],
                                )),
                              );
                            } else {
                              return CustomCheckBoxWidget(
                                title: cuisineController.cuisineModel!.cuisines![index].name ?? '',
                                value: isSelected,
                                onClick: () => widget.isRestaurant ? publicFilterController.selectCuisineRestaurant(cuisineController.cuisineModel!.cuisines![index].id!) : publicFilterController.selectCuisineProduct(cuisineController.cuisineModel!.cuisines![index].id!),
                              );
                            }
                          },
                        ),
                      ) :
                      const SizedBox();
                    }
                ),

              ]),
            ),
          ),
          const SizedBox(height: 30),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: ResponsiveHelper.isDesktop(context) ? BorderRadius.only(bottomLeft: Radius.circular(Dimensions.radiusDefault), bottomRight: Radius.circular(Dimensions.radiusDefault)) : null,
              boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), offset: Offset(0, -3), blurRadius: 10)],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
            child: SafeArea(
              child: Row(children: [
                Expanded(
                  child: CustomButtonWidget(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                    textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () {
                      publicFilterController.resetRestaurantFilter();
                      publicFilterController.resetFilter();

                      Get.back();
                      widget.filterAdditionalDataModel?.callback?.call(publicFilterController.getFilterDataModel());
                    },
                    buttonText: 'clear_filter'.tr,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'filter'.tr,
                    onPressed: () async {
                      Get.back();
                      widget.filterAdditionalDataModel?.callback?.call(publicFilterController.getFilterDataModel());
                    },
                  ),
                ),
              ],
              ),
            ),
          ),
        ]);
      }),
    );
  }
}

void showFilterBottomSheetOrDialog(BuildContext context, bool isRestaurant, {double? maxValue, double? minValue, FilterAdditionalDataModel? filterAdditionalDataModel, FilterDataModel? filterDataModel}) {

  ResponsiveHelper.isMobile(context) ? Get.bottomSheet(PublicFilterWidget(
    isRestaurant: isRestaurant,
    filterAdditionalDataModel: filterAdditionalDataModel,
    filterDataModel: filterDataModel,
  ),
    isScrollControlled: true,
  ) : _showSearchDialog(context, maxValue, minValue, isRestaurant, filterDataModel);

}


Future<void> _showSearchDialog(BuildContext context, double? maxValue, double? minValue, bool isRestaurant, FilterDataModel? filterDataModel) async {
  // RenderBox renderBox = _searchBarKey.currentContext!.findRenderObject() as RenderBox;
  // final searchBarPosition = renderBox.localToGlobal(Offset.zero);

  await showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) => Stack(children: [
      Positioned(
        // top: searchBarPosition.dy + 40,
        // left: searchBarPosition.dx - 400,
        // width: renderBox.size.width + 400,
        // height: renderBox.size.height + MediaQuery.of(context).size.height * 0.6,
        child: Material(
          color: Theme.of(context).cardColor,
          elevation: 0,
          borderRadius: BorderRadius.circular(30),
          child: PublicFilterWidget(isRestaurant: isRestaurant, filterDataModel: filterDataModel,),
        ),
      ),

    ]),
  );
}

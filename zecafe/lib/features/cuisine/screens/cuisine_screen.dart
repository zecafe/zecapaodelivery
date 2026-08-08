import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/features/home/widgets/cuisine_card_widget.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CuisineScreen extends StatefulWidget {
  const CuisineScreen({super.key});

  @override
  State<CuisineScreen> createState() => _CuisineScreenState();
}

class _CuisineScreenState extends State<CuisineScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<CuisineController>().getCuisineList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    scrollController.dispose();
    Get.find<CuisineController>().getCuisineList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'cuisine'.tr),
      backgroundColor: Theme.of(context).colorScheme.surface,
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(children: [

          SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0: Dimensions.paddingSizeLarge),
          WebScreenTitleWidget(title: 'cuisine'.tr),

          Center(child: FooterViewWidget(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(children: [
                RefreshIndicator(
                  onRefresh: () async {
                    // await Get.find<CuisineController>().getCuisineList();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault, right: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault),
                    child: GetBuilder<CuisineController>(builder: (cuisineController) {
                      return Column(
                        children: [

                          ResponsiveHelper.isDesktop(context) ? SizedBox() : SizedBox(
                            height: 47,
                            child: SearchBar(
                              controller: _searchController,
                              backgroundColor: WidgetStatePropertyAll(Theme.of(context).cardColor),
                              elevation: WidgetStatePropertyAll(0),
                              side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.15))),
                              onChanged: (value) {
                                cuisineController.getCuisineList(search: value);
                              },
                              onSubmitted: (value) {
                                cuisineController.getCuisineList(search: value);
                              },
                              hintText: 'search_by_category'.tr,
                              hintStyle: WidgetStatePropertyAll(
                                robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                              ),
                              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0)),
                              leading: Icon(CupertinoIcons.search, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
                              trailing: _searchController.text.isEmpty ? [const SizedBox()] : _searchController.text.isNotEmpty ? [InkWell(
                                child: Icon(Icons.clear, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
                                onTap: () {
                                  _searchController.clear();
                                  cuisineController.getCuisineList(search: null);
                                  cuisineController.update();
                                },
                              )] : [const SizedBox()],
                            ),
                          ),
                          SizedBox(height: Dimensions.paddingSizeDefault,),


                          cuisineController.cuisineModel != null ? GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveHelper.isMobile(context) ? 4 : ResponsiveHelper.isDesktop(context) ? 8 : 6,
                              mainAxisSpacing: Dimensions.paddingSizeDefault,
                              crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 35 : Dimensions.paddingSizeDefault,
                              childAspectRatio: 1,
                            ),
                            shrinkWrap: true,
                            itemCount: cuisineController.cuisineModel!.cuisines!.length,
                            scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              return InkWell(
                                hoverColor: Colors.transparent,
                                onTap: (){
                                  Get.toNamed(RouteHelper.getCuisineRestaurantRoute(cuisineController.cuisineModel!.cuisines![index].id, cuisineController.cuisineModel!.cuisines![index].name));
                                },
                                child: SizedBox(
                                  height: 130,
                                  child: CuisineCardWidget(
                                    image: '${cuisineController.cuisineModel!.cuisines![index].imageFullUrl}',
                                    name: cuisineController.cuisineModel!.cuisines![index].name!,
                                    fromCuisinesPage: true,
                                  ),
                                ),
                              );
                            }) : const Center(child: CircularProgressIndicator()),
                        ],
                      );
                    }),
                  ),
                ),
              ]),
            ),
          )),
        ]),
      ),
    );
  }
}

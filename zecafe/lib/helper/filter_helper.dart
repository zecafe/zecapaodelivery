import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';

class FilterHelper {
  //
  //  static int _getRatting(FilterDataModel? filterDataModel){
  //   if(filterDataModel != null){
  //     if(filterDataModel.rating5 == 1){
  //       return 5;
  //     }
  //     else if(filterDataModel.rating4 == 1){
  //       return 4;
  //     }
  //     else if(filterDataModel.rating3 == 1){
  //       return 3;
  //     }
  //     else if(filterDataModel.rating2 == 1){
  //       return 2;
  //     }
  //     else if(filterDataModel.rating1 == 1){
  //       return 1;
  //     }
  //   }
  //   return -1;
  // }

  static String foodType(bool veg, bool nonVeg) {
      if(veg && nonVeg){
        return '';
      }
      else if(veg) {
        return 'veg';
      } else if(nonVeg) {
        return 'non_veg';
      } else {
        return '';
      }
  }

  static String getSortTypeFromIndex(int sortBy, {required bool isRestaurant}) {
    if (isRestaurant) {
      switch (sortBy) {
        case 1:
          return 'a_to_z';
        case 2:
          return 'z_to_a';
        case 3 :
          return 'distance';
        case 4:
          return 'fast_delivery';
        default:
          return ''; // fallback
      }
    } else {
      switch (sortBy) {
        case 1:
          return 'a_to_z';
        case 2:
          return 'z_to_a';
        case 3:
          return 'price_low_to_high';
        case 4:
          return 'price_high_to_low';
        default:
          return ''; // fallback
      }
    }
  }


}
class FilterDataModel {
  String? name;
  int? offset;
  int? limit;
  bool? isRestaurant;
  int? restaurantSortIndex;
  int? sortIndex;
  double? minPrice;
  double? maxPrice;
  double? minLimit;
  double? maxLimit;
  List<int>? restDeliveryTypes;
  List<int>? deliveryTypes;
  bool? restVeg;
  bool? veg;
  bool? restNonVeg;
  bool? nonVeg;
  int? restRating;
  int? rating;
  bool? restFreeDelivery;
  bool? freeDelivery;
  bool? restIsAvailable;
  bool? isAvailable;
  bool? restIsNew;
  bool? isNew;
  bool? restDiscounted;
  bool? discounted;
  bool? restIsPopular;
  bool? isPopular;
  List<int>? restSelectedCuisines;
  List<int>? selectedCuisines;

  FilterDataModel({
    this.name,
    this.offset,
    this.limit,
    this.isRestaurant,
    this.restaurantSortIndex,
    this.sortIndex,
    this.minPrice,
    this.maxPrice,
    this.minLimit,
    this.maxLimit,
    this.restDeliveryTypes,
    this.deliveryTypes,
    this.restVeg,
    this.veg,
    this.restNonVeg,
    this.nonVeg,
    this.restRating,
    this.rating,
    this.restFreeDelivery,
    this.freeDelivery,
    this.restIsAvailable,
    this.isAvailable,
    this.restIsNew,
    this.isNew,
    this.restDiscounted,
    this.discounted,
    this.restIsPopular,
    this.isPopular,
    this.restSelectedCuisines,
    this.selectedCuisines,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name ?? '',
      'offset': offset ?? '',
      'limit': limit ?? '',
      'is_restaurant': isRestaurant ?? '',

      'restaurant_sort_index': restaurantSortIndex ?? '',
      'sort_index': sortIndex ?? '',

      'min_price': minPrice ?? '',
      'max_price': maxPrice ?? '',
      'min_limit': minLimit ?? '',
      'max_limit': maxLimit ?? '',

      'rest_delivery_types': restDeliveryTypes ?? [],
      'delivery_types': deliveryTypes ?? [],

      'rest_veg': restVeg == null ? '' : (restVeg! ? 1 : 0),
      'veg': veg == null ? '' : (veg! ? 1 : 0),

      'rest_non_veg': restNonVeg == null ? '' : (restNonVeg! ? 1 : 0),
      'non_veg': nonVeg == null ? '' : (nonVeg! ? 1 : 0),

      'rest_rating': restRating ?? '',
      'rating': rating ?? '',

      'rest_free_delivery': restFreeDelivery == null ? '' : (restFreeDelivery! ? 1 : 0),
      'free_delivery': freeDelivery == null ? '' : (freeDelivery! ? 1 : 0),

      'rest_is_available': restIsAvailable == null ? '' : (restIsAvailable! ? 1 : 0),
      'is_available': isAvailable == null ? '' : (isAvailable! ? 1 : 0),

      'rest_is_new': restIsNew == null ? '' : (restIsNew! ? 1 : 0),
      'is_new': isNew == null ? '' : (isNew! ? 1 : 0),

      'rest_discounted': restDiscounted == null ? '' : (restDiscounted! ? 1 : 0),
      'discounted': discounted == null ? '' : (discounted! ? 1 : 0),

      'rest_is_popular': restIsPopular == null ? '' : (restIsPopular! ? 1 : 0),
      'is_popular': isPopular == null ? '' : (isPopular! ? 1 : 0),

      'rest_cuisines': restSelectedCuisines ?? [],
      'cuisines': selectedCuisines ?? [],
    };
  }
}
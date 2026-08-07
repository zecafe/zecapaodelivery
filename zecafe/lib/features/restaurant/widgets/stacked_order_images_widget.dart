import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class StackedOrderImagesWidget extends StatelessWidget {
  final List<String> imageUrls;
  final int totalCount;
  final double imageSize;
  final double overlap;
  final bool showCountAsOverlay;


  const StackedOrderImagesWidget({
    super.key,
    required this.imageUrls,
    required this.totalCount,
    this.imageSize = 32,
    this.overlap = 14,
    this.showCountAsOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> visibleImages = imageUrls.isEmpty ? ['1'] : imageUrls.take(3).toList();
    final int remaining = totalCount - visibleImages.length;
    final bool showOverlay = remaining > 0;
    final double stackWidth = visibleImages.length * (imageSize - overlap) + imageSize;

    return Row(
      children: [
        SizedBox(
          width: stackWidth,
          height: imageSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(visibleImages.length, (index) {
              final bool isFront = index == visibleImages.length - 1;
              return Positioned(
                left: index * (imageSize - overlap),
                child: Container(
                  height: imageSize,
                  width: imageSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).cardColor, width: 2),
                  ),
                  child: ClipOval(
                    child: Stack(
                      children: [
                        CustomImageWidget(
                          image: visibleImages[index],
                          height: imageSize,
                          width: imageSize,
                          isFood: true,
                          placeholderBgColor : Theme.of(context).cardColor,
                        ),
                        if (isFront && showOverlay && showCountAsOverlay)
                          Container(
                            height: imageSize,
                            width: imageSize,
                            alignment: Alignment.center,
                            color: Colors.black.withValues(alpha: 0.55),
                            child: Text(
                              '+$remaining',
                              style: robotoBold.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        if(!showCountAsOverlay && remaining > 0)...[
          SizedBox(width: Dimensions.paddingSizeExtraSmall,),
          Text('+$remaining', style: robotoBold.copyWith(fontSize: 12,),)
        ]
      ],
    );
  }
}

// localization keys used:
// (none)

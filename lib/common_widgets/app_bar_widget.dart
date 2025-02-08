import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/calender_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/drop_down_widget.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showActionButton;
  final Function()? onBackPressed;
  final bool centerTitle;
  final double? fontSize;
  final bool isHome;
  final String? subTitle;
  final bool showTripHistoryFilter;
  const AppBarWidget({
    super.key,
    required this.title,
    this.subTitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = false,
    this.showActionButton = true,
    this.isHome = false,
    this.showTripHistoryFilter = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    final Color textColor = isDarkMode
        ? Colors.white
        : const Color(0xFF333333); // Color primario en modo claro

    return PreferredSize(
      preferredSize: const Size.fromHeight(150.0),
      child: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: InkWell(
          onTap: isHome
              ? () {
                  Address? currentAddress =
                      Get.find<LocationController>().getUserAddress();
                  if (currentAddress == null ||
                      currentAddress.longitude == null) {
                    Get.to(() => const AccessLocationScreen());
                  } else {
                    Get.find<LocationController>().updatePosition(
                      LatLng(
                          currentAddress.latitude!, currentAddress.longitude!),
                      false,
                      LocationType.location,
                    );
                    Get.to(() => PickMapScreen(
                        type: LocationType.accessLocation,
                        address: currentAddress));
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.only(
                left:
                    Dimensions.paddingSizeSmall), // Ajuste de padding izquierdo
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isHome) // Mostrar la imagen solo en la página de inicio
                      Padding(
                        padding: const EdgeInsets.only(
                            right: Dimensions.paddingSizeSmall),
                        child: Image.asset(
                          Images
                              .hand, // Asegúrate de que Images.hand esté definido en tu archivo de imágenes
                          height: 24,
                          width: 24,
                        ),
                      ),
                    Text(
                      title.tr,
                      style: textBold.copyWith(
                        fontSize: (fontSize ?? Dimensions.fontSizeLarge) + 4,
                        color: textColor, // Usar el color definido
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showTripHistoryFilter)
                      GetBuilder<TripController>(builder: (tripController) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault),
                            child: DropDownWidget<int>(
                              showText: false,
                              showLeftSide: false,
                              menuItemWidth: 120,
                              icon: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.filter_list_sharp,
                                  color: Theme.of(context).primaryColor,
                                  size: 16,
                                ),
                              ),
                              maxListHeight: 200,
                              items: tripController.filterList
                                  .map((item) => CustomDropdownMenuItem<int>(
                                        value: tripController.filterList
                                            .indexOf(item),
                                        child: Text(
                                          item.tr,
                                          style: textRegular.copyWith(
                                            color: isDarkMode
                                                ? (Get.find<TripController>()
                                                            .filterIndex ==
                                                        Get.find<
                                                                TripController>()
                                                            .filterList
                                                            .indexOf(item)
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.white)
                                                : (Get.find<TripController>()
                                                            .filterIndex ==
                                                        Get.find<
                                                                TripController>()
                                                            .filterList
                                                            .indexOf(item)
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .color),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              hintText: tripController
                                  .filterList[
                                      Get.find<TripController>().filterIndex]
                                  .tr,
                              borderRadius: 5,
                              onChanged: (int selectedItem) {
                                if (selectedItem ==
                                    tripController.filterList.length - 1) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => CalenderWidget(
                                        onChanged: (value) => Get.back()),
                                  );
                                } else {
                                  tripController
                                      .setFilterTypeName(selectedItem);
                                }
                              },
                            ),
                          ),
                        );
                      }),
                  ],
                ),
                subTitle != null
                    ? Text(
                        '${'trip'.tr} #$subTitle',
                        style: textBold.copyWith(
                          fontSize: (fontSize ?? Dimensions.fontSizeLarge) + 4,
                          color: textColor, // Usar el color definido
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox(),
                isHome
                    ? GetBuilder<LocationController>(
                        builder: (locationController) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeExtraSmall),
                          child: Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                color: textColor, // Usar el color definido
                                size: 16,
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSeven),
                              Expanded(
                                child: Text(
                                  locationController
                                          .getUserAddress()
                                          ?.address ??
                                      '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textRegular.copyWith(
                                    color: textColor, // Usar el color definido
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        centerTitle: centerTitle,
        excludeHeaderSemantics: true,
        titleSpacing: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                color: textColor, // Usar el color definido
                onPressed: () => onBackPressed != null
                    ? onBackPressed!()
                    : Navigator.canPop(context)
                        ? Get.back()
                        : Get.offAll(() => const DashboardScreen()),
              )
            : null, // Eliminamos la imagen icon
      ),
    );
  }

  @override
  Size get preferredSize => const Size(Dimensions.webMaxWidth, 150);
}

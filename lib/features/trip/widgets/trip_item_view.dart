import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:ride_sharing_user_app/features/auth/domain/enums/refund_status_enum.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_safety_sheet_details_widget.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

class TripItemView extends StatefulWidget {
  final TripDetails tripDetails;
  final bool isDetailsScreen;
  const TripItemView({super.key, required this.tripDetails, this.isDetailsScreen = false});

  @override
  State<TripItemView> createState() => _TripItemViewState();
}

class _TripItemViewState extends State<TripItemView> {
  JustTheController toolTipController = JustTheController();

  @override
  void initState() {
    if(widget.tripDetails.customerSafetyAlert != null && widget.isDetailsScreen){
      showToolTips();
    }
    super.initState();
  }


  @override
  void dispose() {
    toolTipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(widget.tripDetails.currentStatus == 'accepted' ||
            widget.tripDetails.currentStatus == 'ongoing'||
            widget.tripDetails.currentStatus == 'pending'){
          if(widget.tripDetails.type == 'parcel'){
            Get.find<RideController>().getRideDetails(widget.tripDetails.id!).then((value) {
              if(widget.tripDetails.currentStatus == 'accepted'){
                Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.otpSent);
                Get.to(()=> const MapScreen(fromScreen: MapScreenType.parcel));

              }else if (widget.tripDetails.currentStatus == 'ongoing'){
                Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.parcelOngoing);
                if(value.body['data']['parcel_information']['payer'] == 'sender' &&
                    value.body['data']['payment_status'] == 'unpaid'){
                  Get.off(()=>const PaymentScreen(fromParcel: true));

                }else{
                  Get.to(()=> const MapScreen(fromScreen: MapScreenType.parcel));

                }
              }else{
                Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.findingRider);
                Get.to(()=> const MapScreen(fromScreen: MapScreenType.parcel));

              }
            });

          }else{
            Get.find<RideController>().getRideDetails(widget.tripDetails.id!);
            if(widget.tripDetails.currentStatus == 'accepted'){
              Get.find<RideController>().updateRideCurrentState(RideState.acceptingRider);
            }else if (widget.tripDetails.currentStatus == 'ongoing'){
              Get.find<RideController>().updateRideCurrentState(RideState.ongoingRide);
            }else{
              Get.find<RideController>().updateRideCurrentState(RideState.findingRider);
            }
            Get.to(()=> const MapScreen(fromScreen: MapScreenType.ride));
          }
        }else{
          if(widget.tripDetails.currentStatus == 'completed' && widget.tripDetails.paymentStatus == 'unpaid'){
            Get.find<RideController>().getFinalFare(widget.tripDetails.id!).then((value){
              Get.to(()=> PaymentScreen(fromParcel: widget.tripDetails.type == 'parcel' ? true : false));
            });

          }else{
            Get.to(()=> TripDetailsScreen(tripId: widget.tripDetails.id!));
          }
        }
      },
      child: Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Stack(children: [
            Container(width: 80, height: Get.height * 0.105,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color:widget.tripDetails.vehicle != null ?
                Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.02) :
                Theme.of(context).cardColor,
              ),
              child: Center(child: Column(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: widget.tripDetails.type != 'parcel' ?
                    ImageWidget(width: 60, height: 60,
                        image : widget.tripDetails.vehicle != null ?
                        '${Get.find<ConfigController>().config!.imageBaseUrl!.vehicleModel!}/${widget.tripDetails.vehicle!.model!.image!}' :
                        '${Get.find<ConfigController>().config!.imageBaseUrl!.vehicleCategory!}/${widget.tripDetails.vehicleCategory?.image!}',
                        fit: BoxFit.cover) :
                    Image.asset(Images.parcel,height: 60,width: 30)
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  widget.tripDetails.type != 'parcel' ?
                  widget.tripDetails.vehicleCategory != null ?
                  widget.tripDetails.vehicleCategory!.name!
                      : '' :
                  'parcel'.tr,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.8),
                  ),
                ),
              ])),
            ),

            if(!widget.isDetailsScreen)
            Positioned(
              right: 0,
              child: Container(
                height: 20,width: 20,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color:  widget.tripDetails.currentStatus == 'cancelled' ?
                    Theme.of(context).colorScheme.error.withValues(alpha:0.15) :
                    widget.tripDetails.currentStatus == 'completed' ?
                    Theme.of(context).colorScheme.surfaceTint.withValues(alpha:0.15) :
                    widget.tripDetails.currentStatus == 'returning' ?
                    Theme.of(context).colorScheme.surfaceContainer.withValues(alpha:0.15) :
                    widget.tripDetails.currentStatus == 'returned' ?
                    Theme.of(context).colorScheme.surfaceTint.withValues(alpha:0.15) :
                    Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha:0.3) ,
                    shape: BoxShape.circle
                ),
                child: widget.tripDetails.currentStatus == 'cancelled' ?
                Image.asset(Images.crossIcon,color: Theme.of(context).colorScheme.error) :
                widget.tripDetails.currentStatus == 'completed' ?
                Image.asset(Images.selectedIcon,color: Theme.of(context).colorScheme.surfaceTint) :
                widget.tripDetails.currentStatus == 'returning' ?
                Image.asset(Images.returnIcon,color: Theme.of(context).colorScheme.surfaceContainer) :
                widget.tripDetails.currentStatus == 'returned' ?
                Image.asset(Images.returnIcon,color: Theme.of(context).colorScheme.surfaceTint) :
                Image.asset(Images.ongoingMarkerIcon,color: Theme.of(context).colorScheme.tertiaryContainer),
              ),
            )
          ]),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text (
              '${'trip_id'.tr}: ${widget.tripDetails.refId}',
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.8) ,
              ),
            ),

            Row(spacing: Dimensions.paddingSizeSmall, children: [
              Expanded(
                child: Text( widget.tripDetails.type == 'parcel' ?
                widget.tripDetails.parcelInformation?.parcelCategoryName ?? '' :
                widget.tripDetails.destinationAddress ?? '',
                  style: textRegular.copyWith(
                    color: Get.isDarkMode ?
                    Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.9) :
                    Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.8),
                  ),overflow: TextOverflow.ellipsis,
                ),
              ),

              if(widget.tripDetails.customerSafetyAlert != null && widget.isDetailsScreen)
                JustTheTooltip(
                  backgroundColor: Get.isDarkMode ?
                  Theme.of(context).primaryColor :
                  Theme.of(context).textTheme.bodyMedium!.color,
                  controller: toolTipController,
                  preferredDirection: AxisDirection.right,
                  tailLength: 10,
                  tailBaseWidth: 20,
                  content: Container(width: Get.width * 0.5,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Text(
                      'tap_to_see_safety_details'.tr,
                      style: textRegular.copyWith(
                        color: Colors.white, fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: ()=> Get.bottomSheet(
                      isScrollControlled: true,
                      TripSafetySheetDetailsWidget(tripDetails: widget.tripDetails),
                      backgroundColor: Theme.of(context).cardColor,isDismissible: false,
                    ),
                    child: Image.asset(Images.safelyShieldIcon3,height: 24,width: 24),
                  ),
                )
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text (
                DateConverter.isoStringToDateTimeString(widget.tripDetails.createdAt!),
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.8) ,
                ),
              ),

              if(!widget.isDetailsScreen && (widget.tripDetails.parcelRefund?.status == RefundStatus.pending || widget.tripDetails.parcelRefund?.status == RefundStatus.approved))
              Image.asset(Images.tripDetailsRefundIcon,height: 16,width: 16),

              if(widget.tripDetails.customerSafetyAlert != null && !widget.isDetailsScreen)
              Image.asset(Images.safelyShieldIcon1,height: 16,width: 16)
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            !widget.isDetailsScreen ?
            SizedBox(width: Get.width*0.6, child: Row( children: [
              widget.tripDetails.estimatedFare!=null ?
              Text(PriceConverter.convertPrice(
                (
                    widget.tripDetails.currentStatus == 'cancelled' || widget.tripDetails.currentStatus == 'completed' ||
                    (widget.tripDetails.parcelInformation?.payer == 'sender' && widget.tripDetails.currentStatus == 'ongoing') ||
                    widget.tripDetails.currentStatus == 'returning' || widget.tripDetails.currentStatus == 'returned'
                ) ?
                  widget.tripDetails.paidFare! :
                ( widget.tripDetails.discountActualFare! > 0 ? widget.tripDetails.discountActualFare! : widget.tripDetails.actualFare!),
              ),
                style: textRobotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ) :
              const SizedBox(),

            ])) :
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              widget.tripDetails.estimatedFare != null ?
              Text(PriceConverter.convertPrice(widget.tripDetails.paidFare!),
                style: textRobotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ) :
              const SizedBox(),

              Text(widget.tripDetails.currentStatus!.tr,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ])),
        ]),
      ),
    );
  }

  void showToolTips(){
    WidgetsBinding.instance.addPostFrameCallback((_){
      Future.delayed(const Duration(milliseconds: 500)).then((_){
        toolTipController.showTooltip();
      });
    });
  }
}
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

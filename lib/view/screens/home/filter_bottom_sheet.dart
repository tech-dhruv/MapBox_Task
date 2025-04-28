import 'package:flutter/material.dart';
import 'package:mapbox_task/config/app_constants.dart';
import 'package:mapbox_task/config/assets.dart';
import 'package:mapbox_task/config/color.dart';
import 'package:mapbox_task/config/dimensions.dart';
import 'package:mapbox_task/config/text_style.dart';
import 'package:mapbox_task/providers/map_provider.dart';
import 'package:mapbox_task/view/base/theme_button.dart';
import 'package:provider/provider.dart';

typedef CategoryUpdateCallback = void Function(String category);

class FilterBottomSheet extends StatefulWidget {
  final CategoryUpdateCallback? onCategoryToggled;

  const FilterBottomSheet({
    super.key,
    this.onCategoryToggled,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, _) {
        return Container(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 15),
          decoration: BoxDecoration(
            color: ColorPallet.secondaryDarkBlackColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  SizedBox(width: 30),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: Dimensions.FONT_SIZE_LARGE_20,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppConstants.FONT_FAMILY,
                      color: ColorPallet.whiteColor,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    highlightColor: ColorPallet.secondaryColor.withOpacity(0.5),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: ColorPallet.whiteColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Store Categories',
                style: TextStyle(
                  fontSize: Dimensions.FONT_SIZE_LARGE_18,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppConstants.FONT_FAMILY,
                  color: ColorPallet.whiteColor,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildCategoryToggle(
                    'Bronze',
                    Assets.BRONZE,
                    mapProvider.showBronzeStores,
                    () => _toggleCategory(mapProvider, 'bronze'),
                  ),
                  const SizedBox(width: 10),
                  _buildCategoryToggle(
                    'Silver',
                    Assets.SILVER,
                    mapProvider.showSilverStores,
                    () => _toggleCategory(mapProvider, 'silver'),
                  ),
                  const SizedBox(width: 10),
                  _buildCategoryToggle(
                    'Gold',
                    Assets.GOLD,
                    mapProvider.showGoldStores,
                    () => _toggleCategory(mapProvider, 'gold'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Customers',
                style: TextStyle(
                  fontSize: Dimensions.FONT_SIZE_LARGE_18,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppConstants.FONT_FAMILY,
                  color: ColorPallet.whiteColor,
                ),
              ),
              const SizedBox(height: 10),
              _buildCustomerToggle(mapProvider),
              const SizedBox(height: 20),
              ThemeButton(
                onTap: () {
                  Navigator.pop(context);
                },
                title: 'Apply Filters',
                shadow: false,
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryToggle(
      String label, String iconAsset, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? ColorPallet.secondaryColor.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isActive
                  ? ColorPallet.secondaryColor
                  : ColorPallet.whiteColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Image.asset(
                iconAsset,
                height: 30,
                width: 30,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: Dimensions.FONT_SIZE_13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontFamily: AppConstants.FONT_FAMILY,
                  color: isActive
                      ? ColorPallet.whiteColor
                      : ColorPallet.whiteColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerToggle(MapProvider mapProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: ColorPallet.whiteColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            Assets.BLUE_CUSTOMER_PIN,
            height: 30,
            width: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Show Customers',
              style: TextStyles.bodyText2(
                color: ColorPallet.whiteColor,
              ),
            ),
          ),
          Switch(
            value: mapProvider.showCustomers,
            onChanged: (value) {
              _toggleCustomers(mapProvider);
            },
            activeColor: ColorPallet.secondaryColor,
          ),
        ],
      ),
    );
  }

  void _toggleCategory(MapProvider mapProvider, String category) {
    setState(() {
      switch (category) {
        case 'bronze':
          mapProvider.toggleBronzeStores();
          break;
        case 'silver':
          mapProvider.toggleSilverStores();
          break;
        case 'gold':
          mapProvider.toggleGoldStores();
          break;
      }
    });

    // Call the callback if provided
    if (widget.onCategoryToggled != null) {
      widget.onCategoryToggled!(category);
    }
  }

  void _toggleCustomers(MapProvider mapProvider) {
    setState(() {
      mapProvider.toggleCustomers();
    });

    // Call the callback if provided
    if (widget.onCategoryToggled != null) {
      widget.onCategoryToggled!('customers');
    }
  }
}

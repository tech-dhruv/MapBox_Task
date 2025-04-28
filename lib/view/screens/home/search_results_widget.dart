import 'package:flutter/material.dart';
import 'package:mapbox_task/config/color.dart';
import 'package:mapbox_task/config/text_style.dart';
import 'package:mapbox_task/models/search_place_model.dart';
import 'package:mapbox_task/providers/search_provider.dart';
import 'package:provider/provider.dart';

class SearchResultsWidget extends StatelessWidget {
  const SearchResultsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        final results = searchProvider.searchResults;
        final isSearching = searchProvider.isSearching;
        
        if (isSearching) {
          return _buildLoadingIndicator();
        }
        
        if (results.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return _buildResultsList(context, results);
      },
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      color: ColorPallet.secondaryDarkBlackColor,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: const Center(
        child: CircularProgressIndicator(
          color: ColorPallet.secondaryColor,
        ),
      ),
    );
  }
  
  Widget _buildResultsList(BuildContext context, List<SearchPlace> results) {
    return Container(
      color: ColorPallet.secondaryDarkBlackColor,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: results.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        separatorBuilder: (context, index) => const Divider(
          color: ColorPallet.greyColor, 
          height: 1,
        ),
        itemBuilder: (context, index) {
          final place = results[index];
          return _buildResultItem(context, place);
        },
      ),
    );
  }
  
  Widget _buildResultItem(BuildContext context, SearchPlace place) {
    return InkWell(
      onTap: () {
        // When a result is tapped, update the selected place
        Provider.of<SearchProvider>(context, listen: false).selectPlace(place);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(
              _getIconForPlaceType(place.placeType),
              color: ColorPallet.whiteColor.withOpacity(0.7),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place.name,
                    style: TextStyles.bodyText1(
                      color: ColorPallet.whiteColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.address,
                    style: TextStyles.bodyText3(
                      color: ColorPallet.whiteColor.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconForPlaceType(String? placeType) {
    switch (placeType) {
      case 'poi':
        return Icons.place;
      case 'address':
        return Icons.home;
      case 'place':
        return Icons.location_city;
      case 'locality':
        return Icons.location_on;
      case 'region':
        return Icons.map;
      default:
        return Icons.location_on;
    }
  }
} 
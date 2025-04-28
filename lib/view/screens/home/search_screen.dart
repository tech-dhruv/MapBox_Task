import 'package:flutter/material.dart';
import 'package:mapbox_task/config/color.dart';
import 'package:mapbox_task/config/text_style.dart';
import 'package:mapbox_task/models/search_place_model.dart';
import 'package:mapbox_task/providers/search_provider.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late SearchProvider _searchProvider;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _searchProvider = Provider.of<SearchProvider>(context);
    _searchController.text = _searchProvider.searchQuery;
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      if (_searchProvider.selectedPlace != null) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: ColorPallet.whiteColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 16),
                Text(
                  'Search Location',
                  style: TextStyles.bodyText1(color: ColorPallet.whiteColor),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: ColorPallet.secondaryDarkBlackColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorPallet.whiteColor.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: TextStyles.bodyText2(color: ColorPallet.whiteColor),
                cursorColor: ColorPallet.secondaryColor,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search for places...',
                  hintStyle: TextStyles.bodyText2(color: ColorPallet.whiteColor.withOpacity(0.5)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: ColorPallet.whiteColor,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: ColorPallet.whiteColor,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _searchProvider.clearSearch();
                        },
                      )
                    : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  _searchProvider.setSearchQuery(value);
                },
                onSubmitted: (value) {
                  if (_searchProvider.searchResults.isNotEmpty) {
                    _searchProvider.selectPlace(_searchProvider.searchResults.first);
                    
                    FocusScope.of(context).unfocus();
                    
                    Future.delayed(const Duration(milliseconds: 50), () {
                      Navigator.pop(context);
                    });
                  }
                },
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, _) {
                if (provider.isSearching) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorPallet.secondaryColor,
                    ),
                  );
                }
                
                if (provider.searchResults.isEmpty) {
                  if (_searchController.text.isNotEmpty) {
                    return Center(
                      child: Text(
                        'No results found',
                        style: TextStyles.bodyText2(color: ColorPallet.whiteColor.withOpacity(0.7)),
                      ),
                    );
                  }
                  return Center(
                    child: Text(
                      'Start typing to search',
                      style: TextStyles.bodyText2(color: ColorPallet.whiteColor.withOpacity(0.7)),
                    ),
                  );
                }
                
                return _buildSearchResults(provider.searchResults);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults(List<SearchPlace> places) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: places.length,
      separatorBuilder: (context, index) => const Divider(
        color: ColorPallet.secondaryDarkBlackColor,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final place = places[index];
        return ListTile(
          onTap: () {
            _searchProvider.selectPlace(place);
            
            FocusScope.of(context).unfocus();
            
            Future.delayed(const Duration(milliseconds: 50), () {
              Navigator.pop(context);
            });
          },
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          leading: Icon(
            _getIconForPlaceType(place.placeType),
            color: ColorPallet.secondaryColor,
          ),
          title: Text(
            place.name,
            style: TextStyles.bodyText2(color: ColorPallet.whiteColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            place.address,
            style: TextStyles.bodyText3(color: ColorPallet.whiteColor.withOpacity(0.7)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
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
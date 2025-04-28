import 'package:mapbox_task/config/assets.dart';
import 'package:mapbox_task/models/stores_model.dart';

class MarkerHelper {
  /// Determines the appropriate marker asset path based on store data
  static String getMarkerAsset(Stores store) {
    // Step 1: Determine the tier (Gold, Silver, Bronze) based on percentile
    String tier = determineTier(store.percentile);
    
    // Step 2: Determine the color (Green, Yellow, Red, Gray) based on sales ratio
    String color = _determineColor(store.caseVolumeLtm, store.cirocCases);
    
    // Step 3: Return the corresponding marker asset
    switch (tier) {
      case 'gold':
        switch (color) {
          case 'green': return Assets.GOLD_GREEN;
          case 'yellow': return Assets.GOLD_YELLOW;
          case 'red': return Assets.GOLD_RED;
          case 'gray': 
          default: return Assets.GOLD_GRAY;
        }
      case 'silver':
        switch (color) {
          case 'green': return Assets.SILVER_GREEN;
          case 'yellow': return Assets.SILVER_YELLOW;
          case 'red': return Assets.SILVER_RED;
          case 'gray': 
          default: return Assets.SILVER_GRAY;
        }
      case 'bronze':
      default:
        switch (color) {
          case 'green': return Assets.BRONZE_GREEN;
          case 'yellow': return Assets.BRONZE_YELLOW;
          case 'red': return Assets.BRONZE_RED;
          case 'gray': 
          default: return Assets.BRONZE_GRAY;
        }
    }
  }
  
  /// Determines the tier (Gold, Silver, Bronze) based on percentile
  ///   Gold: Percentile < 10
  ///   Silver: Percentile between 10-50
  ///   Bronze: Percentile > 50 or no percentile data
  static String determineTier(double? percentile) {
    if (percentile == null) {
      return 'bronze';
    }
    
    if (percentile < 10) {
      return 'gold';
    } else if (percentile >= 10 && percentile <= 50) {
      return 'silver';
    } else {
      return 'bronze';
    }
  }
  
  /// Determines color based on sales ratio:
  ///   Green: caseVolumeLTM > 30% of cirocCases
  ///   Yellow: caseVolumeLTM between 15% - 30% of cirocCases
  ///   Red: caseVolumeLTM between 0% - 15% of cirocCases
  ///   Gray: No cirocCases data or caseVolumeLTM is 0 or not available
  static String _determineColor(double? caseVolumeLtm, double? cirocCases) {
    // If either value is null or caseVolumeLtm is 0, return gray
    if (caseVolumeLtm == null || cirocCases == null || caseVolumeLtm == 0 || cirocCases == 0) {
      return 'gray';
    }
    
    // Calculate the ratio as a percentage
    double ratio = (caseVolumeLtm / cirocCases) * 100;
    
    if (ratio > 30) {
      return 'green';
    } else if (ratio >= 15 && ratio <= 30) {
      return 'yellow';
    } else {
      return 'red';
    }
  }
} 
import 'package:meta/meta.dart';
import 'package:vector_tile/vector_tile.dart';
import 'package:vector_tile_query/util/segment.dart';

/// Takes a geojson feature, calculates the bbox of all input features, and returns a bounding box.
///
/// @param geojson any GeoJSON object
/// @returns bbox extent in [minX, minY, maxX, maxY] order
List<double> getbbox({@required GeoJson geoJson}) {
  List<double> bbox = [double.infinity, double.infinity, -double.infinity, -double.infinity];

  coordEach(
    geoJson: geoJson,
    callback: ({List<double> coord, int coordIndex}) {
      if (bbox[0] > coord[0]) {
        bbox[0] = coord[0];
      }
      if (bbox[1] > coord[1]) {
        bbox[1] = coord[1];
      }
      if (bbox[2] < coord[0]) {
        bbox[2] = coord[0];
      }
      if (bbox[3] < coord[1]) {
        bbox[3] = coord[1];
      }

      return false;
    }
  );

  return bbox;
}

/// Check a point is inside bbox
bool pointInBBox({@required List<double> point, @required List<double> bbox}) {
  return (
    bbox[0] <= point[0] && 
    bbox[1] <= point[1] && 
    bbox[2] >= point[0] && 
    bbox[3] >= point[1]
  );
}
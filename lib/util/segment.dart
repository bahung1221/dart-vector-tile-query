import 'package:meta/meta.dart';
import 'package:vector_tile/util/geojson.dart';
import 'package:vector_tile_query/reverse_geocoding.dart';


/// Iterate over 2-vertex line segment in any GeoJSON object, similar to List.forEach()
/// (Multi)Point geometries do not contain segments therefore they are ignored during this operation.
/// 
/// @param geojson any GeoJSON type
/// @param {Function} callback that will be call for each segment
void segmentEach({
  @required GeoJson geoJson, 
  @required bool Function({
    @required List<List<double>> segment
  }) callback
}) {
  if (geoJson.geometry == null) return;
  if (geoJson.geometry.type == GeometryType.Point) return;
  if (geoJson.geometry.type == GeometryType.MultiPoint) return;

  flattenEach(
    geoJson: geoJson,
    callback: ({GeoJson feature, int featureIndex, int multiFeatureIndex}) {
      List<double> previousCoord;

      coordEach(
        geoJson: feature,
        callback: ({List<double> coord, int coordIndex}) {
          if (previousCoord == null) {
            previousCoord = coord;
            return false;
          }

          bool stopFlg = callback(
            segment: [previousCoord, coord], 
          );
          if (stopFlg) return true;

          previousCoord = coord;
          return false;
        }
      );

      return false;
    }
  );
}

/// Flatten given GeoJson to list of single GeoJson feature (for **Multi** types)
/// Then iterate over one by one, similar to List.forEach.
///
/// @param geojson any GeoJSON object
/// @param {Function} callback that will be call for each flattened feature
void flattenEach({
  @required GeoJson geoJson,
  @required bool Function({
    @required GeoJson feature,
    int featureIndex,
    int multiFeatureIndex,
  }) callback
}) {
  // Only support feature type
  if (geoJson.type != GeoJsonType.Feature) {
    return;
  }

  if ([
    GeometryType.Point, 
    GeometryType.LineString, 
    GeometryType.Polygon
  ].contains(geoJson.geometry.type)) {
    callback(
      feature: geoJson, 
      featureIndex: 0,
      multiFeatureIndex: 0,
    );
    return;
  }

  flattenEachMultiGeometry(
    geoJson: geoJson,
    callback: callback,
  );
}

/// Flatten given GeoJson (only **Multi** geometry types) to list of single feature GeoJson
/// Then iterate over one by one, similar to List.forEach.
///
/// @param geojson any GeoJSON object
/// @param {Function} callback that will be call for each flattened feature
void flattenEachMultiGeometry({
  @required GeoJson geoJson,
  @required bool Function({
    @required GeoJson feature,
    int featureIndex,
    int multiFeatureIndex,
  }) callback
}) {
  int coordinatesLength;

  if (geoJson.geometry.type == GeometryType.MultiPoint) {
    coordinatesLength = (geoJson.geometry as GeometryMultiPoint).coordinates.length;
  } else if (geoJson.geometry.type == GeometryType.MultiLineString) {
    coordinatesLength = (geoJson.geometry as GeometryMultiLineString).coordinates.length;
  } else if (geoJson.geometry.type == GeometryType.MultiPolygon) {
    coordinatesLength = (geoJson.geometry as GeometryMultiPolygon).coordinates.length; 
  } else {
    return;
  }
  
  for (int index = 0; index < coordinatesLength; index++) {
    Geometry newGeometry;
    
    if (geoJson.geometry.type == GeometryType.MultiPoint) {
      newGeometry = Geometry.Point(
        coordinates: (geoJson.geometry as GeometryMultiPoint).coordinates[index]
      );
    } else if (geoJson.geometry.type == GeometryType.MultiLineString) {
      newGeometry = Geometry.LineString(
        coordinates: (geoJson.geometry as GeometryMultiLineString).coordinates[index]
      );
    } else if (geoJson.geometry.type == GeometryType.MultiPolygon) {
      newGeometry = Geometry.Polygon(
        coordinates: (geoJson.geometry as GeometryMultiPolygon).coordinates[index]
      );
    }

    bool stopFlag = callback(
      feature: GeoJson(geometry: newGeometry),
      featureIndex: 0,
      multiFeatureIndex: index,
    );
    if (stopFlag) return;
  }
}

/// Iterate over coordinates in any GeoJSON object, similar to List.forEach()
/// Only support **single** geomytry type: Point, LineString, Polygon.
/// If need support for **multi** geometry type, flatten it first (use flattenEach method)
///
/// @param geojson any GeoJSON object
/// @param {Function} callback that will be call for each coord
void coordEach({
  @required GeoJson geoJson, 
  @required bool Function({
    @required List<double> coord, 
    int coordIndex,
  }) callback
}) {
  if (geoJson.geometry.type == GeometryType.Point) {
    callback(
      coord: (geoJson.geometry as GeometryPoint).coordinates,
      coordIndex: 0,
    );
    return;
  }

  if (geoJson.geometry.type == GeometryType.LineString) {
    GeometryLineString geometry = geoJson.geometry as GeometryLineString;
    int coordsLength = geometry.coordinates.length;

    for (int i = 0; i < coordsLength; i++) {
      bool stopFlg = callback(
        coord: geometry.coordinates[i],
        coordIndex: i,
      );
      if (stopFlg) return;
    }
    return;
  }

  if (geoJson.geometry.type == GeometryType.Polygon) {
    GeometryPolygon geometry = geoJson.geometry as GeometryPolygon;
    int linesLength = geometry.coordinates.length;
    int coordIndex = 0;

    for (int i = 0; i < linesLength; i++) {
      List<List<double>> lines = geometry.coordinates[i];
      int coordsLength = lines.length;

      for (int j = 0; j < coordsLength; j++) {
        bool stopFlg = callback(
          coord: lines[j],
          coordIndex: coordIndex,
        );
        coordIndex++;
        if (stopFlg) return;
      }
    }
  }
}

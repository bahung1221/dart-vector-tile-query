import 'dart:math';
import 'package:meta/meta.dart';
import 'package:vector_tile/vector_tile.dart';
import 'package:vector_tile_query/util/constant.dart';
import 'package:vector_tile_query/util/distance.dart';

export 'package:vector_tile/vector_tile.dart';

/// Query Options
/// - radius = 0: Direct hit
/// - layers = null: Query in all layers
/// - geometryType = null: Query all geometryType
/// - limit = null: No limit
class ReverseQueryOption {
  double radius;
  int limit;
  List<String> layers;
  List<VectorTileGeomType> geometryTypes;
  Unit unit;

  ReverseQueryOption({
    this.radius = 0, // Direct hit polygon (inside include edge)
    this.limit, // No limit
    this.layers, // All layers
    this.geometryTypes, // All geometry type
    this.unit = Unit.Meters,
  });
}

class QueryTile {
  VectorTile tile;
  int x;
  int y;
  int z;

  QueryTile({
    @required this.tile,
    @required this.x,
    @required this.y,
    @required this.z,
  });
}

class QueryResultFeature {
  GeoJson geoJson;
  VectorTileFeature feature;
  double distance;

  QueryResultFeature({
    @required this.geoJson,
    @required this.feature,
    @required this.distance,
  });
}

/// Reverse geocoding query
///
List<QueryResultFeature> reverseQuery({
  @required List<double> point,
  @required List<QueryTile> queryTiles,
  @required ReverseQueryOption option,
}) {
  List<QueryResultFeature> result = [];
  
  queryTiles.forEach((queryTile) {
    queryTile.tile.layers.forEach((layer) {
      if (!_isValidLayer(layer: layer, queryLayers: option.layers)) {
        return;
      }

      layer.features.forEach((feature) {
        if (!_isValidGeomType(feature: feature, queryGeomTypes: option.geometryTypes)) {
          return;
        }

        GeoJson geoJsonFeature = feature.toGeoJson(
          x: queryTile.x,
          y: queryTile.y,
          z: queryTile.z
        );

        double distance = double.infinity;
        if (geoJsonFeature is GeoJsonPoint) {
          distance = pointToPointDistance(
            from: point, 
            to: geoJsonFeature.geometry.coordinates
          );
        }
        else {
          distance = pointToLineOrPolygonDistance(
            point: point, 
            geoJson: geoJsonFeature,
          );
        }

        if (!_isValidDistance(distance: distance, radius: option.radius)) {
          return;
        }

        result.add(
          QueryResultFeature(
            geoJson: geoJsonFeature, 
            feature: feature, 
            distance: distance,
          )
        );
      });
    });
  });

  result.sort((a, b) {
    if (a.distance > b.distance) return 1;
    if (a.distance == b.distance) return 0;

    return -1;
  });

  return option.limit == null 
    ? result
    : result.sublist(0, min(option.limit, result.length));
}

bool _isValidLayer({@required VectorTileLayer layer, @required List<String> queryLayers}) {
  if (queryLayers == null) {
    return true;
  }

  return queryLayers.any((queryLayer) => queryLayer == layer.name );
}

bool _isValidGeomType({
  @required VectorTileFeature feature, 
  @required List<VectorTileGeomType> queryGeomTypes
}) {
  if (queryGeomTypes == null) {
    return true;
  }

  return queryGeomTypes.any((queryGeomType) => queryGeomType == feature.type);
}

bool _isValidDistance({
  @required double distance, 
  @required double radius,
}) {
  return distance <= radius;
}

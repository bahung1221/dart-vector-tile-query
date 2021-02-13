import 'package:meta/meta.dart';
import 'package:vector_tile/vector_tile.dart';
import 'package:vector_tile_query/util/util.dart' as util;

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

  ReverseQueryOption({
    this.radius = 0, // Direct hit
    this.limit, // No limit
    this.layers, // All layers
    this.geometryTypes, // All geometry type
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
  GeoJson feature;
  double distance;

  QueryResultFeature({
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

        // TODO: support more geojson type instead of only Point
        if (!(geoJsonFeature is GeoJsonPoint)) {
          return;
        }

        GeoJsonPoint geoJsonPointFeature = geoJsonFeature as GeoJsonPoint;
        double distance = util.distance(from: point, to: geoJsonPointFeature.geometry.coordinates);

        if (!_isValidDistance(distance: distance, radius: option.radius)) {
          return;
        }

        result.add(
          QueryResultFeature(feature: geoJsonFeature, distance: distance)
        );
      });
    });
  });

  return result;
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

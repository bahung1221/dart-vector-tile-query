import 'dart:math';
import 'package:meta/meta.dart';
import 'package:vector_tile/vector_tile.dart';
import 'package:vector_tile_query/util/unit.dart';
import 'package:vector_tile_query/util/distance.dart';

export 'package:vector_tile/vector_tile.dart';

/// Query Options for reverse geocoding
/// 
/// @param radius: the radius to query for features, default is 0 (direct hit only)
/// @param limit: limit the number of result items, default is get all
/// @param dedupe: filter duplicated items, default is true
/// @param layers: query in specifics layers, default is all layers
/// @param geometryTypes: query in specifics layers, default is all geometryTypes
/// @param unit: response unit, default is meters
class ReverseQueryOption {
  double radius;
  bool dedupe;
  int limit;
  List<String> layers;
  List<VectorTileGeomType> geometryTypes;
  Unit unit;

  ReverseQueryOption({
    this.radius = 0, // Direct hit polygon (inside include edge)
    this.dedupe = true, // No limit
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

class ResultItem {
  GeoJson geoJson;
  VectorTileFeature feature;
  double distance;

  ResultItem({
    @required this.geoJson,
    @required this.feature,
    @required this.distance,
  });
}

/// Excute reverse geocoding query
///
/// @return list of satisfy items (feature, geojson & distance)
List<ResultItem> reverseQuery({
  @required List<double> point,
  @required List<QueryTile> queryTiles,
  @required ReverseQueryOption option,
}) {
  List<ResultItem> result = [];
  
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
            to: geoJsonFeature.geometry.coordinates,
            unit: option.unit,
          );
        }
        else if (geoJsonFeature is GeoJsonPolygon || geoJsonFeature is GeoJsonMultiPolygon) {
          distance = pointToPolygonDistance(
            point: point, 
            geoJson: geoJsonFeature,
            unit: option.unit,
          );
        } else {
          distance = pointToLineOrPolygonDistance(
            point: point, 
            geoJson: geoJsonFeature,
            unit: option.unit,
          );
        }

        if (!_isValidDistance(distance: distance, radius: option.radius)) {
          return;
        }

        ResultItem newItem = ResultItem(
          geoJson: geoJsonFeature, 
          feature: feature, 
          distance: distance,
        );

        result = _dedupeAndPush(
          curList: result,
          newItem: newItem,
          dedupe: option.dedupe,
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

/// Check if given layer was specified in query layers or not
bool _isValidLayer({@required VectorTileLayer layer, @required List<String> queryLayers}) {
  if (queryLayers == null) {
    return true;
  }

  return queryLayers.any((queryLayer) => queryLayer == layer.name );
}

/// Check if given geomType was specified in query geomTypes or not
bool _isValidGeomType({
  @required VectorTileFeature feature, 
  @required List<VectorTileGeomType> queryGeomTypes
}) {
  if (queryGeomTypes == null) {
    return true;
  }

  return queryGeomTypes.any((queryGeomType) => queryGeomType == feature.type);
}

/// Check if given distance is within query radius or not
bool _isValidDistance({
  @required double distance, 
  @required double radius,
}) {
  return distance <= radius;
}

/// Dedupe if needed and then push the new item to result list
List<ResultItem> _dedupeAndPush({
  @required List<ResultItem> curList,
  @required ResultItem newItem,
  @required bool dedupe,
}) {
  int duplicatedIndex = curList.indexWhere((curItem) {
    return curItem.feature.id == newItem.feature.id;
  });

  if (dedupe && duplicatedIndex >= 0) {
    if (newItem.distance < curList[duplicatedIndex].distance) {
      curList[duplicatedIndex] = newItem;
    }
  } else {
    curList.add(newItem);
  }

  return curList;
}

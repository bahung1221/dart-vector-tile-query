## Dart Vector Tile Query
A Dart package to `query` reverse geocoding on a set of **vector tile protobuf** files (`pbf` or `mvt`).
Using vector tiles that were parsed by [dart-vector-tile](https://github.com/saigontek/dart-vector-tile).

Features:
- [x] Get a list of the features closest to a query point.
- [x] Point in polygon checks (radius=0).


## Sample usage

```dart
import 'package:vector_tile_query/vector_tile_query.dart';

List<QueryTile> tiles = [
    QueryTile(
        tile: await VectorTile.fromPath(path: '../data/13-6525-3847.pbf'),
        x: 6525,
        y: 3847,
        z: 13,
    ),
    QueryTile(
        tile: await VectorTile.fromPath(path: '../data/13-6525-3848.pbf'),
        x: 6525,
        y: 3848,
        z: 13,
    ),
];

ReverseQueryOption option = ReverseQueryOption(
    radius: 20,
    limit: 10,
    geometryTypes: [VectorTileGeomType.POINT],
    layers: ['poi', 'housenumber', 'building', 'park'],
    dedupe: true,
);

List<double> point = [
    106.75985276699066,
    10.844338677301536
]; // lon - lat

var result = reverseQuery(point: point, queryTiles: tiles, option: option);
```

## Result item structure:

```dart
class ResultItem {
  GeoJson geoJson; // GeoJson data
  VectorTileFeature feature; // Raw vector tile feature data
  double distance; // Distance to query point
}
```

- `GeoJson` sample data: https://github.com/saigontek/dart-vector-tile#sample-vectortile-raw-decoded-as-json
- `VectorTileFeature` sample data: https://github.com/saigontek/dart-vector-tile#sample-vectortilefeature-as-geojson-decoded


## Example use cases:

Reverse geocoding to find housenumber, road, suburb and city of a point by given a set of satisfy tiles:

- **1)** Find set of specific zooms for specific feature level. ([OSM zoom levels](https://wiki.openstreetmap.org/wiki/Zoom_levels))
    + 14: housenumber, poi and road.
    + 13: suburb.
    + 12: city

- **2)** Find map tile xy number from a lon/lat pair and above zoom: https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Lon..2Flat._to_tile_numbers

- **3)** Run a set of query to find satisfy result :beer:

[example code](example/lib/main.dart)

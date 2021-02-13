import 'package:vector_tile_query/vector_tile_query.dart';

main() async {
  List<QueryTile> queryTiles = [
    QueryTile(
      tile: await VectorTile.fromPath(path: '../data/14-13050-7695.pbf'),
      x: 13050,
      y: 7695,
      z: 14,
    ),
  ];

  // Robic.vn - 163/50
  List<double> coordinate = [
    106.75985276699066,
    10.844338677301536
  ]; // lon - lat
  ReverseQueryOption option = ReverseQueryOption(
    radius: 20, // 20 meters
    limit: 10,
    geometryTypes: [VectorTileGeomType.POINT],
    layers: ['poi', 'housenumber', 'building', 'park'],
  );

  var result =
      reverseQuery(point: coordinate, option: option, queryTiles: queryTiles);

  result.forEach((queryResultFeature) {
    print('=========');
    queryResultFeature.feature.properties.forEach((property) {
      property.forEach((key, value) {
        if (value.intValue != 0) {
          print(
            'key: $key, value: ${value.intValue}'
          );
        } else {
          print(
            'key: $key, value: ${value.stringValue}'
          );
        }
      });
    });
    print('distance: ${queryResultFeature.distance}');
  });
}

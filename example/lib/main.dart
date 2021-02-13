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
  List<QueryTile> suburbTiles = [
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

  List<QueryTile> cityTiles = [
    QueryTile(
      tile: await VectorTile.fromPath(path: '../data/12-3262-1923.pbf'),
      x: 3262,
      y: 1923,
      z: 12,
    ),
    QueryTile(
      tile: await VectorTile.fromPath(path: '../data/12-3262-1924.pbf'),
      x: 3262,
      y: 1924,
      z: 12,
    ),
    QueryTile(
      tile: await VectorTile.fromPath(path: '../data/12-3263-1923.pbf'),
      x: 3263,
      y: 1923,
      z: 12,
    ),
    QueryTile(
      tile: await VectorTile.fromPath(path: '../data/12-3263-1924.pbf'),
      x: 3263,
      y: 1924,
      z: 12,
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
  ReverseQueryOption optionRoad = ReverseQueryOption(
    radius: 20, // 20 meters
    limit: 10,
    geometryTypes: [VectorTileGeomType.LINESTRING],
    layers: ['transportation_name'],
  );
  ReverseQueryOption optionsSuburb = ReverseQueryOption(
    radius: 500,
    limit: 10,
    layers: ['place'],
  );
  ReverseQueryOption optionsCity = ReverseQueryOption(
    radius: 5000,
    limit: 10,
    layers: ['place'],
  );

  var result = reverseQuery(point: coordinate, option: option, queryTiles: queryTiles);
  var resultRoad = reverseQuery(point: coordinate, option: optionRoad, queryTiles: queryTiles);
  var resultSuburb = reverseQuery(point: coordinate, option: optionsSuburb, queryTiles: suburbTiles);
  var resultCity = reverseQuery(point: coordinate, option: optionsCity, queryTiles: cityTiles);

  print('=========');
  result.forEach((queryResultFeature) {
    queryResultFeature.geoJson.properties.forEach((property) {
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
    print('latlon: ${(queryResultFeature.feature.geometry as GeometryPoint).coordinates}');
    print('id: ${queryResultFeature.feature.id}');
    print('distance: ${queryResultFeature.distance}');
  });
  
  print('=========Road');
  resultRoad.forEach((queryResultFeature) {
    queryResultFeature.geoJson.properties.forEach((property) {
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
    print('latlon: ${(queryResultFeature.feature.geometry as GeometryLineString).coordinates}');
    print('id: ${queryResultFeature.feature.id}');
    print('distance: ${queryResultFeature.distance}');
  });

  print('=========Suburb');
  resultSuburb.forEach((queryResultFeature) {
    queryResultFeature.geoJson.properties.forEach((property) {
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
    print('latlon: ${(queryResultFeature.feature.geometry as GeometryPoint).coordinates}');
    print('id: ${queryResultFeature.feature.id}');
    print('distance: ${queryResultFeature.distance}');
  });

  print('=========CITY');
  resultCity
    .where((queryResultFeature) {
      return queryResultFeature.geoJson.properties.any((property) {
        if (!property.containsKey('class')) return false;

        return property['class'].stringValue != null && 
          ['city', 'town'].contains(property['class'].stringValue);
      });
    })
    .forEach((queryResultFeature) {
      queryResultFeature.geoJson.properties.forEach((property) {
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
      print('latlon: ${(queryResultFeature.feature.geometry as GeometryPoint).coordinates}');
      print('latlon: ${(queryResultFeature.feature.geometry as GeometryPoint).type}');
      print('id: ${queryResultFeature.feature.id}');
      print('distance: ${queryResultFeature.distance}');
    });
}

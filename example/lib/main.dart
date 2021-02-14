import 'package:vector_tile_query/vector_tile_query.dart';

/// Reverse geocoding to find housenumber, road, suburb and city of a point by given a set of satisfy tiles
/// - **1)** Find set of specific zooms for specific feature level. ([OSM zoom levels](https://wiki.openstreetmap.org/wiki/Zoom_levels))
///    + 14: housenumber, poi and road.
///    + 13: suburb.
///    + 12: city
///
/// - **2)** Find map tile xy number from a lon/lat pair and above zoom: https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Lon..2Flat._to_tile_numbers
///
/// - **3)** Run a set of query to find satisfy result :beer:
void reverseGeocoding() async {
  List<QueryTile> houseTiles = [
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
  ReverseQueryOption houseOption = ReverseQueryOption(
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

  var result = reverseQuery(point: coordinate, option: houseOption, queryTiles: houseTiles);
  var resultRoad = reverseQuery(point: coordinate, option: optionRoad, queryTiles: houseTiles);
  var resultSuburb = reverseQuery(point: coordinate, option: optionsSuburb, queryTiles: suburbTiles);
  var resultCity = reverseQuery(point: coordinate, option: optionsCity, queryTiles: cityTiles);

  print('=========POI OF GIVEN COORDINATE=========');
  print('\n');
  result.forEach((queryResultFeature) {
    print('id: ${queryResultFeature.feature.id}');
    print('distance: ${queryResultFeature.distance}');
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
  });
  
  print('\n\n');
  print('=========ROAD OF GIVEN COORDINATE=========');
  resultRoad.forEach((queryResultFeature) {
    print('id: ${queryResultFeature.feature.id}');
    print('distance: ${queryResultFeature.distance}');
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
  });

  print('\n\n');
  print('=========SUBURB OF GIVEN COORDINATE=========');
  print('\n');
  resultSuburb.forEach((queryResultFeature) {
    print('id: ${queryResultFeature.feature.id}');
    print('distance: ${queryResultFeature.distance}');
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
  });

  print('\n\n');
  print('=========CITY OF GIVEN COORDINATE=========');
  print('\n');
  resultCity
    .where((queryResultFeature) {
      return queryResultFeature.geoJson.properties.any((property) {
        if (!property.containsKey('class')) return false;

        return property['class'].stringValue != null && 
          ['city', 'town'].contains(property['class'].stringValue);
      });
    })
    .forEach((queryResultFeature) {
      print('id: ${queryResultFeature.feature.id}');
      print('distance: ${queryResultFeature.distance}');
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
    });
}


void pointInPolygon() async {
  List<QueryTile> tiles = [
    QueryTile(
      tile: await VectorTile.fromPath(path: '../data/12-3261-1920.pbf'),
      x: 3261,
      y: 1920,
      z: 12,
    ),
    QueryTile(
      tile: await VectorTile.fromPath(path: '../data/12-3261-1921.pbf'),
      x: 3261,
      y: 1921,
      z: 12,
    ),
  ];

  List<double> coordinate = [
    106.63813,
    11.10946,
  ]; // lon - lat

  ReverseQueryOption option = ReverseQueryOption(
    radius: 0,
    limit: 10,
  );

  var result = reverseQuery(point: coordinate, option: option, queryTiles: tiles);

  result.forEach((queryResultFeature) {
    print('id: ${queryResultFeature.feature.id}');
    print('distance: ${queryResultFeature.distance}');
    print('id: ${queryResultFeature.geoJson.geometry.type}');
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
  });
}

main() {
  reverseGeocoding();  
  // pointInPolygon();
}

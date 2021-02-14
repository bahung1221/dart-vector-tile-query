import 'package:meta/meta.dart';
import 'package:vector_tile/vector_tile.dart';
import 'package:vector_tile_query/util/bbox.dart';

bool pointInPolygon({
  @required List<double> point,
  @required GeoJson geoJson,
}) {
  if (
    !(geoJson.geometry is GeometryPolygon) &&
    !(geoJson.geometry is GeometryMultiPolygon)
  ) {
    return false;
  }

  List<double> bbox = getbbox(geoJson: geoJson);
  if (!pointInBBox(point: point, bbox: bbox)) {
    return false;
  }

  // normalize to multipolygon
  List<List<List<List<double>>>> polygons = [];
  if (geoJson.geometry is GeometryMultiPolygon) {
    polygons = (geoJson.geometry as GeometryMultiPolygon).coordinates;
  } else {
    polygons = [(geoJson.geometry as GeometryPolygon).coordinates];
  }

  bool insidePoly = false;
  for (int i = 0; i < polygons.length && !insidePoly; i++) {
    // check if it is in the outer ring first
    if (pointInRing(point: point, ring: polygons[i][0])) {
      bool inHole = false;
      int k = 1;
      // check for the point in any of the holes
      while (k < polygons[i].length && !inHole) {
        if (pointInRing(point: point, ring: polygons[i][k])) {
          inHole = true;
        }
        k++;
      }
      if (!inHole) {
        insidePoly = true;
      }
    }
  }

  return insidePoly;
}

bool pointInRing({
  @required List<double> point,
  @required List<List<double>> ring,
}) {
  bool isInside = false;

  if (
    ring[0][0] == ring[ring.length - 1][0] &&
    ring[0][1] == ring[ring.length - 1][1]
  ) {
    ring = ring.sublist(0, ring.length - 1);
  }

  for (int i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    double xi = ring[i][0];
    double yi = ring[i][1];
    double xj = ring[j][0];
    double yj = ring[j][1];

    bool onBoundary =
      point[1] * (xi - xj) + yi * (xj - point[0]) + yj * (point[0] - xi) == 0 &&
      (xi - point[0]) * (xj - point[0]) <= 0 &&
      (yi - point[1]) * (yj - point[1]) <= 0;

    if (onBoundary) {
      return true;
    }

    bool isIntersect =
      yi > point[1] != yj > point[1] &&
      point[0] < ((xj - xi) * (point[1] - yi)) / (yj - yi) + xi;
    if (isIntersect) {
      isInside = !isInside;
    }
  }

  return isInside;
}

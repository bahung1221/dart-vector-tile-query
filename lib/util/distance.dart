import 'dart:math';
import 'package:meta/meta.dart';
import 'package:vector_tile/util/geojson.dart';
import 'package:vector_tile_query/util/constant.dart';
import 'package:vector_tile_query/util/segment.dart';

/// Converts an angle in degrees to radians
///
/// @param degree: angle between 0 and 360 degrees
/// @return angle in radians
double degreeToRadian({@required double degree}) {
  double radian = degree % 360;
  return (radian * pi) / 180;
}

/// Convert a distance measurement (assuming a spherical Earth) from radians to a more friendly unit.
/// 
/// @param radian: in radians across the sphere
/// @param unit: output unit
/// 
/// @return distance
double radianToLength({@required double radian, Unit unit = Unit.Meters}) {
  return factors[unit] * radian;
}

/// Calculates the distance between two points in degrees.
/// This uses the [Haversine formula](http://en.wikipedia.org/wiki/Haversine_formula) to account for global curvature.
///
/// @param from: origin point
/// @param to: destination point
/// @param unit: output distance unit
/// 
/// @return distance between the two points
double pointToPointDistance({
  @required List<double> from, 
  @required List<double> to, 
  Unit unit = Unit.Meters
}) {
  double dLat = degreeToRadian(degree: to[1] - from[1]);
  double dLon = degreeToRadian(degree: to[0] - from[0]);
  double lat1 = degreeToRadian(degree: from[1]);
  double lat2 = degreeToRadian(degree: to[1]);

  double a =
    pow(sin(dLat / 2), 2) +
    pow(sin(dLon / 2), 2) * cos(lat1) * cos(lat2);

  return radianToLength(
    radian: 2 * atan2(sqrt(a), sqrt(1 - a)),
    unit: unit,
  );
}

/// Returns the minimum distance between a Point and a LineString or Polygon, 
/// being the distance from a line the minimum distance between the point 
/// and any segment of the `LineString`/`Polygon`.
/// 
/// @param point: point
/// @param geoJson (Multi)LineString or (Multi)Polygon GeoJSON
/// @returns {double} distance between point and line
double pointToLineOrPolygonDistance({
  @required List<double> point,
  @required GeoJson geoJson,
  Unit unit = Unit.Meters
}) {
  double distance = double.infinity;

  segmentEach(
    geoJson: geoJson,
    callback: ({List<List<double>> segment}) {
      double curDistance = pointToSegmentDistance(
        point: point,
        segment: segment,
        unit: unit
      );
      if (curDistance < distance) {
        distance = curDistance;
      }
      return false;
    }
  );

  return distance;
}

/// A implementation of theory by Paul Bourke.
/// https://stackoverflow.com/a/6853926/8127805
/// 
/// @returns the distance between a point P on a segment AB.
double pointToSegmentDistance({
  @required List<double> point,
  @required List<List<double>> segment,
  Unit unit = Unit.Meters
}) {
  if (segment.length != 2) return double.infinity;

  List<double> a = segment[0];
  List<double> b = segment[1];

  List<double> v = [b[0] - a[0], b[1] - a[1]];
  List<double> w = [point[0] - a[0], point[1] - a[1]];

  double c1 = dot(w, v);
  if (c1 <= 0) {
    return pointToPointDistance(from: point, to: a);
  }

  double c2 = dot(v, v);
  if (c2 <= c1) {
    return pointToPointDistance(from: point, to: b);
  }

  double b2 = c1 / c2;
  List<double> pb = [a[0] + b2 * v[0], a[1] + b2 * v[1]];

  return pointToPointDistance(
    from: point, 
    to: pb,
    unit: unit,
  );
}

double dot(List<double> u, List<double> v) {
  return u[0] * v[0] + u[1] * v[1];
}

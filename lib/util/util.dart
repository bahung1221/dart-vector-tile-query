import 'dart:math';

import 'package:meta/meta.dart';

final double earthRadius = 6371008.8;

enum Unit {
  Centimeters, Degrees, Feet, Inches, Kilometers, Meters, 
  Miles, Millimeters, Nauticalmiles, Radians, Yards
}

final Map<Unit, double> factors = {
  Unit.Centimeters: earthRadius * 100,
  Unit.Degrees: earthRadius / 111325,
  Unit.Feet: earthRadius * 3.28084,
  Unit.Inches: earthRadius * 39.37,
  Unit.Kilometers: earthRadius / 1000,
  Unit.Meters: earthRadius,
  Unit.Miles: earthRadius / 1609.344,
  Unit.Millimeters: earthRadius * 1000,
  Unit.Nauticalmiles: earthRadius / 1852,
  Unit.Radians: 1,
  Unit.Yards: earthRadius / 1.0936,
};

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

/**
 * Calculates the distance between two {@link Point|points} in degrees, radians, miles, or kilometers.
 * This uses the [Haversine formula](http://en.wikipedia.org/wiki/Haversine_formula) to account for global curvature.
 *
 * @param from: origin point
 * @param to: destination point
 * @param unit: output distance unit
 * 
 * @return distance between the two points
 */
double distance({
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


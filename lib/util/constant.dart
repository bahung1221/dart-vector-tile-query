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

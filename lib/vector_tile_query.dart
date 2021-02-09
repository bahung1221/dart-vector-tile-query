import 'package:meta/meta.dart';
import 'package:vector_tile/vector_tile.dart';

export 'package:vector_tile/vector_tile.dart' show VectorTile;

class LatLng {
  double lat;
  double lng;
  LatLng({
    @required this.lat, 
    @required this.lng
  });
}

class QueryOption {
  String layer;
  int radius;
  QueryOption({
    this.radius, 
    this.layer
  });
}

String reverseQuery({@required LatLng point, @required List<VectorTile> tiles, @required QueryOption option}) {
  // TODO
}

import 'dart:math';

import 'package:objectbox/objectbox.dart';

@Entity()
class GeoData {
  @Id()
  int id = 0;

  double lat;
  double lon;

  GeoData({
    required this.lat,
    required this.lon,
  });

  /** Ungetestet */
  double getDistanceTo(double pos_lat, double pos_lon) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((pos_lat - lat) * p)/2 +
        c(lat * p) * c(pos_lat * p) *
            (1 - c((pos_lon - lon) * p))/2;
    return 12742 * asin(sqrt(a));
  }
}
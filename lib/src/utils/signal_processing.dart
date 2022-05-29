import 'dart:math' as math;
import 'package:tuple/tuple.dart';

// 0 - parado, 1 - en movimiento

// int lastStateIsChangePoint(List<int> states, List<int> changePointsIndexes) {
//   int changePoint = states[states.length - 1] - states[states.length - 2];
//   if (changePoint != 0) {
//     return states.length - 1;
//   }
//   else {
//     return -1;
//   }
// }

// bool detectMotion(List<int> _states, double oldXAccelX, double oldXAccelY, double oldXAccelZ,
//     double newXAccelX, double newXAccelY, double newXAccelZ) {

//   int threshold = 2;
//   if (oldXAccelY != newXAccelY) {
//     if (_states[_states.length - 1] == 0) {
//       if (newXAccelY - oldXAccelY > threshold || newXAccelY - oldXAccelY < -threshold) {
//         return true;
//       }
//       return false;
//     }

//     else {
//       if (newXAccelY - oldXAccelY > threshold || newXAccelY - oldXAccelY < -threshold) {
//         return false;
//       }
//       return true;
//     }
//   }
//   return false;
// }

bool scanPotholes(double prevAccelX, double prevAccelY, double prevAccelZ,
    double currAccelX, double currAccelY, double currAccelZ) {
  return zThresh(currAccelZ) || zDiff(prevAccelZ, currAccelZ);
}

List<double>biAxialLowpassFilter( prevLat, prevLong, currLat, currLong) {
  const double smoothingParam = 0.9;

  //Low-Pass Filter
  double filteredLat =
      (currLat * smoothingParam) + prevLat * (1 - smoothingParam);
  double filteredLong =
      (currLong * smoothingParam) + prevLong * (1 - smoothingParam);

  filteredLat = double.parse(filteredLat.toStringAsPrecision(9));
  filteredLong = double.parse(filteredLong.toStringAsPrecision(9));

  return [filteredLat, filteredLong];
}

List<double> triAxialHighpassFilter(double prevReadX, double prevReadY,
    double prevReadZ, double currReadX, double currReadY, double currReadZ) {
  const double smoothingParam = 0.8;

  //Low-Pass Filter
  double filteredReadX =
      (currReadX * smoothingParam) + prevReadX * (1 - smoothingParam);
  double filteredReadY =
      (currReadY * smoothingParam) + prevReadY * (1 - smoothingParam);
  double filteredReadZ =
      (currReadZ * smoothingParam) + prevReadZ * (1 - smoothingParam);

  // High-Pass Filter
  filteredReadX =
      double.parse((currReadX - filteredReadX).toStringAsPrecision(6));
  filteredReadY =
      double.parse((currReadY - filteredReadY).toStringAsPrecision(6));
  filteredReadZ =
      double.parse((currReadZ - filteredReadZ).toStringAsPrecision(6));

  return [filteredReadX, filteredReadY, filteredReadZ];
}

// Calcular la distancia entre dos coordenadas de latitud-longitud
double computeSpeed(double prevLat, double prevLong, double currLat,
    double currLong, double timeInterval) {
  // double kineticFormula = prevSpeed + yAccel*timeInterval*3.6;
  // double calibratedSpeed = kineticFormula - slopeMedian;

  // return calibratedSpeed < 0 ? 0 : calibratedSpeed;

  final double distance =
      distanceHaversine(prevLat, prevLong, currLat, currLong);
  return distance / (timeInterval / 3600);
}

// Llevar de grados a radianes
double toRadians(double degree) {
  double oneDeg = (math.pi) / 180;
  return (oneDeg * degree);
}

// Distancia de Haversine
double distanceHaversine(double lat1, double long1, double lat2, double long2) {
  lat1 = toRadians(lat1);
  long1 = toRadians(long1);
  lat2 = toRadians(lat2);
  long2 = toRadians(long2);

  // Radio de La Tierra en KM, R = 6371
  const double earthRadius = 6371;

  // Fórmula de Haversine
  double diffLong = long2 - long1;
  double diffLat = lat2 - lat1;

  double ans = math.pow(math.sin(diffLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(diffLong / 2), 2);

  ans = 2 * earthRadius * math.asin(math.sqrt(ans));

  return ans;
}

// Heurísticas para determinar baches

bool gZero(
  double currAccelX,
  double currAccelY,
  double currAccelZ,
) {
  const double thresh = 10;

  return currAccelX.abs() < thresh &&
      currAccelY.abs() < thresh &&
      currAccelZ.abs() < thresh;
}

bool zThresh(double zAccel) {
  const double threshold = 10;
  return zAccel.abs() > threshold;
}

bool zDiff(double prevAccelZ, double currAccelZ) {
  const double threshold = 10;
  return (currAccelZ - prevAccelZ).abs() > threshold;
}

bool potholePatrol(
    double currSpeed,
    double currAccelX,
    double currAccelY,
    double currAccelZ,
    double prevAccelX,
    double prevAccelY,
    double prevAccelZ) {
  const double speedThresh = 15;
  const double xzAccelRatio = 5;
  const double speedZRatio = 5;

  if (currSpeed < speedThresh ||
      !zThresh(currAccelZ) ||
      currAccelX / currAccelZ < xzAccelRatio ||
      currAccelZ / currSpeed < speedZRatio) {
    return false;
  }

  return true;
}

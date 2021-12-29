import 'dart:math' as math;

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

double computeSpeed(double previousSpeed, double yAccel, double slopeMedian, double timeInterval) {
  double kineticFormula = previousSpeed + yAccel*timeInterval*3.6;
  double calibratedSpeed = kineticFormula - slopeMedian;

  return calibratedSpeed < 0 ? 0 : calibratedSpeed;
}

double toRadians(double degree) {
    double oneDeg = (math.pi) / 180;
    return (oneDeg * degree);
}
 
double distance(double lat1, double long1, double lat2, double long2) {
    lat1 = toRadians(lat1);
    long1 = toRadians(long1);
    lat2 = toRadians(lat2);
    long2 = toRadians(long2);
     
    // Haversine Formula
    double dLong = long2 - long1;
    double dLat = lat2 - lat1;
 
    double ans = math.pow(math.sin(dLat / 2), 2) +
                          math.cos(lat1) * math.cos(lat2) *
                          math.pow(math.sin(dLong / 2), 2);
 
    ans = 2 * math.asin(math.sqrt(ans));
 
    // Radius of Earth in
    // Kilometers, R = 6371
    double earthRadius = 6371;
     
    // Calculate the result
    ans = ans * earthRadius;
 
    return ans;
}

bool zThresh(double zAccel, double threshold) =>
    zAccel.abs() > threshold;

bool zDiff(double zAccelStart, double zAccelEnd, double threshold) => 
  (zAccelEnd - zAccelStart).abs() > threshold;

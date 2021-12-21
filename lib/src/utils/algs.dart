// 0 - parado, 1 - en movimiento

int lastStateIsChangePoint(List<int> states, List<int> changePointsIndexes) {
  int changePoint = states[states.length - 1] - states[states.length - 2];
  if (changePoint != 0) {
    return states.length - 1;
  }
  else {
    return -1;
  }
}

bool detectMotion(List<int> _states, double oldXAccelX, double oldXAccelY, double oldXAccelZ,
    double newXAccelX, double newXAccelY, double newXAccelZ) {

  int threshold = 2;
  if (oldXAccelY != newXAccelY) {
    if (_states[_states.length - 1] == 0) {
      if (newXAccelY - oldXAccelY > threshold || newXAccelY + oldXAccelY < -threshold) {
        return true;
      }
      return false;
    }

    else {
      if (newXAccelY - oldXAccelY < threshold || newXAccelY + oldXAccelY > -threshold) {
        return false;
      }
      return true;
    }
  }
  return false;
}

bool zThresh(double zAccel, double threshold) =>
    zAccel.abs() > threshold;

bool zDiff(double zAccelStart, double zAccelEnd, double threshold) => 
  (zAccelEnd - zAccelStart).abs() > threshold;

double speedEstKinetic(double previousSpeed, double yAccel, double timeInterval) => // Asume aceleración constante, y se expresa en km/h
  previousSpeed + yAccel.abs()*timeInterval*3.6;

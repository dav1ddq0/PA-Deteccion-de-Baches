Map<int, int> sampleRateRanges = {
  0: 20,
  1: 40,
  2: 60,
  3: 80,
  4: 100,
  6: 120,
  7: 140,
  8: 160,
  9: 180
};

double recomputeSamplingRate(int sampleCount, double speed) {
  double newSamplingRate = 1 / 15;
  if (speed < 100) {
    newSamplingRate =
        1 / (sampleCount * (sampleRateRanges[(speed / 10).floor()]!));
  }
  return newSamplingRate;
}

Map<int, int> sampleRateRanges = {
  0: 3,
  1: 6,
  2: 8,
  3: 11,
  4: 14,

  6: 19,
  7: 22,
  8: 25,
  9: 27
};

double recomputeSamplingRate(int sampleCount, double speed) {
  double newSamplingRate = 1 / 15;
  if (speed < 100) {
    newSamplingRate =
        1 / (sampleCount * (sampleRateRanges[(speed / 10).floor()]!));
  }
  return newSamplingRate;
}

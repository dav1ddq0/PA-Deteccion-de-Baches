double recomputeSamplingRate(int sampleCount, double speed) {
  return 1 / (sampleCount * speed / 3.6);
}

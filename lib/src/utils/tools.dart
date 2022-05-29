double recomputeSampleRate(int sampleCount, double velocity) {
  return 1 / (velocity * sampleCount / 3.6);
}

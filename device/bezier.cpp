#include "bezier.hpp"
#include "Arduino.h"

const int NUM_ITERATIONS = 2;

Distance Bezier::sample(Time time)
{
  // find t for given time -- solve f(t) = (1-t)^3 * P0.t + 3(1-t)^2 * t * P1.t + 3(1-t) * t^2 * P2.t + t^3 * P3.t - time
  // derivative: 3(1-t)^2(P1.t - P0.t) + 6(1-t)t(P2.t-P1.t) + 3t^2(P3.t-P2.t)

  uint32_t startMs = start.time.getMilliseconds();
  uint32_t control1Ms = control1.time.getMilliseconds();
  uint32_t control2Ms = control2.time.getMilliseconds();
  uint32_t endMs = end.time.getMilliseconds();
  uint32_t timeMs = time.getMilliseconds();

  Time minTime = start.time;
  Time maxTime = end.time;
  float t0 = (time - minTime) / (maxTime - minTime); // good first guess is just time as percentage

  float t = t0;
  for (int i = 0; i < NUM_ITERATIONS; i++)
  {
    float f = (1 - t) * (1 - t) * (1 - t) * startMs + 3 * (1 - t) * (1 - t) * t * control1Ms + 3 * (1 - t) * t * t * control2Ms + t * t * t * endMs - timeMs;
    float fPrime = 3 * (1 - t) * (1 - t) * (control1Ms - startMs) + 6 * (1 - t) * t * (control2Ms - control1Ms) + 3 * t * t * (endMs - control2Ms);
    t = t - f / fPrime;
  }

  float coef1 = (1 - t) * (1 - t) * (1 - t);
  float coef2 = 3 * (1 - t) * (1 - t) * t;
  float coef3 = 3 * (1 - t) * t * t;
  float coef4 = t * t * t;
  Distance result = coef1 * start.x + coef2 * control1.x + coef3 * control2.x + coef4 * end.x;

  return result;
}

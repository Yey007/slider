#include "bezier.hpp"
#include "Arduino.h"

Distance Bezier::sample(Time time)
{
  // TODO: performance issue here. Bulk of time spent on calculation.
  Time minTime = start.time;
  Time maxTime = end.time;
  float t = (time - minTime) / (maxTime - minTime);

  float coef1 = (1 - t) * (1 - t) * (1 - t);
  float coef2 = 3 * (1 - t) * (1 - t) * t;
  float coef3 = 3 * (1 - t) * t * t;
  float coef4 = t * t * t;
  Distance result = coef1 * start.x + coef2 * control1.x + coef3 * control2.x + coef4 * end.x;

  return result;
}
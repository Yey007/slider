#include "bezier.hpp"
#include <math.h>

Distance Bezier::sample(Time time)
{
  Time minTime = start.time;
  Time maxTime = end.time;
  double t = (time - minTime) / (maxTime - minTime);
  return pow(1 - t, 3) * start.x + 3 * pow(1 - t, 2) * t * control1.x + 3 * (1 - t) * pow(t, 2) * control2.x + pow(t, 3) * end.x;
}
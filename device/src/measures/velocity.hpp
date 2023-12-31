#pragma once
#include "distance.hpp"
#include "time.hpp"

struct Velocity
{
public:
  Velocity(Distance distance, Time time);

  float toMicrostepsPerSecond() const;

private:
  Distance distance;
  Time time;
};

Velocity operator/(const Distance &distance, const Time &time);
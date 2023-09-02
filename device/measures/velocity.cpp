#include "velocity.hpp"

Velocity::Velocity(Distance distance, Time time)
    : distance(distance), time(time)
{
}

float Velocity::getMotorTicksPerSecond() const
{
  return distance.getMotorTicks() / time.getSeconds();
}

Velocity operator/(const Distance &distance, const Time &time)
{
  return Velocity(distance, time);
}
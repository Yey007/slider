#include "velocity.hpp"

Velocity::Velocity(Distance distance, Time time)
    : distance(distance), time(time)
{
}

float Velocity::toMicrostepsPerSecond() const
{
    return distance.toMicrosteps() / time.toSeconds();
}

Velocity operator/(const Distance &distance, const Time &time)
{
    return Velocity(distance, time);
}
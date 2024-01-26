#include "distance.hpp"
#include "../../motor_config.hpp"

Distance Distance::fromCentimeters(float centimeters)
{
    Distance distance;
    distance.microsteps = centimeters * 10 * STEPS_PER_MM;
    return distance;
}

Distance Distance::fromMillimeters(float millimeters)
{
    Distance distance;
    distance.microsteps = millimeters * STEPS_PER_MM;
    return distance;
}

Distance Distance::fromMicrosteps(float ticks)
{
    Distance distance;
    distance.microsteps = ticks;
    return distance;
}

float Distance::toCentimeters() const
{
    return microsteps / STEPS_PER_MM / 10.0;
}

float Distance::toMillimeters() const
{
    return microsteps / STEPS_PER_MM;
}

float Distance::toMicrosteps() const
{
    return microsteps;
}

Distance operator*(const Distance &distance, float scalar)
{
    return Distance::fromMicrosteps(distance.toMicrosteps() * scalar);
}

Distance operator*(float scalar, const Distance &distance)
{
    return distance * scalar;
}

Distance operator+(const Distance &distance1, const Distance &distance2)
{
    return Distance::fromMicrosteps(distance1.toMicrosteps() + distance2.toMicrosteps());
}

Distance operator-(const Distance &distance1, const Distance &distance2)
{
    return Distance::fromMicrosteps(distance1.toMicrosteps() - distance2.toMicrosteps());
}

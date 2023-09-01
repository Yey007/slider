#include "distance.hpp"
#include "motor_config.hpp"

Distance Distance::fromCentimeters(float centimeters)
{
  Distance distance;
  distance.motorTicks = centimeters * 10 * STEPS_PER_MM;
  return distance;
}

Distance Distance::fromMillimeters(float millimeters)
{
  Distance distance;
  distance.motorTicks = millimeters * STEPS_PER_MM;
  return distance;
}

Distance Distance::fromMotorTicks(float ticks)
{
  Distance distance;
  distance.motorTicks = ticks;
  return distance;
}

float Distance::getCentimeters() const
{
  return motorTicks / STEPS_PER_MM / 10.0;
}

float Distance::getMillimeters() const
{
  return motorTicks / STEPS_PER_MM;
}

float Distance::getMotorTicks() const
{
  return motorTicks;
}

Distance operator*(const Distance &distance, float scalar)
{
  return Distance::fromMotorTicks(distance.getMotorTicks() * scalar);
}

Distance operator*(float scalar, const Distance &distance)
{
  return distance * scalar;
}

Distance operator+(const Distance &distance1, const Distance &distance2)
{
  return Distance::fromMotorTicks(distance1.getMotorTicks() + distance2.getMotorTicks());
}
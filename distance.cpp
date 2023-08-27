#include "distance.hpp"
#include "motor_config.hpp"

Distance Distance::fromCentimeters(double centimeters)
{
  Distance distance;
  distance.motorTicks = centimeters * 10 * STEPS_PER_MM;
  return distance;
}

Distance Distance::fromMillimeters(double millimeters)
{
  Distance distance;
  distance.motorTicks = millimeters * STEPS_PER_MM;
  return distance;
}

Distance Distance::fromMotorTicks(double ticks)
{
  Distance distance;
  distance.motorTicks = ticks;
  return distance;
}

double Distance::getCentimeters() const
{
  return motorTicks / STEPS_PER_MM / 10.0;
}

double Distance::getMillimeters() const
{
  return motorTicks / STEPS_PER_MM;
}

double Distance::getMotorTicks() const
{
  return motorTicks;
}

Distance operator*(const Distance &distance, double scalar)
{
  return Distance::fromMotorTicks(distance.getMotorTicks() * scalar);
}

Distance operator*(double scalar, const Distance &distance)
{
  return distance * scalar;
}

Distance operator+(const Distance &distance1, const Distance &distance2)
{
  return Distance::fromMotorTicks(distance1.getMotorTicks() + distance2.getMotorTicks());
}
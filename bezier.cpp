#include "bezier.hpp"
#include "motor_config.hpp"

Time Time::fromSeconds(double seconds)
{
  Time time;
  time.milliseconds = seconds * 1000;
  return time;
}

Time Time::fromMilliseconds(uint32_t milliseconds)
{
  Time time;
  time.milliseconds = milliseconds;
  return time;
}

double Time::getSeconds() const
{
  return milliseconds / 1000.0;
}

uint32_t Time::getMilliseconds() const
{
  return milliseconds;
}

double operator/(const Time &time1, const Time &time2)
{
  return time1.getMilliseconds() / (double)time2.getMilliseconds();
}

Time operator-(const Time &time1, const Time &time2)
{
  if (time1.getMilliseconds() < time2.getMilliseconds())
  {
    Serial.println("Subtracting times out of order. This is not good!");
  }

  return Time::fromMilliseconds(time1.getMilliseconds() - time2.getMilliseconds());
}

Distance Distance::fromCentimeters(double centimeters)
{
  Distance distance;
  distance.millimeters = centimeters * 10;
  return distance;
}

Distance Distance::fromMillimeters(uint32_t millimeters)
{
  Distance distance;
  distance.millimeters = millimeters;
  return distance;
}

Distance Distance::fromMotorTicks(uint32_t ticks)
{
  Distance distance;
  distance.millimeters = MM_PER_STEP * ticks;
  return distance;
}

double Distance::getCentimeters() const
{
  return millimeters / 10.0;
}

uint32_t Distance::getMillimeters() const
{
  return millimeters;
}

uint32_t Distance::getMotorTicks() const
{
  return millimeters / MM_PER_STEP;
}

Distance operator*(const Distance &distance, double scalar)
{
  return Distance::fromMillimeters(distance.getMillimeters() * scalar);
}

Distance operator*(double scalar, const Distance &distance)
{
  return distance * scalar;
}

Distance operator+(const Distance &distance1, const Distance &distance2)
{
  return Distance::fromMillimeters(distance1.getMillimeters() + distance2.getMillimeters());
}

Distance Bezier::sample(Time time)
{
  Time minTime = start.time;
  Time maxTime = end.time;
  double t = (time - minTime) / (maxTime - minTime);
  return pow(1 - t, 3) * start.x + 3 * pow(1 - t, 2) * t * control1.x + 3 * (1 - t) * pow(t, 2) * control2.x + pow(t, 3) * end.x;
}
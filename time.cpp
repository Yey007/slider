#include "time.hpp"

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

Time Time::now()
{
  Time time;
  time.milliseconds = millis();
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
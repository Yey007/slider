#include "time.hpp"
#include "Arduino.h"

float Time::baseline = 0;

Time Time::fromSeconds(float seconds)
{
  Time time;
  time.milliseconds = seconds * 1000;
  return time;
}

Time Time::fromMilliseconds(float milliseconds)
{
  Time time;
  time.milliseconds = milliseconds;
  return time;
}

Time Time::now()
{
  Time time;
  time.milliseconds = millis() - baseline;
  return time;
}

void Time::reset()
{
  baseline = millis();
}

float Time::toSeconds() const
{
  return milliseconds / 1000.0;
}

float Time::toMilliseconds() const
{
  return milliseconds;
}

float operator/(const Time &time1, const Time &time2)
{
  return time1.toMilliseconds() / (float)time2.toMilliseconds();
}

Time operator+(const Time &time1, const Time &time2)
{
  return Time::fromMilliseconds(time1.toMilliseconds() + time2.toMilliseconds());
}

Time operator-(const Time &time1, const Time &time2)
{
  return Time::fromMilliseconds(time1.toMilliseconds() - time2.toMilliseconds());
}

Time operator*(const Time &time, float scalar)
{
  return Time::fromMilliseconds(time.toMilliseconds() * scalar);
}

Time operator*(float scalar, const Time &time)
{
  return time * scalar;
}

bool operator<(const Time &time1, const Time &time2)
{
  return time1.toMilliseconds() < time2.toMilliseconds();
}

bool operator>(const Time &time1, const Time &time2)
{
  return time1.toMilliseconds() > time2.toMilliseconds();
}
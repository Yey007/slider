#pragma once

struct Time
{
public:
  static Time fromSeconds(double seconds);
  static Time fromMilliseconds(uint32_t milliseconds);
  static Time now();

  double getSeconds() const;
  uint32_t getMilliseconds() const;

private:
  uint32_t milliseconds;
};

double operator/(const Time &time1, const Time &time2);
Time operator-(const Time &time1, const Time &time2);

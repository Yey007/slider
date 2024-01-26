#pragma once
#include <stdint.h>

struct Time
{
public:
    static Time fromSeconds(float seconds);
    static Time fromMilliseconds(float milliseconds);
    static Time now();
    static void reset();

    float toSeconds() const;
    float toMilliseconds() const;

private:
    float milliseconds;
    static float baseline;
};

float operator/(const Time &time1, const Time &time2);
Time operator+(const Time &time1, const Time &time2);
Time operator-(const Time &time1, const Time &time2);
Time operator*(const Time &time, float scalar);
Time operator*(float scalar, const Time &time);
bool operator<(const Time &time1, const Time &time2);
bool operator>(const Time &time1, const Time &time2);

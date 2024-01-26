#include "bezier.hpp"
#include "Arduino.h"

const int NUM_ITERATIONS = 2;

float Bezier::getT(Time time)
{
    // find t for given time -- solve time = (1-t)^3 * P0.t + 3(1-t)^2 * t * P1.t + 3(1-t) * t^2 * P2.t + t^3 * P3.t
    // derivative: 3(1-t)^2(P1.t - P0.t) + 6(1-t)t(P2.t-P1.t) + 3t^2(P3.t-P2.t)

    Time minTime = start.time;
    Time maxTime = end.time;
    float t0 = (time - minTime) / (maxTime - minTime); // good first guess is just time as percentage

    float t = t0;
    for (int i = 0; i < NUM_ITERATIONS; i++)
    {
        Time f = (1 - t) * (1 - t) * (1 - t) * start.time + 3 * (1 - t) * (1 - t) * t * control1.time + 3 * (1 - t) * t * t * control2.time + t * t * t * end.time - time;
        Time fPrime = 3 * (1 - t) * (1 - t) * (control1.time - start.time) + 6 * (1 - t) * t * (control2.time - control1.time) + 3 * t * t * (end.time - control2.time);
        t = t - f / fPrime;
    }

    return t;
}

Distance Bezier::sample(Time time)
{
    float t = getT(time);

    float coef1 = (1 - t) * (1 - t) * (1 - t);
    float coef2 = 3 * (1 - t) * (1 - t) * t;
    float coef3 = 3 * (1 - t) * t * t;
    float coef4 = t * t * t;

    return coef1 * start.x + coef2 * control1.x + coef3 * control2.x + coef4 * end.x;
}

Velocity Bezier::sampleVelocity(Time time)
{
    float t = getT(time);

    float coef1 = 3 * (1 - t) * (1 - t);
    float coef2 = 6 * (1 - t) * t;
    float coef3 = 3 * t * t;

    return (coef1 * (control1.x - start.x) +
            coef2 * (control2.x - control1.x) +
            coef3 * (end.x - control2.x)) /
           Time::fromSeconds(1); // TODO: per seconds? what are the real units here?
}

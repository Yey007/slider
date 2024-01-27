#include "bezier.hpp"

Distance Bezier::sample(Time time)
{
    float t = time / (end.time - start.time);
    float oneMinus = 1 - t;

    Distance dist =
        start.x * oneMinus * oneMinus * oneMinus +
        3 * control1 * oneMinus * oneMinus * t +
        3 * control2 * oneMinus * t * t +
        end.x * t * t * t;

    return dist;
}

#pragma once
#include <stdint.h>

struct Distance
{
public:
  static Distance fromCentimeters(float centimeters);
  static Distance fromMillimeters(float millimeters);
  static Distance fromMicrosteps(float ticks);

  float toCentimeters() const;
  float toMillimeters() const;
  float toMicrosteps() const;

private:
  float microsteps;
};

Distance operator*(const Distance &distance, float scalar);
Distance operator*(float scalar, const Distance &distance);
Distance operator+(const Distance &distance1, const Distance &distance2);
Distance operator-(const Distance &distance1, const Distance &distance2);

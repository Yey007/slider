#include <stdint.h>

struct Distance
{
public:
  static Distance fromCentimeters(float centimeters);
  static Distance fromMillimeters(float millimeters);
  static Distance fromMotorTicks(float ticks);

  float getCentimeters() const;
  float getMillimeters() const;
  float getMotorTicks() const;

private:
  float motorTicks;
};

Distance operator*(const Distance &distance, float scalar);
Distance operator*(float scalar, const Distance &distance);
Distance operator+(const Distance &distance1, const Distance &distance2);

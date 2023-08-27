#include <stdint.h>

struct Distance
{
public:
  static Distance fromCentimeters(double centimeters);
  static Distance fromMillimeters(double millimeters);
  static Distance fromMotorTicks(double ticks);

  double getCentimeters() const;
  double getMillimeters() const;
  double getMotorTicks() const;

private:
  double motorTicks;
};

Distance operator*(const Distance &distance, double scalar);
Distance operator*(double scalar, const Distance &distance);
Distance operator+(const Distance &distance1, const Distance &distance2);

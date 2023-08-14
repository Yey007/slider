struct Distance
{
public:
  static Distance fromCentimeters(double centimeters);
  static Distance fromMillimeters(uint32_t millimeters);
  static Distance fromMotorTicks(uint32_t ticks);

  double getCentimeters() const;
  uint32_t getMillimeters() const;
  uint32_t getMotorTicks() const;

private:
  uint32_t millimeters;
};

Distance operator*(const Distance &distance, double scalar);
Distance operator*(double scalar, const Distance &distance);
Distance operator+(const Distance &distance1, const Distance &distance2);

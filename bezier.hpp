struct Time
{
public:
  static Time fromSeconds(double seconds);
  static Time fromMilliseconds(uint32_t milliseconds);

  double getSeconds() const;
  uint32_t getMilliseconds() const;

private:
  uint32_t milliseconds;
};

double operator/(const Time &time1, const Time &time2);
Time operator-(const Time &time1, const Time &time2);

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

struct BezierPoint
{
public:
  Distance x;
  Time time;
};

struct Bezier
{
public:
  BezierPoint start, control1, control2, end;

  Distance sample(Time time);
};

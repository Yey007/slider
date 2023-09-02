#include "motor_config.hpp"
#include "src/measures/time.hpp"
#include "bezier.hpp"
#include <stdint.h>
#include <math.h>
#include <TMCStepper.h>

#define STEP_PIN 2
#define DIR_PIN 3
#define EN_PIN 8
#define RX_PIN 7
#define TX_PIN 6

#define R_SENSE 0.15f

TMC2208Stepper driver = TMC2208Stepper(RX_PIN, TX_PIN, R_SENSE);

void setup()
{
  Serial.begin(115200);

  pinMode(EN_PIN, OUTPUT);
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  digitalWrite(EN_PIN, LOW); // Enable driver in hardware

  driver.beginSerial(115200); // SW UART drivers

  driver.begin(); //  SPI: Init CS pins and possible SW SPI pins
                  // UART: Init SW UART (if selected) with default 115200 baudrate
  driver.toff(5); // Enables driver in software
  driver.rms_current(600);
  driver.microsteps(MICROSTEPS == 1 ? 0 : MICROSTEPS); // Weird API makes this ugly

  driver.pwm_autoscale(true); // Needed for stealthChop

  driver.dedge(true); // double edge

  uint16_t ms = driver.microsteps();
  Serial.print("Microsteps: ");
  Serial.println(ms);

  // TODO: figure out why vactual < 2000 doesn't spin the motor at all (maybe to do with current?)
  driver.VACTUAL(0);

  // Time::reset();

  // Bezier curve = Bezier(
  //     BezierPoint(Distance::fromCentimeters(0), Time::fromMilliseconds(0)),
  //     BezierPoint(Distance::fromCentimeters(0), Time::fromMilliseconds(1000)),
  //     BezierPoint(Distance::fromCentimeters(10), Time::fromMilliseconds(2000)),
  //     BezierPoint(Distance::fromCentimeters(10), Time::fromMilliseconds(3000)));

  // run(curve);
}

void loop()
{
}

int64_t currentTicks = 0;
bool currentStep = LOW;
bool previousReverse = false;

// TODO: we should really figure out what we wanna do in terms of torque control.
// Maybe we should load the profile onto the Arduino or the app or something,
// so we can check what motions are really possible and what motions are not. Though
// that might require knowing the load in more detail. We can deal with this later.
void run(Bezier curve)
{
  while (true)
  {
    Time now = Time::now();

    if (now > curve.end.time)
    {
      return;
    }

    Distance sample = curve.sample(now);
    uint32_t targetPosition = sample.getMotorTicks();

    if (abs(targetPosition - currentTicks) > 1)
    {
      // TODO: It seems like we can't generate step pulses fast enough to keep up with basic curves.
      // We need to optimize, reduce microsteps, or figure something else out.
      // Ideas for optimization: lookup table instead of on the fly curve computation (most likely to help, but there may be memory restrictions)
      // PWM for pulse generation? Frequency is a constant 980Hz tho so will that work?

      // Serial.println("Can't keep up! More than a tick behind per iteration.");
    }

    bool reverse = targetPosition < currentTicks;
    digitalWrite(DIR_PIN, reverse);

    currentStep = !currentStep;
    digitalWrite(STEP_PIN, currentStep);

    currentTicks += reverse ? -1 : 1;
  }
}

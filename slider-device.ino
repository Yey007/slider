#include "motor_config.hpp"
#include "bezier.hpp"
#include <stdint.h>
#include <math.h>
#include <TMCStepper.h>

#define STEP_PIN 2
#define DIR_PIN 3
#define EN_PIN 8
#define RX_PIN 7
#define TX_PIN 6

#define R_SENSE 0.11f

TMC2208Stepper driver = TMC2208Stepper(RX_PIN, TX_PIN, R_SENSE);

void setup()
{
  Serial.begin(115200);

  pinMode(EN_PIN, OUTPUT);
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  digitalWrite(EN_PIN, LOW); // Enable driver in hardware

  driver.beginSerial(115200); // SW UART drivers

  driver.begin();          //  SPI: Init CS pins and possible SW SPI pins
                           // UART: Init SW UART (if selected) with default 115200 baudrate
  driver.toff(5);          // Enables driver in software
  driver.rms_current(600); // Set motor RMS current
  driver.microsteps(128);  // Set microsteps to 1/16th

  driver.en_spreadCycle(false); // Toggle spreadCycle on TMC2208/2209/2224
  driver.pwm_autoscale(true);   // Needed for stealthChop

  uint16_t ms = driver.microsteps();
  Serial.print("Microsteps: ");
  Serial.println(ms);

  for (int i = 0; i < 1000; i++)
  {
    digitalWrite(STEP_PIN, HIGH);
    delayMicroseconds(1000);
    digitalWrite(STEP_PIN, LOW);
    delayMicroseconds(1000);
  }

  // Time::reset();
  // Bezier curve = Bezier(
  //     BezierPoint(Distance::fromMotorTicks(0), Time::fromMilliseconds(0)),
  //     BezierPoint(Distance::fromMotorTicks(0), Time::fromMilliseconds(1000)),
  //     BezierPoint(Distance::fromMotorTicks(1000), Time::fromMilliseconds(2000)),
  //     BezierPoint(Distance::fromMotorTicks(1000), Time::fromMilliseconds(3000)));
  // run(curve);
}

int steps = 0;

void loop()
{
  // digitalWrite(STEP_PIN, HIGH);
  // delayMicroseconds(1000);
  // digitalWrite(STEP_PIN, LOW);
  // delayMicroseconds(1000);
  // Serial.println(steps++);
}

uint32_t currentTicks = 0;

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

    int64_t targetPosition = curve.sample(now).getMotorTicks();

    if (abs(targetPosition - currentTicks) > 1)
    {
      Serial.println("Can't keep up! More than a tick behind per iteration.");
    }

    if (targetPosition < currentTicks)
    {
      digitalWrite(DIR_PIN, HIGH);
      // Required delays are on the order of nanoseconds,
      // so this should be plenty without influencing performance much.
      delayMicroseconds(100);

      digitalWrite(STEP_PIN, HIGH);
      delayMicroseconds(100);
      digitalWrite(STEP_PIN, LOW);
    }
    else if (targetPosition > currentTicks)
    {
      digitalWrite(DIR_PIN, LOW);
      delayMicroseconds(100);

      digitalWrite(STEP_PIN, HIGH);
      delayMicroseconds(100);
      digitalWrite(STEP_PIN, LOW);
    }
  }
}

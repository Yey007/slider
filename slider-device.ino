#include <TMC2208Stepper.h>
#include "motor_config.hpp"
#include "bezier.hpp"
#include <stdint.h>
#include <math.h>

#define STEP_PIN 2
#define DIR_PIN 3
#define EN_PIN 8
#define RX_PIN 7
#define TX_PIN 6

TMC2208Stepper driver = TMC2208Stepper(RX_PIN, TX_PIN);

void setup()
{
  Serial.begin(115200);
  driver.beginSerial(115200);
  // Push at the start of setting up the driver resets the register to default
  driver.push();

  pinMode(EN_PIN, OUTPUT);
  pinMode(STEP_PIN, OUTPUT);
  digitalWrite(EN_PIN, HIGH); // Disable driver in hardware

  driver.pdn_disable(true);     // Use PDN/UART pin for communication
  driver.I_scale_analog(false); // Use internal voltage reference
  driver.rms_current(500);      // Set driver current 500mA
  driver.toff(2);               // Enable driver in software

  digitalWrite(EN_PIN, LOW); // Enable driver in hardware

  driver.microsteps(MICROSTEPS);
  driver.push();

  uint8_t conn = driver.test_connection();
  Serial.print("Connection: ");
  Serial.println(conn);

  uint16_t ms = driver.microsteps();
  Serial.print("Microsteps: ");
  Serial.println(ms);

  uint32_t data = 0;
  Serial.print("DRV_STATUS = 0x");
  driver.DRV_STATUS(&data);
  Serial.println(data, HEX);
}

void loop()
{
  digitalWrite(STEP_PIN, !digitalRead(STEP_PIN));
  delayMicroseconds(100);
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
      delayMicroseconds(1);

      digitalWrite(STEP_PIN, HIGH);
      delayMicroseconds(1);
      digitalWrite(STEP_PIN, LOW);
    }
    else if (targetPosition > currentTicks)
    {
      digitalWrite(DIR_PIN, LOW);
      delayMicroseconds(1);

      digitalWrite(STEP_PIN, HIGH);
      delayMicroseconds(1);
      digitalWrite(STEP_PIN, LOW);
    }
  }
}

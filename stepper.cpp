#include <Arduino.h>
#include "crc.hpp"
#include "stepper.hpp"

// this should really be like, 100ns but we can't really do that
const uint8_t STEP_MIN_HIGH_TIME_MICROSECONDS = 1;
const uint8_t STEP_MIN_LOW_TIME_MICROSECONDS = 1;
const uint32_t UART_BAUD_RATE = 9600;
const uint32_t UART_PULSE_WIDTH_MICROSECONDS = 1000000 / UART_BAUD_RATE;
const uint8_t READ_MAX_ATTEMPTS = 3;
const uint8_t READ_TIMEOUT_MILLISECONDS = 100;

Stepper::Stepper(uint8_t stepPin, uint8_t dirPin, uint8_t uartTxPin, uint8_t uartRxPin)
{
  m_stepPin = stepPin;
  m_dirPin = dirPin;
  m_uartTxPin = uartTxPin;
  m_uartRxPin = uartRxPin;

  pinMode(m_stepPin, OUTPUT);
  pinMode(m_dirPin, OUTPUT);
  pinMode(m_uartTxPin, OUTPUT);
  pinMode(m_uartRxPin, INPUT);

  // Idle state for UART must be high
  digitalWrite(m_uartTxPin, HIGH);

  setDirection(CLOCKWISE);
}

void Stepper::step()
{
  digitalWrite(m_stepPin, HIGH);
  _delay_us(STEP_MIN_HIGH_TIME_MICROSECONDS);
  digitalWrite(m_stepPin, LOW);
  _delay_us(STEP_MIN_LOW_TIME_MICROSECONDS);
}

// so TECHNICALLY there are some minimum times between steps and changing direction
// but it's on the order of nanoseconds so it doesn't really matter
// needs be we add some delays to this function
void Stepper::setDirection(Direction direction)
{
  digitalWrite(m_dirPin, direction);
}

bool Stepper::setMicrosteps(MicrostepMode mode)
{
  // read current config
  bool success = false;
  uint32_t chop_conf = read_register(Register::CHOPCONF, &success);

  if (!success)
  {
    return false;
  }

  uint32_t bitmask = ~(0b1111 << 24);
  chop_conf &= bitmask; // clear microstep bits
  chop_conf |= mode << 24;

  write_register(Register::CHOPCONF, chop_conf);

  return true;
}

void Stepper::write_register(Register address, uint32_t value)
{
  size_t length = 8;
  uint8_t packet[length];

  // these may look reversed but it's because LSB goes first
  packet[0] = 0b00000101;           // sync + reserved
  packet[1] = 0;                    // slave address (unused for TMC22XX)
  packet[2] = address | 0b10000000; // address + write. address should never have the highest bit set

  // why not just reinterpret_cast? because this guarantees the correct byte order.
  // https://stackoverflow.com/questions/16008879/how-do-you-write-portably-reverse-network-byte-order
  packet[3] = (value >> 24) & 0xFF;
  packet[4] = (value >> 16) & 0xFF;
  packet[5] = (value >> 8) & 0xFF;
  packet[6] = (value >> 0) & 0xFF;

  packet[7] = calc_crc(packet, length - 1);

  send(packet, length);
}

uint32_t Stepper::read_register(Register address, bool *success)
{
  uint32_t result = 0;
  uint8_t attempts = 0;

  do
  {
    read_register_request(address);
    result = read_register_response(success);
    attempts++;
    // minimum wait of 12 bit times between failures (a little more for good measure)
    _delay_us(UART_PULSE_WIDTH_MICROSECONDS * 16);
  } while (!*success && attempts < READ_MAX_ATTEMPTS);

  return result;
}

void Stepper::read_register_request(Register address)
{
  size_t length = 4;
  uint8_t packet[length];

  packet[0] = 0b00000101; // sync + reserved
  packet[1] = 0;          // slave address
  packet[2] = address;    // address + read. highest bit will always be zero (indicates read)
  packet[3] = calc_crc(packet, length - 1);

  send(packet, length);
}

uint32_t Stepper::read_register_response(bool *success)
{
  size_t length = 8;
  uint8_t packet[length];

  *success = receive(packet, length);
  if (!*success)
  {
    return 0;
  }

  if (!verify_crc(packet, length - 1, packet[length - 1]))
  {
    Serial.println("CRC mismatch");
    *success = false;
    return 0;
  }

  uint32_t result = 0;
  result |= packet[3] << 24;
  result |= packet[4] << 16;
  result |= packet[5] << 8;
  result |= packet[6];

  return result;
}

void Stepper::send(uint8_t packet[], size_t length)
{
  for (size_t i = 0; i < length; i++)
  {
    send_bit(LOW); // start bit

    // data bits, LSB to MSB
    for (uint8_t j = 0; j < 8; j++)
    {
      uint8_t bit = (packet[i] >> j) & 0b00000001;
      send_bit(bit);
    }

    send_bit(HIGH); // stop bit
  }
  send_bit(HIGH); // delay ok here?
  Serial.println();
}

void Stepper::send_bit(uint8_t bit)
{
  digitalWrite(m_uartTxPin, bit);
  Serial.print(bit);
  _delay_us(UART_PULSE_WIDTH_MICROSECONDS);
}

bool Stepper::receive(uint8_t packet[], size_t length)
{
  for (size_t i = 0; i < length; i++)
  {
    uint8_t byte = 0;

    // wait for start bit
    uint32_t start = millis();
    while (true)
    {
      if (digitalRead(m_uartRxPin) == LOW)
      {
        break;
      }

      if (millis() - start > READ_TIMEOUT_MILLISECONDS)
      {
        Serial.println("start bit timeout");
        return false;
      }

      _delay_us(10);
    }
    _delay_us(UART_PULSE_WIDTH_MICROSECONDS);
    Serial.println("start bit found");

    for (uint8_t j = 0; j < 8; j++)
    {
      uint8_t bit = receive_bit();
      byte |= bit << j; // LSB comes first
    }
    packet[i] = byte;
    Serial.println("byte received");

    // wait for stop bit
    start = millis();
    while (true)
    {
      if (digitalRead(m_uartRxPin) == HIGH)
      {
        break;
      }

      if (millis() - start > READ_TIMEOUT_MILLISECONDS)
      {
        Serial.println("stop bit timeout");
        return false;
      }

      _delay_us(10);
    }
    _delay_us(UART_PULSE_WIDTH_MICROSECONDS);
    Serial.println("stop bit found");
  }

  return true;
}

uint8_t Stepper::receive_bit()
{
  uint8_t bit = digitalRead(m_uartTxPin);
  _delay_us(UART_PULSE_WIDTH_MICROSECONDS);
  return bit;
}

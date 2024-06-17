#include <Arduino.h>
#include "rgb.hpp"

namespace rgb
{
    void initLED()
    {
        pinMode(LED_RED, OUTPUT);
        pinMode(LED_GREEN, OUTPUT);
        pinMode(LED_BLUE, OUTPUT);

        digitalWrite(LED_RED, HIGH);
        digitalWrite(LED_GREEN, HIGH);
        digitalWrite(LED_BLUE, HIGH);
    }

    void setLEDColor(uint8_t red, uint8_t green, uint8_t blue)
    {
        analogWrite(LED_RED, 256 - red);
        analogWrite(LED_GREEN, 256 - green);
        analogWrite(LED_BLUE, 256 - blue);
    }

    void setLEDColor(LEDColor color)
    {
        switch (color)
        {
        case LEDColor::RED:
            setLEDColor(255, 0, 0);
            break;
        case LEDColor::GREEN:
            setLEDColor(0, 255, 0);
            break;
        case LEDColor::BLUE:
            setLEDColor(0, 0, 255);
            break;
        case LEDColor::YELLOW:
            setLEDColor(255, 255, 0);
            break;
        case LEDColor::CYAN:
            setLEDColor(0, 255, 255);
            break;
        case LEDColor::MAGENTA:
            setLEDColor(255, 0, 255);
            break;
        default:
            throw std::invalid_argument("Invalid color");
        }
    }
}
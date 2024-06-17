#include <stdint.h>

namespace rgb
{
    enum class LEDColor
    {
        RED,
        GREEN,
        BLUE,
        YELLOW,
        CYAN,
        MAGENTA,
        WHITE
    };

    void initLED();
    void setLEDColor(uint8_t red, uint8_t green, uint8_t blue);
    void setLEDColor(LEDColor color);
}

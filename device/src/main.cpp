#include <stdint.h>
#include <math.h>

#include <bezier.hpp>
#include <rgb.hpp>

#include "motor_config.hpp"
#include "slider_controller.hpp"
#include "web_server.hpp"

#define CORE_0 0
#define CORE_1 1

void serverTask(void *pvParameters)
{
    runWebServer();
    vTaskDelete(NULL);
}

void controllerTask(void *pvParameters)
{
    runController();
    vTaskDelete(NULL);
}

void setup()
{
    Serial.begin(115200);

    rgb::initLED();
    rgb::setLEDColor(rgb::LEDColor::MAGENTA);

    xTaskCreatePinnedToCore(
        serverTask,
        "Web Server",
        32768,
        nullptr,
        1,
        nullptr,
        CORE_0);

    xTaskCreatePinnedToCore(
        controllerTask,
        "Slider Controller",
        32768,
        nullptr,
        1,
        nullptr,
        CORE_0);
}

void loop()
{
}
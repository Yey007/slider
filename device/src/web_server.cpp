
#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

#include <rgb.hpp>

void runWebServer()
{
    WiFi.softAP("slider");
    rgb::setLEDColor(rgb::LEDColor::BLUE);

    // AsyncWebServer server(80);

    // server.on("/", HTTP_GET, [](AsyncWebServerRequest *request)
    //           { request->send(200, "text/plain", "Hello, world!"); });

    // server.begin();
}

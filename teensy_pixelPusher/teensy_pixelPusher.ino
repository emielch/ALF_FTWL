#define TEENSY_ID      6

#include <OctoWS2811.h>

#if TEENSY_ID == 0
const int ledsPerStrip = 203;
#elif TEENSY_ID == 1
const int ledsPerStrip = 226;
#elif TEENSY_ID == 2
const int ledsPerStrip = 208;
#elif TEENSY_ID == 3
const int ledsPerStrip = 229;
#elif TEENSY_ID == 4
const int ledsPerStrip = 226;
#elif TEENSY_ID == 5
const int ledsPerStrip = 229;
#elif TEENSY_ID == 6
const int ledsPerStrip = 245;
#endif

DMAMEM int displayMemory[ledsPerStrip * 6];
int drawingMemory[ledsPerStrip * 6];
const int config = WS2811_800kHz; // color config is on the PC side

OctoWS2811 leds(ledsPerStrip, displayMemory, drawingMemory, config);

boolean newData = false;

const int ledPin = 13;
boolean ledState = false;

void setup() {
  pinMode(ledPin,OUTPUT);
  switchLed();
  Serial.setTimeout(5000);
  leds.begin();
  leds.show();
}

void switchLed(){
  ledState = !ledState;
  digitalWrite(ledPin,ledState);
}

void loop() {
  //
  // wait for a Start-Of-Message character:
  //
  //   '%' = Frame of image data, to be displayed when a frame sync
  //         character ('*') is received over serial.
  //
  //   '*' = Frame sync character, controls when new image data is
  //         sent to the leds.
  //
  //   '?' = Query LED and Video parameters.  Teensy 3.0 responds
  //         with a comma delimited list of information.
  //
  int startChar = Serial.read();

  if (startChar == '%') {
    // receive a frame - set boolean newData to true foshowing when
    // a frame sync arrives
    int count = Serial.readBytes((char *)drawingMemory, sizeof(drawingMemory));
    if (count == sizeof(drawingMemory)) {
      newData = true;
    }

  } else if (startChar == '*') {
    // recieve a frame sync - if there is new data, show it on the leds
    if (newData) {
      leds.show();
      switchLed();
      newData = false;
    }

  } else if (startChar == '?') {
    // when the video application asks, give it all our info
    // for easy and automatic configuration
    Serial.print(TEENSY_ID);
    Serial.write(',');
    Serial.print(ledsPerStrip);
    Serial.write(',');
    Serial.print(0);
    Serial.println();

  } else if (startChar >= 0) {
    // discard unknown characters
  }
}


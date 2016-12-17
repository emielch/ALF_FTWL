#define TEENSY_ID      7

#include <OctoWS2811.h>

// 0-6 are the wave LEDs teensys
#if TEENSY_ID == 0
const int ledsPerStrip = 211;
#elif TEENSY_ID == 1
const int ledsPerStrip = 226;
#elif TEENSY_ID == 2
const int ledsPerStrip = 207;
#elif TEENSY_ID == 3
const int ledsPerStrip = 228;
#elif TEENSY_ID == 4
const int ledsPerStrip = 227;
#elif TEENSY_ID == 5
const int ledsPerStrip = 229;
#elif TEENSY_ID == 6
const int ledsPerStrip = 243;

// 10 is the faces teensy
#elif TEENSY_ID == 7
const int ledsPerStrip = 125;
#define HALL_AM 3
byte hallPins[HALL_AM] = {0, 1, 23};
boolean hallStates[HALL_AM] = {false, false, false};
elapsedMillis sinceSerialReceive = 0;
unsigned int stopSendDelay = 2000;
unsigned long lastRisingHall[HALL_AM] = {0, 0, 0};
unsigned int hallDelay = 500;
#endif

DMAMEM int displayMemory[ledsPerStrip * 6];
int drawingMemory[ledsPerStrip * 6];
const int config = WS2811_800kHz; // color config is on the PC side

OctoWS2811 leds(ledsPerStrip, displayMemory, drawingMemory, config);

boolean newData = false;

const int ledPin = 13;
boolean ledState = false;

int rainbowColors[180];

unsigned int screenSaverDelay = 5000;
elapsedMillis sinceNewFrame = screenSaverDelay;

void setup() {
#if TEENSY_ID == 7
  for (int i = 0; i < HALL_AM; i++) {
    pinMode(hallPins[i], INPUT_PULLUP);
  }
#endif
  pinMode(ledPin, OUTPUT);
  switchLed();
  Serial.setTimeout(50);

  for (int i = 0; i < 180; i++) {
    int hue = i * 2;
    int saturation = 100;
    int lightness = 10;
    // pre-compute the 180 rainbow colors
    rainbowColors[i] = makeColor(hue, saturation, lightness);
  }
  leds.begin();
}

void switchLed() {
  ledState = !ledState;
  digitalWrite(ledPin, ledState);
}

void loop() {
  if (sinceNewFrame > screenSaverDelay) {
    rainbow(10, 2500);
  }

#if TEENSY_ID == 7

  for (int i = 0; i < HALL_AM; i++) {
    boolean val = digitalRead(hallPins[i]);
    if(val==true) lastRisingHall[i] = millis();
    if (val != hallStates[i]) {
      if (val==true || (val == false && millis() > lastRisingHall[i] + hallDelay)) {
        hallStates[i] = val;
        if (sinceSerialReceive < stopSendDelay && millis()>stopSendDelay) sendHallState(i, val);
      }
    }
  }
#endif


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
#if TEENSY_ID == 7
  if (startChar == '.') {
    sinceSerialReceive = 0;
  }
#endif
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
      sinceNewFrame = 0;
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


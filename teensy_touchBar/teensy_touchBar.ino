#include <Adafruit_NeoPixel.h>

#define PIN 5
#define LED_AM 120

Adafruit_NeoPixel leds = Adafruit_NeoPixel(LED_AM, PIN, NEO_GRB + NEO_KHZ800);


#define TOUCH_AM 12
byte touchPin[TOUCH_AM] = {0, 1, 15, 16, 17, 18, 19, 22, 23, 25, 32, 33};
//byte touchPin[TOUCH_AM] = {19, 22, 23, 25, 32, 33, 18, 17, 16, 15, 1, 0};

float touchVals[TOUCH_AM];
float touchCalib[TOUCH_AM];
int samples = 50;
int calibSamples = 100;

void setup() {
  calibTouchPins();

  leds.begin();
}

void loop() {
  readTouchPins();
  printTouchVals();
  calcLeds();
  leds.show();
}

void calcLeds() {
  float maxVal = 0;
  int maxID = -1;

  for (int i = 0; i < TOUCH_AM; i++) {
    float val = touchVals[i] - touchCalib[i];
    if (val > maxVal) {
      maxVal = val;
      maxID = i;
    }
  }

  int ledStart = maxID * (LED_AM / 12.);
  int ledEnd = (maxID + 1) * (LED_AM / 12.);
  for (int i = 0; i < LED_AM; i++) {
    if (i > ledStart && i < ledEnd) {
      leds.setPixelColor(i, 10, 20, 50);
    } else {
      leds.setPixelColor(i, 10, 0, 0);
    }
  }
}


void readTouchPins() {
  for (int i = 0; i < TOUCH_AM; i++) {
    touchVals[i] = 0;
  }

  for (int j = 0; j < samples; j++) {
    for (int i = 0; i < TOUCH_AM; i++) {
      touchVals[i] += touchRead(touchPin[i]) / float(samples);
    }
  }
}

void calibTouchPins() {
  for (int i = 0; i < TOUCH_AM; i++) {
    touchCalib[i] = 0;
  }
  for (int j = 0; j < calibSamples; j++) {
    for (int i = 0; i < TOUCH_AM; i++) {
      touchCalib[i] += touchRead(touchPin[i]) / float(calibSamples);
    }
  }
}


void printTouchVals() {
  for (int i = 0; i < TOUCH_AM; i++) {
    Serial.print(touchVals[i] - touchCalib[i]);
    Serial.print('\t');
  }
  Serial.println();
}





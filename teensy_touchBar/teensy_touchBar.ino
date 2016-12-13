#include <Colore.h>
#include <Adafruit_NeoPixel.h>

#define TOUCHBAR_ID 100 // 100 and 101 are touchbars


#define TOUCH_AM 12

#define MAX_POS 12

#if TOUCHBAR_ID==100
byte touchPin[TOUCH_AM] = {0, 1, 15, 16, 17, 18, 19, 22, 23, 25, 32, 33};
#else
byte touchPin[TOUCH_AM] = {19, 22, 23, 25, 32, 33, 18, 17, 16, 15, 1, 0};
#endif

float touchCalibVals[TOUCH_AM];
float touchRawVals[TOUCH_AM];
float touchMin[TOUCH_AM];
float touchMax[TOUCH_AM];

float touchPos[MAX_POS];

int samples = 50;

elapsedMillis sinceCalibCount = 0;
unsigned int calibDelay = 2000;

void setup() {
  setupLeds();

  for (int i = 0; i < TOUCH_AM; i++) {
    touchMin[i] = 1000000;
    touchMax[i] = -1;
  }
}

void loop() {
  checkSerial();
  calibCounter();
  readTouchPins();
  calcTouchPos();

  printTouchVals();

  updateLeds();
}
void checkSerial() {
  if (Serial.available() > 0) {
    int startChar = Serial.read();
    if (startChar == '?') {
      // when the video application asks, give it all our info
      // for easy and automatic configuration
      Serial.print(TOUCHBAR_ID);
      Serial.write(',');
      Serial.print(0);
      Serial.write(',');
      Serial.print(0);
      Serial.println();

    } else if (startChar >= 0) {
      // discard unknown characters
    }
  }
}


void calibCounter() {
  if (sinceCalibCount > calibDelay) {
    sinceCalibCount = 0;

    for (int i = 0; i < TOUCH_AM; i++) {
      touchMin[i]++;
      touchMax[i]--;
    }
  }
}



void readTouchPins() {
  for (int i = 0; i < TOUCH_AM; i++) {
    touchRawVals[i] = 0;
  }

  for (int j = 0; j < samples; j++) {
    for (int i = 0; i < TOUCH_AM; i++) {
      touchRawVals[i] += touchRead(touchPin[i]) / float(samples);
    }
  }

  for (int i = 0; i < TOUCH_AM; i++) {
    if (touchRawVals[i] < touchMin[i]) touchMin[i] = touchRawVals[i];
    if (touchRawVals[i] > touchMax[i]) touchMax[i] = touchRawVals[i];
    touchCalibVals[i] = mapFloat(touchRawVals[i], touchMin[i], touchMax[i], 0, 1);
  }
}

void calcTouchPos() {
  for (int i = 0; i < TOUCH_AM; i++) {
    if (touchCalibVals[i] > 0.2) {
      touchPos[i] = i;
    } else {
      touchPos[i] = -1;
    }
  }
}


void printTouchVals() {
  for (int i = 0; i < MAX_POS; i++) {
    if (touchPos[i] > -1) {
      Serial.print(touchCalibVals[i]);
      if (i != MAX_POS - 1) Serial.print('\t');
    }
  }
  Serial.println();

  //  for (int i = 0; i < TOUCH_AM; i++) {
  //    Serial.print(touchCalibVals[i]);
  //    Serial.print('\t');
  //  }
  //  Serial.println();
}


int mapFloat(float value, float low1, float high1, float low2, float high2) {
  float mapped = low2 + (high2 - low2) * (value - low1) / (high1 - low1);
  return mapped;
}




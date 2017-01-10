#define PIN 5
#define LED_AM 117

#define BEAM_AM 10

Beam beams[BEAM_AM];
Adafruit_NeoPixel leds = Adafruit_NeoPixel(LED_AM, PIN, NEO_GRB + NEO_KHZ800);

Segment seg[] = {
  Segment(0, LED_AM) // 0
};

byte segAm = sizeof(seg) / sizeof(Segment);
Colore colore( LED_AM, seg, segAm, beams, BEAM_AM, &set_ledLib, &get_ledLib, &show_ledLib, &reset_ledLib );

float touchLedSpread = 20;

Color BGCol(160, 100, 3, HSB_MODE);
Color touchCol(20, 100, 100, HSB_MODE);

void setupLeds() {
  leds.begin();
  seg[0].setStaticColor(BGCol);
  seg[0].setBlendMode(NORMAL);
}

void updateLeds() {
  colore.update(false,false);
  calcLeds();
  show_ledLib();
}


void calcLeds() {
  for (int i = 0; i < MAX_POS; i++) {
    if (touchPos[i] == -1) continue;
    float position = touchPos[i] * LED_AM;
    int startLed = position - touchLedSpread / 2;
    int endLed = position + touchLedSpread / 2;

    for (int i = startLed; i <= endLed; i++) {
      if ( i >= 0 && i < LED_AM ) {
        int pixelID = i;
        float dist = constrain(1 - abs(i - position) / touchLedSpread * 2, 0, 1);
        Color prevCol = get_ledLib(pixelID);
        prevCol.add(touchCol, dist);
        leds.setPixelColor(i, prevCol.red(), prevCol.green(), prevCol.blue());
      }
    }
  }
}


void set_ledLib(int pixel, byte r, byte g, byte b) {
  leds.setPixelColor(pixel, r, g, b);
}

void show_ledLib() {
  leds.show();
}

void reset_ledLib() {
  for (int i = 0; i < LED_AM; i++) {
    leds.setPixelColor(i, 0, 0, 0);
  }
}

Color get_ledLib(int pixel) {
  uint32_t conn = leds.getPixelColor(pixel);  // retrieve the color that has already been saved
  byte b = conn & 255;       // unpack the color
  byte g = conn >> 8 & 255;
  byte r = conn >> 16 & 255;
  Color pixelCol(r, g, b, RGB_MODE);
  return pixelCol;
}

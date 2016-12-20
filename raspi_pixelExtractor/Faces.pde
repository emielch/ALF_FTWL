int faceH = 0;
int faceS = 0;

int moveTime[] = {3000, 3000, 3000};
int startAnimation[] = {0, 0, 0};
int minMoveTime = 2000;
int minUpTime = 2000;
int minCharge = 0;
int maxCharge = 200;
int maxBrightness = 200;
int nextMaxEmptyTime[] = {0, 0, 0};
int emptyWaitTime = 20000; //Max time to wait for the hand to empty itself
float faceCharge[] = {minCharge, minCharge, minCharge};
float startCharge[] = new float[3];
boolean emptyFace[] = {false, false, false};
boolean faceDown[] = {false, false, false};
boolean soundTriggered[] = {false, false, false};
int emptyTime = 2000;

void drawFaces() {  
  colorMode(HSB);
  for (int i = 0; i < 3; i++) {
    if (millis() > nextMaxEmptyTime[i]) faceMove(i, false);
    if (faceDown[i] && millis()-startAnimation[i] > minMoveTime) {
      if (!soundTriggered[i]) {
        voiceSample[floor(random(voiceN))].trigger();
        soundTriggered[i] = true;
        startCharge[i] = faceCharge[i];
      }
      faceCharge[i] = (int)lerp(startCharge[i], maxBrightness, (float)(millis()-startAnimation[i]-2000) / (float)moveTime[i]);
    } else if (emptyFace[i]) {
      float r = (float)(millis()-startAnimation[i]) / (float)emptyTime;
      if (r > 1) emptyFace[i] = false;
      else faceCharge[i] = (int)lerp(startCharge[i], minCharge, r);
    }
    fill(color(faceH, faceS, faceCharge[i]));
    noStroke();
    rect(547+i*50, 0, 50, 50);
  }
}

void parseHall(char h) {
  boolean rise = false;
  int hallID = 0;
  try {
    hallID = Character.getNumericValue(h);
  }
  catch(Exception e) {
    println("error during parsing of hall data");
    return;
  }
  if (h<0 || h>5) return;
  if (hallID>2) {
    hallID-=3;
    rise = true;
  }
  faceMove(hallID, rise);
}


void faceMove(int faceID, boolean down) {
  if (down) {
    if (millis() - startAnimation[faceID] > minUpTime) {
      startAnimation[faceID] = millis();
      faceDown[faceID] = true;
      emptyFace[faceID] = false;
    }
  } else {
    if (millis() - startAnimation[faceID] > minMoveTime) {
      moveTime[faceID] = (int)(0.8*(float)moveTime[faceID] + 0.2*(millis()-startAnimation[faceID]));
      startAnimation[faceID] = millis();
      emptyFace[faceID] = true;
      faceDown[faceID] = false;
      startCharge[faceID] = faceCharge[faceID];
      nextMaxEmptyTime[faceID] = millis()+(int)random(0.9*emptyWaitTime, 1.1*emptyWaitTime);
      soundTriggered[faceID] = false;
    }
  }
}
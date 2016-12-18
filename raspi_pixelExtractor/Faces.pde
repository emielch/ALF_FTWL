int faceH = 0;
int faceS = 0;

int moveTime[] = {3000, 3000, 3000};
int startAnimation[] = {0,0,0};
int minMoveTime = 2000;
int minUpTime = 2000;
int minCharge = 0;
int maxCharge = 200;
int maxBrightness = 200;
float faceCharge[] = {minCharge,minCharge,minCharge};
float startCharge[] = new float[3];
boolean emptyFace[] = {false,false,false};
boolean faceDown[] = {false, false, false};
boolean soundTriggered;
int emptyTime = 1500;

void drawFaces(){  
  colorMode(HSB);
  for(int i = 0; i < 3; i++){
    if(faceDown[i] && millis()-startAnimation[i] > minMoveTime){
      faceCharge[i] = (int)lerp(startCharge[i], maxBrightness, (float)(millis()-startAnimation[i]-2000) / (float)moveTime[i]);
      if(!soundTriggered){
        voiceSample[floor(random(voiceN))].trigger();
        soundTriggered = true;
      }
      //if(i==0) println((float)(millis()-startAnimation[i]+2000) / (float)moveTime[i]);
    }
    else if(emptyFace[i]){
      float r = (float)(millis()-startAnimation[i]) / (float)emptyTime;
      if(r > 1) emptyFace[i] = false;
      else faceCharge[i] = (int)lerp(startCharge[i], minCharge, r);
    }
    fill(color(faceH, faceS, faceCharge[i]));
    noStroke();
    rect(547+i*50,0,50,50);
  }
}

void parseHall(char h){
  boolean rise = false;
  int hallID = Character.getNumericValue(h);
  if(hallID>2){
    hallID-=3;
    rise = true;
  }
  faceMove(hallID,rise);
}


void faceMove(int faceID, boolean down){
  if(down){
    if(millis() - startAnimation[faceID] > minUpTime){
      startAnimation[faceID] = millis();
      faceDown[faceID] = true;
      emptyFace[faceID] = false;
      startCharge[faceID] = faceCharge[faceID];
    }
  }
  else{
    if(millis() - startAnimation[faceID] > minMoveTime){
      moveTime[faceID] = (int)(0.8*(float)moveTime[faceID] + 0.2*(millis()-startAnimation[faceID]));
      startAnimation[faceID] = millis();
      emptyFace[faceID] = true;
      faceDown[faceID] = false;
      startCharge[faceID] = faceCharge[faceID];
      soundTriggered = false;
    }
  }
}
int faceH = 0;
int faceS = 0;
int faceCharge[] = {0,0,0};
int moveTime[] = {3000, 3000, 3000};
int startAnimation[] = {0,0,0};
int minMoveTime = 2000;
int minCharge = 20;
int maxCharge = 128;
int startCharge[] = new int[3];
boolean emptyFace[] = {false,false,false};
boolean faceDown[] = {false, false, false};
int emptyTime = 1500;

void drawFaces(){  
  colorMode(HSB);
  for(int i = 0; i < 3; i++){
    if(faceDown[i] && millis()-startAnimation[i] > minMoveTime){
      faceCharge[i] = (int)lerp(startCharge[i], 255, (float)(millis()-startAnimation[i]) / (float)moveTime[i]);
    }
    else if(emptyFace[i]){
      float r = (float)(millis()-startAnimation[i]) / (float)emptyTime;
      faceCharge[i] = (int)lerp(startCharge[i], minCharge, r);
      if(r > 1) emptyFace[i] = false;
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
    startAnimation[faceID] = millis();
    faceDown[faceID] = true;
    startCharge[faceID] = faceCharge[faceID];
  }
  else{
    if(millis() - startAnimation[faceID] > minMoveTime){
      startAnimation[faceID] = millis();
      moveTime[faceID] = (int)(0.8*(float)moveTime[faceID] + 0.2*millis()-startAnimation[faceID]);
      emptyFace[faceID] = true;
      faceDown[faceID] = false;
      startCharge[faceID] = faceCharge[faceID];
    }
  }
}
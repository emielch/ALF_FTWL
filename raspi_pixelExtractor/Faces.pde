color faceColor[];

void setupFaces(){
  faceColor = new color[3];
}

void setFaceColor(int fi, color c){
  faceColor[fi] = c;
}

void drawFaces(){
  for(int i = 0; i < 3; i++){
    fill(faceColor[i]);
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
  
}
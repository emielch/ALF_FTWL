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
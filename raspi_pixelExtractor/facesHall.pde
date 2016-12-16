

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
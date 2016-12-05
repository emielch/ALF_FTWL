class Pulse{
  int posX, posY;
  Segment currentS;
  
  //RandomWalk
  float segTime = 1.0;
  
  Pulse(Segment s, int dir){
    currentS = s;
    if(dir == 0){
      posX = currentS.startX;
      posY = currentS.startY;
    }
    else{
      posX = currentS.endX;
      posY = currentS.endY;
    }
  }
  
  void randomWalk(){
    
  }
  
}
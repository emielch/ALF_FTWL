PImage pulseSprite;
Pulse pulses[];

void setupRandomWalkPulses(int amount){
  pulseSprite = loadImage("BlobSprite.png");
  pulses = new Pulse[amount];
  colorMode(HSB);
  for(int i = 0; i < amount; i++){
    Segment r = segments.get(floor(random(segments.size())));
    int d = (random(1) > 0.5 ? -1 : 1);
    int s = floor(random(10, 100));
    pulses[i] = new Pulse(r, d, s, color(random(255),255,255), floor(map(s, 10, 100, 200, 5000)));
  }
}

void randomWalkPulses(){
  for(int i = 0; i < pulses.length; i++){
    pulses[i].randomWalk();
    pulses[i].draw();
  }
}

class Pulse{
  int posX, posY;
  Segment currentS;
  int segStart;
  int size;
  int dir;
  color c;
  int segTime;
  
  Pulse(Segment s, int dir, int size, color c, int st){
    currentS = s;
    if(dir == 0){
      posX = currentS.startX;
      posY = currentS.startY;
    }
    else{
      posX = currentS.endX;
      posY = currentS.endY;
    }
    segStart = millis();
    this.dir = dir;
    this.size = size;
    this.c = c;
    segTime = st;
  }
  
  void randomWalk(){
    float relPos = (float)(millis()-segStart)/((float)segTime);
    if(relPos > 1.0){ 
      switchSegments();
      relPos = 0.0;
    }
    if(dir > 0){
      posX = (int)lerp(currentS.startX, currentS.endX, relPos);
      posY = (int)lerp(currentS.startY, currentS.endY, relPos);
    }
    else{
      posX = (int)lerp(currentS.endX, currentS.startX, relPos);
      posY = (int)lerp(currentS.endY, currentS.startY, relPos);
    }
  }
  
  void switchSegments(){
    Segment old = currentS;
    if(dir > 0){
      if(random(1) > 0.5 && currentS.en[0] != null) currentS = currentS.en[0];
      else currentS = currentS.en[1];
    }
    else{
      if(random(1) > 0.5 && currentS.sn[0] != null) currentS = currentS.sn[0];
      else currentS = currentS.sn[1];
    }
    if(currentS == null){
      currentS = old;
      dir = -dir;
    }
    else{
      if(currentS.sn[0] == old || currentS.sn[1] == old){ 
        dir = 1;
      }
      else{ 
        dir = -1;
      }
    }
    
    segStart = millis();
  }
  
  void draw(){
    imageMode(CENTER);
    tint(c);
    image(pulseSprite, posX, posY, size, size);
  }
  
}
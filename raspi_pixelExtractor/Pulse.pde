PImage pulseSprite;
ArrayList<Pulse> pulses;
ArrayList<Pulse> removePulses;
int lastPulse;

void setupPulses(){
  pulseSprite = loadImage("BlobSprite.png");
  pulses = new ArrayList<Pulse>();
  removePulses = new ArrayList<Pulse>();
}

void firePulseToMouse(){
  if(millis() > lastPulse+200){
    Segment s = segments.get(floor(random(segments.size())));
    int dir;
    if(random(1) < 0.5) dir = 1;
    else dir = -1;
    colorMode(RGB);
    firePulse(s, mouseX, mouseY, dir, 10, color(255, 230, 180), floor(random(10,200)));
    lastPulse = millis();
  }
}

void firePulse(Segment from, int tx, int ty, int dir, int size, color c, int speed){
  Segment[] path = getPath(from, tx, ty, dir);
  for(int i = 0; i < path.length; i++){ 
    Segment p = path[i];
    //println(p.startX +"\t"+ p.startY +"\t"+ p.endX +"\t"+ p.endY);
    //text(i, p.startX+(p.endX-p.startX)/2, p.startY+(p.endY-p.startY)/2);
  }
  pulses.add(new Pulse(path, dir, size, c, speed));
}

void drawPulses(){
  for(Pulse p : pulses){
    p.update();
  }
  for(Pulse p : removePulses){
    pulses.remove(p);
  }
  for(Pulse p : pulses){
    p.draw();
  }
}

class Pulse{
  int posX, posY;
  Segment[] path;
  int cs;
  int segStart;
  int size;
  int dir;
  color c;
  int speed;
  
  Pulse(Segment[] path, int dir, int size, color c, int speed){
    this.path = path;
    if(dir == 0){
      posX = path[0].startX;
      posY = path[0].startY;
    }
    else{
      posX = path[0].endX;
      posY = path[0].endY;
    }
    segStart = millis();
    this.dir = dir;
    this.size = size;
    this.c = c;
    this.speed = speed;
  }
  
  void update(){
    float relPos = (float)(millis()-segStart)/(1000 * ((float) path[cs].ledN / (float) speed));
    if(relPos > 1.0){ 
      if(cs == path.length-1){ 
        removePulses.add(this);
        return;
      }
      dir = getDir(path[cs], path[++cs]);
      relPos = 0.0;
      segStart = millis();
    }
    if(dir > 0){
      posX = (int)lerp(path[cs].startX, path[cs].endX, relPos);
      posY = (int)lerp(path[cs].startY, path[cs].endY, relPos);
    }
    else{
      posX = (int)lerp(path[cs].endX, path[cs].startX, relPos);
      posY = (int)lerp(path[cs].endY, path[cs].startY, relPos);
    }
  }
  
  void draw(){
    imageMode(CENTER);
    tint(c);
    image(pulseSprite, posX, posY, size, size);
  }
  
}
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
    firePulse(s, mouseX, mouseY, dir, 10, floor(random(s.ledN)), color(255, 230, 180), floor(random(10,200)), 100000);
    lastPulse = millis();
  }
}

void firePulseFromMouse(){
  Segment start = closestSegment(mouseX, mouseY);
  int startLED = start.closestLED(mouseX,mouseY);
  
  int dir = (random(1) > 0.5 ? 1 : -1);
  
  firePulse(start, floor(random(width)), floor(random(height)), dir, 10, startLED, color(255, random(100,150), random(0,50)), floor(random(50,200)), floor(random(200, 1000)));
}

void firePulse(Segment from, int tx, int ty, int dir, int size, int startLED, color c, int speed, int lifeTime){
  Segment[] path = getPath(from, tx, ty, dir);
  for(int i = 0; i < path.length; i++){ 
    Segment p = path[i];
    //println(p.startX +"\t"+ p.startY +"\t"+ p.endX +"\t"+ p.endY);
    //text(i, p.startX+(p.endX-p.startX)/2, p.startY+(p.endY-p.startY)/2);
  }
  pulses.add(new Pulse(path, dir, size, startLED, c, speed, lifeTime));
}

void drawPulses(){
  for(Pulse p : pulses){
    p.update();
  }
  for(Pulse p : removePulses){
    pulses.remove(p);
  }
  removePulses = new ArrayList<Pulse>();
  imageMode(CENTER);
  colorMode(RGB);
  for(Pulse p : pulses){
    p.draw();
  }
}

class Pulse{
  int posX, posY;
  Segment[] path;
  int currentS;
  int segStart;
  int size;
  int dir;
  float r, g, b;
  float colorScale = 1.0;
  int speed;
  int birthTime;
  int lifeTime;
  
  Pulse(Segment[] path, int dir, int size, int startLED, color c, int speed, int lifeTime){
    this.path = path;
    posX = path[0].leds[startLED].posX;
    posY = path[0].leds[startLED].posY;
    if(dir > 0) segStart = (int)(millis()-1000*((float)startLED / (float) speed));
    else segStart = (int)(millis()-1000*((float)(path[0].ledN-startLED) / (float) speed));
    birthTime = millis();
    this.dir = dir;
    this.size = size;
    r = c >> 16 & 0xFF;
    g = c >> 8 & 0xFF;
    b = c & 0xFF;
    this.speed = speed;
    this.lifeTime = lifeTime;
  }
  
  void update(){
    float relPos = (float)(millis()-segStart)/(1000 * ((float) path[currentS].ledN / (float) speed));
    if(relPos > 1.0){ 
      if(currentS == path.length-1){ 
        removePulses.add(this);
        return;
      }
      colorScale = 1-(millis()-birthTime) / (float)lifeTime;
      if(colorScale < 0){
        removePulses.add(this);
        return;
      }
      dir = getDir(path[currentS], path[++currentS]);
      relPos = 0.0;
      segStart = millis();
    }
    if(dir > 0){
      posX = (int)lerp(path[currentS].startX, path[currentS].endX, relPos);
      posY = (int)lerp(path[currentS].startY, path[currentS].endY, relPos);
    }
    else{
      posX = (int)lerp(path[currentS].endX, path[currentS].startX, relPos);
      posY = (int)lerp(path[currentS].endY, path[currentS].startY, relPos);
    }
  }
  
  void draw(){
    tint(colorScale*r, colorScale*g, colorScale*b);
    image(pulseSprite, posX, posY, size, size);
  }
  
}
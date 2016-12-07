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
    firePulse(s, mouseX, mouseY, dir, 10, color(255, 230, 180), floor(random(10,200)), 100000);
    lastPulse = millis();
  }
}

void firePulseFromMouse(){
  int maxDist = 20;
  Segment start = segments.get(0);
  int dir = 0;
  for(Segment s : segments){
    float d = dist(mouseX, mouseY, s.startX, s.startY);
    if(d < maxDist){
      dir = 1;
      firePulse(s, floor(random(width)), floor(random(height)), dir, 10, color(255, random(100,150), random(0,50)), floor(random(50,200)), floor(random(200, 1000)));
    }
    d = dist(mouseX, mouseY, s.endX, s.endY);
    if(d < maxDist){
      dir = -1;
      firePulse(s, floor(random(width)), floor(random(height)), dir, 10, color(255, random(100,150), random(0,100)), floor(random(50,200)), floor(random(200,1000)));
    }
  }
  lastPulse = millis();
}

void firePulse(Segment from, int tx, int ty, int dir, int size, color c, int speed, int lifeTime){
  Segment[] path = getPath(from, tx, ty, dir);
  for(int i = 0; i < path.length; i++){ 
    Segment p = path[i];
    //println(p.startX +"\t"+ p.startY +"\t"+ p.endX +"\t"+ p.endY);
    //text(i, p.startX+(p.endX-p.startX)/2, p.startY+(p.endY-p.startY)/2);
  }
  pulses.add(new Pulse(path, dir, size, c, speed, lifeTime));
}

void drawPulses(){
  for(Pulse p : pulses){
    p.update();
  }
  for(Pulse p : removePulses){
    pulses.remove(p);
  }
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
  
  Pulse(Segment[] path, int dir, int size, color c, int speed, int lifeTime){
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
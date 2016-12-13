PImage dropSprite;
ArrayList<Drop> drops;
ArrayList<Drop> removeDrops;
ArrayList<Drop> addDrops;

int mergeRange = 3;

void setupDrops(){
  dropSprite = loadImage("DropSprite.png");
  drops = new ArrayList<Drop>();
  removeDrops = new ArrayList<Drop>();
  addDrops = new ArrayList<Drop>();
}

void drawDrops(){
  for(Drop d : drops) d.update();
  for(Drop d : drops){ 
    if(d.merged) removeDrops.add(d);
  }
  for(Drop d : removeDrops){ 
    while(drops.remove(d)) println("REMOVED!");
    println();
  }
  removeDrops = new ArrayList<Drop>();
  for(Drop d : addDrops) drops.add(d);
  addDrops = new ArrayList<Drop>();
  imageMode(CENTER);
  for(Drop d : drops) d.draw();
}

class Drop{  
  float x, y;
  
  int index;
  
  static final float minSpeed = 1; 
  static final float maxSpeed = 50;
  float speed = 0;
  float size;
  int dir;
  color c;
  Segment currentS;
  boolean merged = false;
  
  ArrayList<Drop> removeSegmentDrops;
  
  Drop(int x, int y, float size, color c){
    currentS = closestSegment(x,y);
    currentS.drops.add(this);
    LED l = currentS.leds[currentS.closestLED(x,y)];
    this.x = l.posX;
    this.y = l.posY;
    
    if(currentS.sa > 0) dir = 1;
    else if(currentS.sa < 0) dir = -1;
    else if(random(1) > 0.5) dir = 1;
    else dir = -1;

    this.size = size;    
    this.c = c;
  }
  
  Drop(Segment s, float size, color c){
    currentS = s;
    currentS.drops.add(this);
    
    if(s.startY < s.endY){
      dir = 1;
      this.x = s.startX;
      this.y = s.startY;
    }
    else{
      dir = -1;
      this.x = s.endX;
      this.y = s.endY;
    }
    
    this.size = size;    
    this.c = c;
  }
  
  void update(){
    println(merged);
    if(currentS.startX < currentS.endX && (x < currentS.startX || x > currentS.endX)) switchSegments();
    else if(currentS.startX > currentS.endX && (x < currentS.endX || x > currentS.startX)) switchSegments();
    else if(currentS.startY < currentS.endY && y > currentS.endY) switchSegments();
    else if(currentS.startY > currentS.endY && y > currentS.startY) switchSegments();
    
    removeSegmentDrops = new ArrayList<Drop>();
    for(Drop d : currentS.drops){
      //if(drops.indexOf(d) == -1) exit();
      if(dist(d.x,d.y,x,y) < mergeRange && d != this){ 
        merge(d);
      }
    }
    for(Drop d : removeSegmentDrops) currentS.drops.remove(d);
    
    if(size < 3) speed = 0;
    else if(size > 5) speed = 2*size*abs(currentS.sa)+minSpeed;
    if(speed > maxSpeed) speed = maxSpeed;
    
    if(speed > 0){
      x += speed*currentS.ca*((float)frameTime/1000)*dir;
      y += speed*currentS.sa*((float)frameTime/1000)*dir;
      size -= 0.1*speed*((float)frameTime/1000);
    }
    
    //Check if we reached the end of the segment
    //If so, switch segments, but only use segments which move down. If both move down, split into two drops
    //Check if we are close to another drop (distance of ~3px) on this segment (store in list in segment!)    
  }
  
  void draw(){
    tint(c);
    image(pulseSprite, x, y, size, size);
  }
  
  void merge(Drop d){
    if(!merged && !d.merged){ //Prevent merged drops merging again with this or other drops
      d.merged = true;
      removeSegmentDrops.add(d);
      x = (x+d.x)/2;
      y = (y+d.y)/2;
      colorMode(RGB);
      float totSize = size+d.size;
      //println(red(c)+"\t"+green(c)+"\t"+blue(c)+"\t\t"+red(d.c)+"\t"+green(d.c)+"\t"+blue(d.c));
      float r = (d.size*(d.c >> 16 & 0xFF)+size*(c >> 16 & 0xFF))/totSize;
      float g = (d.size*(d.c >> 8 & 0xFF)+size*(c >> 8 & 0xFF))/totSize;
      float b = (d.size*(d.c & 0xFF)+size*(c & 0xFF))/totSize;
      //println(r+"\t"+g+"\t"+b+"\t\t"+size+"\t"+d.size);
      c = color(r,g,b);
      size = totSize;
    }
  }
  
  void switchSegments(){
    Segment[] candidates = nextCandidates();
    if(candidates.length == 0){ 
      removeDrops.add(this);
      removeSegmentDrops.add(this);
    }
    else if(candidates.length == 1) switchTo(candidates[0]);
    else{
      if(candidates[0] == candidates[1]) switchTo(candidates[0]);
      else{
        float tsa = abs(candidates[0].sa) + abs(candidates[1].sa);
        float ratio = abs(candidates[0].sa)/tsa;
        if(size*ratio > 1) addDrops.add(new Drop(candidates[0], size*ratio, c));
        switchTo(candidates[1]);
        size *= 1-ratio;
        if(size < 1){ 
          removeDrops.add(this);
          removeSegmentDrops.add(this);
        }
        
      }
    }
  }
  
  void switchTo(Segment s){
    if(s.sa > 0) dir = 1;
    else if(s.sa < 0) dir = -1;
    else{
      if(s.sn[0] == currentS || s.sn[1] == currentS) dir = 1;
      else dir = -1;
    }
    if(dir > 0){ 
      x = s.startX;
      y = s.startY;
    }
    else{ 
      x = s.endX;
      y = s.endY;
    }
    
    currentS.drops.remove(this);
    s.drops.add(this);
    currentS = s;
  }
  
  Segment[] nextCandidates(){
    ArrayList<Segment> notNull = new ArrayList<Segment>();
    if(dir > 0){
      for(Segment s : currentS.en) if(s != null) notNull.add(s);
    }
    else{
      for(Segment s : currentS.sn) if(s != null) notNull.add(s);
    }
    ArrayList<Segment> down = new ArrayList<Segment>();
    for(Segment s : notNull){
      if((s.sn[0] == currentS || s.sn[1] == currentS) && s.sa >= 0){ 
        down.add(s);
      }
      else if((s.en[0] == currentS || s.en[1] == currentS) && s.sa <= 0){ 
        down.add(s);
      }
    }
    
    Segment[] result = new Segment[down.size()];
    return down.toArray(result);
  }
}
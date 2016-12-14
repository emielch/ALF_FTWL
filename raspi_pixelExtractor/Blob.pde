PImage blobSprite;
ArrayList<Blob> blobs;
ArrayList<Blob> removeBlobs;

void setupBlobs(){
  blobSprite = loadImage("BlobSprite.png");
  blobs = new ArrayList<Blob>();
  removeBlobs = new ArrayList<Blob>();
}

void drawBlobs(){
  for(Blob b : blobs) b.update();
  for(Blob b : removeBlobs) blobs.remove(b);
  removeBlobs = new ArrayList<Blob>();
  imageMode(CENTER);
  colorMode(HSB);
  for(Blob b : blobs) b.draw();
}

class Blob{
  float startX, startY, x, y, bx, by, speed, rx, ry, randomMovement;
  float pulseChance, dropChance;
  int tx, ty, size;
  int hue;
  color c;
  int startMove, moveTime;
  
  Blob(float x, float y, int tx, int ty, int size, int hue, int sat, int bri, float speed, float randomMovement, float pulseChance){
    rx = random(2*PI);
    ry = random(2*PI);
    this.x = x;
    this.y = y;
    this.c = c;
    this.speed = speed;
    this.size = size;
    setTarget(tx,ty);
    this.randomMovement = randomMovement;
    this.pulseChance = pulseChance;
    this.hue = hue;
    colorMode(HSB);
    c = color(hue,sat,bri);
  }
  
  Blob(float x, float y, int size, int hue, int sat, int bri, float speed, float randomMovement, float dropChance){
    rx = random(2*PI);
    ry = random(2*PI);
    tx = -1;
    ty = -1;
    this.x = x;
    this.y = y;
    this.c = c;
    this.speed = speed;
    this.size = size;
    this.randomMovement = randomMovement;
    this.dropChance = dropChance;
    this.hue = hue;
    colorMode(HSB);
    c = color(hue,sat,bri);
  }

  void update(){
    //Only move if we have a target
    if(tx > -1 && ty > -1){
      float relPos = (float)(millis()-startMove)/moveTime;
      if(relPos > 1){ 
        removeBlobs.add(this);
        return;
      }
      x = lerp(startX, tx, relPos);
      y = lerp(startY, ty, relPos);
    }
    if(randomMovement > 0){
      bx = randomMovement*cos(rx+2*PI*millis()/1000*(speed/(randomMovement*10)));
      by = randomMovement*sin(ry+2*PI*millis()/1000*(speed/(randomMovement*10)));
    }
    if(dropChance > 0){
      if(random(1) < dropChance) drops.add(new Drop((int)(x+bx+random(-size/3,size/3)), (int)(y+by+random(-size/3,size/3)), random(1,20), color(hue, 255, 200)));
    }
    if(pulseChance > 0){
      int dir;
      if(random(1) < 0.5) dir = 1;
      else dir = -1;
      if(random(1) < pulseChance) firePulse((int)(x+bx), (int)(y+by), tx, ty, dir, 5, color(0, 0, 255), floor(random(50,200)), floor(random(200,1500)));
    }
  }
  
  void draw(){
    tint(c);
    image(blobSprite, x+bx, y+by, size, size);
  }
  
  void setTarget(int tx, int ty){
    startMove = millis();
    moveTime = (int)(dist(x,y,tx,ty)/(2.2222222222*speed)*1000);
    startX = this.x;
    startY = this.y;
    this.tx = tx;
    this.ty = ty;
  }
}
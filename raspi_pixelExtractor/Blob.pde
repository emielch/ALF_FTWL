PImage blobSprite;
ArrayList<Blob> blobs;
ArrayList<Blob> removeBlobs;
ArrayList<Blob> addBlobs;
float chargeAmount = 0.9;

void setupBlobs(){
  blobSprite = loadImage("BlobSprite.png");
  blobs = new ArrayList<Blob>();
  removeBlobs = new ArrayList<Blob>();
  addBlobs = new ArrayList<Blob>();
}

void drawBlobs(){
  imageMode(CENTER);
  colorMode(HSB);
  for(Blob b : blobs) b.update();
  for(Blob b : removeBlobs) blobs.remove(b);
  removeBlobs = new ArrayList<Blob>();
  for(Blob b : addBlobs) blobs.add(b);
  addBlobs = new ArrayList<Blob>();
  for(Blob b : blobs) b.draw();
}

void sendLove(int x, int y){
  int fi;
  if(x-712 < (faceX[1]-faceX[0])/2+faceX[0]) fi = 0;
  else if(x-712 < (faceX[2]-faceX[1])/2+faceX[1]) fi = 1;
  else fi = 2;
  blobs.add(new Blob(x,y,faceX[fi], faceY, (int)random(50,100), (int)random(200,255), (int)random(200,255), 200, 100, random(10,30),0.2,true));
  
  if(x > 712){
    int soundi = floor((532-(x-712))/(540/15));
    soundi = constrain(soundi, 0, touchSample.length);
    if(millis() > touchTriggered[soundi]+3000){
      touchSample[soundi].trigger();
      touchTriggered[soundi] = millis();
    }
  }
}

class Blob{
  float startX, startY, x, y, bx, by, speed, rx, ry, randomMovement;
  float pulseChance, dropChance;
  int tx, ty, size;
  int hue, sat, bri;
  color c;
  int startMove, moveTime;
  boolean street;
  
  Blob(float x, float y, int tx, int ty, int size, int hue, int sat, int bri, float speed, float randomMovement, float pulseChance, boolean street){
    rx = random(2*PI);
    ry = random(2*PI);
    this.x = x;
    this.y = y;
    this.speed = speed;
    this.size = size;
    setTarget(tx,ty);
    this.randomMovement = randomMovement;
    this.pulseChance = pulseChance;
    this.hue = hue;
    this.sat = sat;
    this.bri = bri;
    colorMode(HSB);
    c = color(hue,sat,255,bri);
    this.street = street;
  }
  
  Blob(float x, float y, int size, int hue, int sat, int bri, float speed, float randomMovement, float dropChance){
    rx = random(2*PI);
    ry = random(2*PI);
    tx = -1;
    ty = -1;
    this.x = x;
    this.y = y;
    this.speed = speed;
    this.size = size;
    this.randomMovement = randomMovement;
    this.dropChance = dropChance;
    this.hue = hue;
    this.sat = sat;
    this.bri = bri;
    colorMode(HSB);
    c = color(hue,sat,bri);
  }

  void update(){
    //Only move if we have a target
    if(tx > -1 && ty > -1){
      float relPos = (float)(millis()-startMove)/moveTime;
      if(relPos > 1){ 
        if(street){ 
          addBlobs.add(new Blob(532-(x-712), 0, tx, ty, size, hue, sat, bri, speed, randomMovement, pulseChance, false));
        }

        for(int i = 0; i < 3; i++){
          if(abs(x-faceX[i]) < 2){ 
            if(faceCharge[i] < maxCharge) faceCharge[i] += chargeAmount;
          }
        }
          
        removeBlobs.add(this);
        return;
      }
      
      if(!street){
        x = lerp(startX, tx, relPos);
        y = lerp(startY, ty, relPos);
      }
      else{ 
        x = lerp(startX, x, relPos);
        y = lerp(startY, 0, relPos);
      }
    }
    if(randomMovement > 0){
      bx = randomMovement*cos(rx+2*PI*millis()/1000*(speed/(randomMovement*10)));
      by = randomMovement*sin(ry+2*PI*millis()/1000*(speed/(randomMovement*10)));
    }
    if(dropChance > 0){
      if(random(1) < dropChance){
        int dx = (int)(x+bx+random(-size/4,size/4));
        int dy = (int)(y+by+random(-size/4,size/4));
        if(dx > 0 && dx < width && dy > 0 && dy < width) drops.add(new Drop(dx, dy, random(1,20), color(hue, 255, 200)));
      }
    }
    if(pulseChance > 0){
      int dir;
      if(random(1) < 0.5) dir = 1;
      else dir = -1;
      if(random(1) < pulseChance){ 
        if(!street) firePulse((int)(x+bx), (int)(y+by), tx, ty, dir, 5, color(0, 0, 255), floor(random(50,200)), floor(random(200,1500)));
        else firePulse((int)(x+bx), (int)(y+by), (int)x, 0, dir, 5, color(0, 0, 255), floor(random(50,200)), floor(random(200,1500)));
      }
    }
  }
  
  void draw(){
    tint(c);
    image(blobSprite, x+bx, y+by, size, size);
  }
  
  void setTarget(int tx, int ty){
    startMove = millis();
    if(!street) moveTime = (int)(dist(x,y,tx,ty)/(2.2222222222*speed)*1000);
    else moveTime = (int)(dist(x,y,x,0)/(2.2222222222*speed)*1000);
    startX = this.x;
    startY = this.y;
    this.tx = tx;
    this.ty = ty;
  }
}
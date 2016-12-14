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

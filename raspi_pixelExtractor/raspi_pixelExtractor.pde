int frameStart, frameTime;


void setup() {
  size(1266, 800, P2D);
  background(0);
  frameRate(1000);
  serialSetup();
  senderSetup();
  setupPulses();
  setupDrops();
  setupBlobs();
  createMeshMask();
  
  colorMode(HSB);
  for(int i = 0; i < 20; i++){
    blobs.add(new Blob(width/2, height/2, (int)random(1000,2000), (int)random(105, 170), (int)random(200, 255), (int)random(20,50), random(1, 30), width/2, 0.01));
  }
}


void draw() {
    frameTime = millis()-frameStart;
    frameStart = millis();
    
    println(frameRate);
    background(0);
  
    if (mousePressed) {  
      blobs.add(new Blob(mouseX,mouseY,(int)random(width), (int)random(height), (int)random(200,500), (int)random(200,255), (int)random(200,255), 200, random(30,50), random(10,30),0.3));
      delay(100);
    }
    
    drawBlobs();
    drawDrops();
    drawPulses();
    
    maskMesh();
  
    sendFrame();
}
int frameStart, frameTime;


void setup() {
  size(1266, 800, P2D);
  background(0);
  frameRate(1000);
  serialSetup();
  senderSetup();
  setupPulses();
  setupDrops();
  createMeshMask();
}


void draw() {
    frameTime = millis()-frameStart;
    frameStart = millis();
    
    //println(frameRate);
    background(20,8,0);
  
    if (mousePressed) { 
      //firePulseFromMouse();
      //testSegmentCounts(1);
      colorMode(HSB, 255);
      drops.add(new Drop(mouseX,mouseY,random(1,10),color(random(105, 170), random(200, 255), 255)));
      delay((int)random(1,100));
    }
    
    drawDrops();
    drawPulses();
    maskMesh();
  
    sendFrame();
}
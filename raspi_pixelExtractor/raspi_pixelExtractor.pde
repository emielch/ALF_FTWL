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
    
    //println(frameTime);
    background(20,8,0);
    
    //int r = ceil(random(2));
    colorMode(HSB);
    if(random(1) < 0.5) drops.add(new Drop(floor(random(1075)),floor(random(600)),random(1,15),color(random(105, 170), random(200, 255), 255)));
  
    if (mousePressed) { 
      //firePulseFromMouse();
      //testSegmentCounts(1);
      colorMode(HSB, 255);
      drops.add(new Drop(mouseX,mouseY,20,color(random(105, 170), random(200, 255), 255)));
      delay(300);
    }
    
    drawDrops();
    drawPulses();
    maskMesh();
  
    sendFrame();
}
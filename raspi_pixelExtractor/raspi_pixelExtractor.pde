
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
  //println(frameRate);
  background(0);
  
  if(mousePressed){ 
    //firePulseFromMouse();
    //testSegmentCounts(1);
    drops.add(new Drop(mouseX,mouseY,random(1,50),color(0, random(0,128), random(0,255))));
    delay(300);
  }
  
  
  drawDrops();
  drawPulses();
  maskMesh();
  
  sendFrame();
}

void setup() {
  size(1266, 800, P2D);
  background(0);
  frameRate(1000);
  serialSetup();
  senderSetup();
  setupPulses();
  createMeshMask();
}


void draw() {
  println(frameRate);
  background(0);
  
  if(mousePressed){ 
    firePulseFromMouse();
  }
  
  drawPulses();
  maskMesh();
  
  sendFrame();
}
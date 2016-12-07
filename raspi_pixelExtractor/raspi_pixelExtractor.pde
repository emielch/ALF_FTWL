
void setup() {
  size(1266, 800, P2D);
  background(0);
  frameRate(1000);
  serialSetup();
  senderSetup();
  setupPulses();
}


void draw() {
  println(frameRate);
  background(0);
  //firePulseToMouse();
  if(mousePressed){ 
    firePulseFromMouse();
  }
  drawPulses();
  sendFrame();
}

void setup() {
  size(1266, 800);
  background(0);
  frameRate(1000);
  serialSetup();
  senderSetup();
  setupPulses();
}


void draw() {
  println(frameRate);
  background(0);
  firePulseToMouse();
  drawPulses();
  sendFrame();
}
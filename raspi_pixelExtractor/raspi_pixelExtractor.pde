
void setup() {
  size(1266, 800, P2D);
  frameRate(1000);
  serialSetup();
  senderSetup();
  setupRandomWalkPulses(300);
}


void draw() {
  //println(frameRate);
  
  background(0);
  //fill(255, 255, 0);
  //rectMode(CENTER);
  //rect(mouseX, mouseY, 200, 200);
  //testSegmentCounts(1);
  randomWalkPulses();
  sendFrame();
}

void setup() {
  size(1266, 800, P2D);
  frameRate(1000);
  serialSetup();
  senderSetup();
  setupRandomWalkPulses(300);
}


void draw() {
  //println(frameRate);
  colorMode(HSB);
  int hue = floor((millis()%64000)/250);
  
  background(0);
  bgNoise(color(hue,255,64), 0.001);
  //fill(255, 255, 0);
  //rectMode(CENTER);
  //rect(mouseX, mouseY, 200, 200);
  //testSegmentCounts(1);
  randomWalkPulses();
  sendFrame();
}
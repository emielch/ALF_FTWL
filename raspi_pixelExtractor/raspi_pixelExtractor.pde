
void setup() {
  size(1266, 800, P2D);
  frameRate(300);
  serialSetup();
  senderSetup();
}


void draw() {
  background(0);
  fill(255, 0, 0);
  rectMode(CENTER);
  rect(mouseX, mouseY, 200, 200);
  sendFrame();
}
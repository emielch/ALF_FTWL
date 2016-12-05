
void setup() {
  size(20  , 20);
  frameRate(100);
  serialSetup();
  senderSetup();
}


void draw() {
  println(frameRate);
 // while(true){
  //background(0);
  //fill(255, 255, 0);
  //rectMode(CENTER);
  //rect(mouseX, mouseY, 200, 200);
  sendFrame();
  //}
}
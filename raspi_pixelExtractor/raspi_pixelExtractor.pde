int frameStart, frameTime;

int channel = 0;


void setup() {
  size(1266, 800, P2D);
  background(0);
  frameRate(1000);
  serialSetup();
  senderSetup();
  setupPulses();
  setupDrops();
  setupBlobs();
  setupSound();
  setupFaces();
  createMeshMask();

  colorMode(HSB);
  for (int i = 0; i < 20; i++) {
    blobs.add(new Blob(width/2, height/2, (int)random(500, 1000), (int)random(105, 170), (int)random(200, 255), (int)random(40, 60), random(20, 40), width/2, 0.01));
  }
  
  thread("serialHeartbeat");
}


void draw() {
  serialUpdate();
  
  frameTime = millis()-frameStart;
  frameStart = millis();

  //println(frameRate);
  background(0);

  if (mousePressed) {
    sendLove(mouseX, mouseY);
  }

  drawBlobs();
  drawDrops();
  drawPulses();

  //if(keyPressed){ 
  //  testSegmentCounts(5);
  //  testChannelLocations(5, channel++);
  //  if(channel > 7) channel = 0;
  //  delay(500);
  //}

  maskMesh();
  
  drawFaces();

  sendFrame();
}


void exit() {
  closeConnections();
  super.exit();
}
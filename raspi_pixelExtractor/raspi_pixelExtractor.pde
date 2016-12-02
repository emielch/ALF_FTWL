
float hue = 0;

int threads = 0;



void setup() {
  teensySetup();
  colorMode(HSB, 360, 100, 100);

  for (int i=0; i < numPorts; i++) { 
    thread("senderThread");
    delay(100);
  }
}


void draw() {
  //multiSender();

  long lastFrame = 0;
  long frameTime = 0;

  while (true) {
    boolean allReady = true;
    for (int i=0; i < numPorts; i++) {
      if (!ready[i]) {
        allReady=false;
        break;
      }
    }

    if (allReady) {
      long currTime = System.nanoTime();
      frameTime = currTime - lastFrame;
      lastFrame = currTime;
      println(1000000000./frameTime);

      //hue++;
      //if (hue>360) hue-=360;

      for (int i=0; i < numPorts; i++) {
        ready[i] = false;
      }
    }
  }
}

void senderThread() {
  int i = threads;
  threads++;

  byte[] ledData =  new byte[(maxLeds[i] * 8 * 3) + 1];

  while (true) {
    if (ready[i]) {
      delay(5);
      continue;
    }

    image2data(ledData, 1, 0);
    ledData[0] = '%';
    // send the raw data to the LEDs  :-)
    ledSerial[i].write(ledData);
    ledSerial[i].write('*');
    ready[i] = true;
  }
}



void multiSender() {
  long lastFrame = 0;
  long frameTime = 0;

  while (true) {
    long currTime = System.nanoTime();
    frameTime = currTime - lastFrame;
    lastFrame = currTime;
    println(1000000000./frameTime);

    for (int i=0; i < numPorts; i++) {    
      byte[] ledData =  new byte[(maxLeds[i] * 8 * 3) + 1];
      //image2data(ledData, 1, 0);
      ledData[0] = '%';
      // send the raw data to the LEDs  :-)
      ledSerial[i].write(ledData);
    }

    for (int i=0; i < numPorts; i++) {
      ledSerial[i].write('*');
    }
  }
}
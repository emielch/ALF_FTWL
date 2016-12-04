
float hue = 0;

int threads = 0;



void setup() {
  teensySetup();
  colorMode(HSB, 360, 100, 100);

  for (int i=0; i < numPorts; i++) { 
    thread("senderThread");
    delay(100);
  }
  thread("controlThread");
}

FloatList framerates = new FloatList();
long lastPrint = 0;
long printDelay = 1000;
long maxFrameTime = 0;

void draw() {
  //multiSender();
}

void controlThread() {
  long lastFrame = 0;
  long frameTime = 0;

  while (true) {
    if (millis()>lastPrint+printDelay) {
      lastPrint = millis();
      float avg = 0;
      for (int i=0; i<framerates.size(); i++) {
        avg += framerates.get(i);
      }
      avg/=framerates.size();
      println(avg);
      println(maxFrameTime/1000000.);
      maxFrameTime= 0;
      framerates.clear();
    }


    boolean allSent = true;
    boolean allSync = true;
    for (int i=0; i < numPorts; i++) {
      if (teensySendState[i]!=1) {
        allSent=false;
      }
      if (teensySendState[i]!=3) {
        allSync=false;
      }
    }

    if (allSent) {
      hue++;
      if (hue>360) hue-=360;

      for (int i=0; i < numPorts; i++) {
        teensySendState[i] = 2;
      }
    }
    if (allSync) {
      long currTime = System.nanoTime();
      frameTime = currTime - lastFrame;
      lastFrame = currTime;
      float framerate = 1000000000./frameTime;
      if (frameTime>maxFrameTime) maxFrameTime = frameTime;
      framerates.append(framerate);

      for (int i=0; i < numPorts; i++) {
        teensySendState[i] = 0;
      }
    }
  }
}

void senderThread() {
  int i = threads;
  threads++;

  byte[] ledData =  new byte[(maxLeds[i] * 8 * 3) + 1];

  while (true) {
    if (teensySendState[i]==0) {
      image2data(ledData, 1, 0);
      ledData[0] = '%';
      // send the raw data to the LEDs  :-)
      ledSerial[i].write(ledData);
      teensySendState[i] = 1;
    } else if (teensySendState[i]==2) {
      ledSerial[i].write('*');
      teensySendState[i] = 3;
    }
  }
}
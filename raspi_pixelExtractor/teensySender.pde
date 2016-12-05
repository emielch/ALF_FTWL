import processing.serial.*;

float gamma = 1.7;
int[] gammatable = new int[256];

FloatList frameTimes = new FloatList();
long lastPrint = 0;
long printDelay = 1000;

volatile ArrayList<ledBuffer> writeBuffers = new ArrayList<ledBuffer>();
volatile ArrayList<ledBuffer> sendBuffers = new ArrayList<ledBuffer>();

volatile boolean writeBuffersFilled = false;

volatile byte teensySendState[] = new byte[maxPorts]; // 0: done syncing, do nothing; 1: send current send Buffers; 2: done sending buffer; 3: send sync

int ledDataOffset = 1;

int threads = 0;


void senderSetup() {
  for (int i=0; i < 256; i++) {
    gammatable[i] = (int)(pow((float)i / 255.0, gamma) * 255.0 + 0.5);
  }

  //create send and write buffers
  for (int i=0; i < numPorts; i++) { 
    writeBuffers.add(new ledBuffer((maxLeds[i] * 8 * 3) + ledDataOffset));
    sendBuffers.add(new ledBuffer((maxLeds[i] * 8 * 3) + ledDataOffset));
  }

  // start the send threads
  for (int i=0; i < numPorts; i++) { 
    teensySendState[i] = 0;
    thread("sendThread");
    delay(100);
  }

  // start the send controller
  thread("sendController");

  importMesh("mesh.json");
}

void sendFrame() {
  while (writeBuffersFilled) {
    delay(1);
  }
  for (int i=0; i < numPorts; i++) {
    ledBuffer currBuffer = writeBuffers.get(i);
    byte[] ledData = currBuffer.ledData;
    mesh2data(ledData, ledDataOffset, i);
    ledData[0] = '%';
  }
  writeBuffersFilled = true;
}

void sendController() {
  long lastFrame = 0;
  long frameTime = 0;

  while (true) {
    delay(1);
    if (millis()>lastPrint+printDelay) {
      lastPrint = millis();

      float avg = 0;
      for (int i=0; i<frameTimes.size(); i++) {
        avg += frameTimes.get(i);
      }
      avg/=frameTimes.size();

      float maxFrameTime = -1;
      float minFrameTime = -1;
      if (frameTimes.size()>0) maxFrameTime=frameTimes.max();
      if (frameTimes.size()>0) minFrameTime=frameTimes.min();
      println("frameRate   avg: ", int(1000./avg), "\tmin: ", int(1000./maxFrameTime), "\tmax: ", int(1000./minFrameTime));
      frameTimes.clear();
    }

    boolean allSent = true;
    boolean allSynced = true;

    for (int i=0; i < numPorts; i++) {
      if (teensySendState[i]!=2) {
        allSent=false;
      }
      if (teensySendState[i]!=0) {
        allSynced=false;
      }
    }

    if (allSent) {
      for (int i=0; i < numPorts; i++) {
        teensySendState[i] = 3;
      }

      while (!writeBuffersFilled) {
        delay(1);
      }

      ArrayList<ledBuffer> switchBuffers = writeBuffers;
      writeBuffers = sendBuffers;
      sendBuffers = switchBuffers;
      writeBuffersFilled = false;
    }
    if (allSynced) {
      long currTime = System.nanoTime();
      frameTime = currTime - lastFrame;
      lastFrame = currTime;
      frameTimes.append(frameTime/1000000.);

      for (int i=0; i < numPorts; i++) {
        teensySendState[i] = 1;
      }
    }
  }
}


void sendThread() {
  int i = threads;
  threads++;

  while (true) {    
    if (teensySendState[i]==1) {
      byte ledData[] = sendBuffers.get(i).ledData;
      ledSerial[i].write(ledData);
      teensySendState[i] = 2;
    } else if (teensySendState[i]==3) {
      ledSerial[i].write('*');
      teensySendState[i] = 0;
    }else delay(1);
  }
}




void mesh2data(byte[] data, int offset, int id) {
  int tID = teensyID[id];
  int pixel[] = new int[8];
  int mask;

  Segment currentS[] = new Segment[8];
  arrayCopy(teensies[tID].channel, currentS);
  int currentLED[] = {0, 0, 0, 0, 0, 0, 0, 0};

  for (int i = 0; i < maxLeds[id]; i++) {

    for (int j = 0; j < 8; j++) {
      if (currentS[j] == null) pixel[j] = 0;
      else {
        LED l = currentS[j].leds[currentLED[j]];
        pixel[j] = get(l.posX, l.posY);
        pixel[j] = colorWiring(pixel[j]);

        //if (i == 0 && j == 0) println(red(pixel[j]));
        //This was the last LED, switch to next segment
        if (++currentLED[j] == currentS[j].leds.length) {
          currentS[j] = currentS[j].next;
          currentLED[j] = 0;
        }
      }
    }

    // convert 8 pixels to 24 bytes
    for (mask = 0x800000; mask != 0; mask >>= 1) {
      byte b = 0;
      for (int j=0; j < 8; j++) {
        if ((pixel[j] & mask) != 0) b |= (1 << j);
      }
      data[offset++] = b;
    }
  }
}



// translate the 24 bit color from RGB to the actual
// order used by the LED wiring.  GRB is the most common.
int colorWiring(int c) {
  int red = (c & 0xFF0000) >> 16;
  int green = (c & 0x00FF00) >> 8;
  int blue = (c & 0x0000FF);
  red = gammatable[red];
  green = gammatable[green];
  blue = gammatable[blue];
  return (green << 16) | (red << 8) | (blue); // GRB - most common wiring
}
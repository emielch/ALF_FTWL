import processing.serial.*;

float gamma = 1.7;
int[] gammatable = new int[256];

FloatList frameTimes = new FloatList();
long lastPrint = 0;
long printDelay = 1000;

ArrayList<SenderThread> senderThreads = new ArrayList<SenderThread>();
ArrayList<byte[]> mapedData = new ArrayList<byte[]>();
int ledDataOffset = 1;
CountDownLatch sendLatch =new CountDownLatch(0);
CountDownLatch receiveLatch = new CountDownLatch(1);
int threads = 0;


void senderSetup() {
  for (int i=0; i < 256; i++) {
    gammatable[i] = (int)(pow((float)i / 255.0, gamma) * 255.0 + 0.5);
  }
 
  // start the send controller
  thread("sendController");

  importMesh("mesh.json");
}

void sendFrame() {
  latchWait(sendLatch);
  sendLatch =new CountDownLatch(1);
  
  for (int i=0; i < numPorts; i++) {
    mesh2data(mapedData.get(i), ledDataOffset, i);
    mapedData.get(i)[0] = '%';
  }

  if (receiveLatch.getCount()==1) {
    receiveLatch.countDown();
  }
}

void latchWait(CountDownLatch latch) {
  try {
    latch.await();  // wait untill all threads sent their data
  } 
  catch (InterruptedException e) {
    e.printStackTrace();
  }
}

void sendController() {

  CountDownLatch transmit = new CountDownLatch(numPorts);
  CountDownLatch display = new CountDownLatch(numPorts);

  while (true) {

    latchWait(receiveLatch);
    receiveLatch = new CountDownLatch(1);

    for (int i=0; i < numPorts; i++) {
      SenderThread currSender = senderThreads.get(i);
      currSender.writeBuffer(mapedData.get(i));
    }
    if (sendLatch.getCount()==1) {
      sendLatch.countDown();
    }

    transmit = new CountDownLatch(numPorts);
    for (int i=0; i < numPorts; i++) {
      SenderThread currSender = senderThreads.get(i);
      currSender.sendData(transmit);
    }
    latchWait(transmit);

    display = new CountDownLatch(numPorts);
    for (int i=0; i < numPorts; i++) {
      SenderThread currSender = senderThreads.get(i);
      currSender.sendSync(display);
    }

    latchWait(display);
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
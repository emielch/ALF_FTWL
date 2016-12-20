import processing.serial.*;

float gamma = 1.7;
int[] gammatable = new int[256];

ArrayList<SenderThread> senderThreads = new ArrayList<SenderThread>();
ArrayList<byte[]> mappedData = new ArrayList<byte[]>();
volatile boolean mappedDataFull = false;
final int ledDataOffset = 1;
CountDownLatch sendLatch = new CountDownLatch(1);


void senderSetup() {
  for (int i=0; i < 256; i++) {
    gammatable[i] = (int)(pow((float)i / 255.0, gamma) * 255.0 + 0.5);
  }

  // start the send controller
  thread("sendController");
}

void sendFrame() {
  if (mappedDataFull) {
    println(millis(), " skipped a frame");
    return;
  }
  for (int i=0; i < numPorts; i++) {
    mesh2data(mappedData.get(i), ledDataOffset, i);
    mappedData.get(i)[0] = '%';
  }
  mappedDataFull = true;

  if (sendLatch.getCount()==1) {
    sendLatch.countDown();
  }
}


void sendController() {
  CountDownLatch transmitLatch;

  while (true) {
    latchWait(sendLatch);   // continue when there is new data in "mappedData" to be sent
    sendLatch = new CountDownLatch(1);

    for (int i=0; i < numPorts; i++) {
      SenderThread currSender = senderThreads.get(i);
      currSender.writeBuffer(mappedData.get(i));
    }
    mappedDataFull = false;

    transmitLatch = new CountDownLatch(numPorts);
    for (int i=0; i < numPorts; i++) {
      SenderThread currSender = senderThreads.get(i);
      currSender.sendData(transmitLatch);
    }
    latchWait(transmitLatch);

    transmitLatch = new CountDownLatch(numPorts);
    for (int i=0; i < numPorts; i++) {
      SenderThread currSender = senderThreads.get(i);
      currSender.sendSync(transmitLatch);
    }
    latchWait(transmitLatch);
  }
}


void latchWait(CountDownLatch latch) {
  try {
    latch.await();  // wait untill the latch is at 0
  } 
  catch (InterruptedException e) {
    e.printStackTrace();
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
        if(currentS[j].disabled) pixel[j] = 0;
        else{
          LED l = currentS[j].leds[currentLED[j]];
          pixel[j] = get(l.posX, l.posY);
          pixel[j] = colorWiring(pixel[j]);
        }

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
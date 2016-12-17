import processing.serial.*;

CountDownLatch serialHeartbeatLatch = new CountDownLatch(1);

long lastHB = 0;
int HBDelay = 1000;

boolean serialStarted = false;

void serialUpdate() {
  if (!serialStarted) {
    serialSetup();
    senderSetup();
    serialStarted = true;
  }


  if (millis()>lastHB+HBDelay) {
    serialHeartbeatLatch.countDown();
    lastHB = millis();
  }
  for (int i=0; i<numTouchPorts; i++) {
    while (touchSerial[i].available() > 0) {
      char inChar = touchSerial[i].readChar();
      if (inChar=='\n') {
        parseTouchString(touchBuffer[i], teensyTouchID[i]);
        touchBuffer[i] = "";
      } else if (inChar!='\r') touchBuffer[i]+=inChar;
    }
  }

  if (faceSerial!=null) {
    while (faceSerial.available() > 0) {
      char inChar = faceSerial.readChar();
      parseHall(inChar);
    }
  }
}


void serialHeartbeat() {
  while (true) {
    serialHeartbeatLatch = new CountDownLatch(1);
    latchWait(serialHeartbeatLatch);
    for (int i=0; i<numTouchPorts; i++) {
      touchSerial[i].write('.');   // send heartbeat
    }
    if (faceSerial!=null) {
      faceSerial.write('.');
    }
  }
}
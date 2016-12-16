import processing.serial.*;

CountDownLatch serialHeartbeatLatch;

long lastHB = 0;
int HBDelay = 1000;

void serialUpdate() {
  if(millis()>lastHB+HBDelay){
    serialHeartbeatLatch.countDown();
    lastHB = millis();
  }
  for (int i=0; i<numTouchPorts; i++) {
    while (touchSerial[i].available() > 0) {
      char inChar = touchSerial[i].readChar();
      if (inChar=='\n') {
        parseTouchString(touchBuffer[i],teensyTouchID[i]);
        touchBuffer[i] = "";
      } else if (inChar!='\r') touchBuffer[i]+=inChar;
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
  }
}
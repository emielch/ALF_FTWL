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
      lastTouchHB[i] = millis();
      if (inChar=='\n') {
        parseTouchString(touchBuffer[i], teensyTouchID[i]);
        touchBuffer[i] = "";
      } else if (inChar!='\r') touchBuffer[i]+=inChar;
    }
  }

  if (faceSerial!=null) {
    while (faceSerial.available() > 0) {
      char inChar = faceSerial.readChar();
      lastLedHB[faceID] = millis();
      if (inChar!='.') parseHall(inChar);
    }
  }

  //receive heartbeats
  for (int i=0; i < numPorts; i++) {
    if (i==faceID) continue; // faceSerial is already checked before
    while (ledSerial[i].available() > 0) {
      char inChar = ledSerial[i].readChar();
      lastLedHB[i] = millis();
    }
  }

  for (int i=0; i < numPorts; i++) {
    if (millis() > lastLedHB[i]+1000 && frameCount>60) {
      println(millis(), "\tTEENSY ", teensyID[i], " LOST");
      try {
        ledSerial[i].stop();
        ledSerial[i] = new Serial(this, ledSerialPortName[i]);
        senderThreads.get(i).newPort(ledSerial[i]);
        if (i==faceID) faceSerial = ledSerial[i];
        lastLedHB[i] = millis()+1000;
        println(millis(), "\treconnected!");
      }
      catch(Throwable e) {
        println(millis(), "\terror reopening port");
      }
    }
  }

  for (int i=0; i<numTouchPorts; i++) {
    if (millis() > lastTouchHB[i]+1000 && frameCount>60) {
      println(millis(), "\tTOUCH TEENSY ", teensyTouchID[i], " LOST");
      try {
        touchSerial[i].stop();
        touchSerial[i] = new Serial(this, touchSerialPortName[i]);
        lastTouchHB[i] = millis()+1000;
        println(millis(), "\treconnected!");
      }
      catch(Throwable e) {
        println(millis(), "\terror reopening port");
      }
    }
  }
}


void serialHeartbeat() {  
  while (true) {
    //send heartbeats
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
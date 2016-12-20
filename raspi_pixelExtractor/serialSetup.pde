
int numPorts=0;  // the number of serial ports in use
int numTouchPorts = 0;
int maxPorts=11; // maximum number of serial ports

Serial[] ledSerial = new Serial[maxPorts];     // each port's actual Serial port
int[] teensyID = new int[maxPorts];
int[] maxLeds = new int[maxPorts];
long[] lastLedHB = new long[maxPorts];
String[] ledSerialPortName = new String[maxPorts];

Serial[] touchSerial = new Serial[maxPorts];     // each port's actual Serial port
int[] teensyTouchID = new int[maxPorts];
long[] lastTouchHB = new long[maxPorts]; // last time a touch signal was received
String[] touchSerialPortName = new String[maxPorts];
String[] touchBuffer = new String[maxPorts];

Serial faceSerial = null;
int faceID = -1;


void serialSetup() {
  String[] list = Serial.list();
  delay(20);
  println("Serial Ports List:");
  println((Object)list);
  for (int i=0; i<list.length; i++) {
    if (list[i].equals("/dev/ttyAMA0")) continue;
    //if(!list[i].substring(0,10).equals("/dev/tty.u")) continue;
    serialConfigure(list[i]);
  }
  println();
  if (numPorts == 0) {
    println("No Teensy's found");
  }
}

// ask a Teensy board for its LED configuration, and set up the info for it.
void serialConfigure(String portName) {
  Serial newSerial = null;
  if (numPorts+numTouchPorts >= maxPorts) {
    println("too many serial ports, please increase maxPorts");
    return;
  }
  try {
    newSerial = new Serial(this, portName);
    if (newSerial == null) throw new NullPointerException();
    newSerial.write('?');
    delay(150);
    newSerial.readString();

    newSerial.write('?');
  } 
  catch (Throwable e) {
    println("Serial port " + portName + " does not exist or is non-functional");
    return;
  }
  int startWait = millis();
  while (newSerial.available() == 0) {
    if (millis()>startWait+500) break;
  }
  String line = newSerial.readStringUntil(10);
  if (line == null) {
    println("Serial port " + portName + " is not responding.");
    println("Is it really a Teensy 3.0 running VideoDisplay?");
    return;
  }
  String param[] = line.split(",");
  if (param.length != 3) {
    println(line);
    println("Error: port " + portName + " did not respond to LED config query");
    return;
  }

  int ID = Integer.parseInt(param[0]);
  // only store the info and increase numPorts if Teensy responds properly


  if (ID<100) {
    if(ID==7){
      faceSerial = newSerial;
      faceID = numPorts;
      println("FACE_TEENSY found!");
    }
    
    ledSerial[numPorts] = newSerial;
    teensyID[numPorts] = ID;
    maxLeds[numPorts] = Integer.parseInt(param[1]);
    ledSerialPortName[numPorts] = portName;

    SenderThread newSender = new SenderThread("teensyIDSender:"+teensyID[numPorts], ledSerial[numPorts], maxLeds[numPorts]);
    senderThreads.add(newSender);

    mappedData.add(new byte[(maxLeds[numPorts] * 8 * 3) + ledDataOffset]);

    println(numPorts+1, "teensy: " + portName + " added, id: " + teensyID[numPorts], ", maxLeds: ", + maxLeds[numPorts]   );
    numPorts++;
  } else {
    touchSerial[numTouchPorts] = newSerial;
    teensyTouchID[numTouchPorts] = ID;
    touchSerialPortName[numTouchPorts] = portName;
    touchBuffer[numTouchPorts] = "";
    println(numTouchPorts+1, "TOUCH_Teensy: " + portName + " added, id: " + teensyTouchID[numTouchPorts]   );
    numTouchPorts++;
  }
}

void closeConnections() {
  for (int i=0; i<numPorts; i++) {
    ledSerial[i].stop();
  }
  for (int i=0; i<numTouchPorts; i++) {
    touchSerial[i].stop();   // send heartbeat
  }
  println("closed connections");
}
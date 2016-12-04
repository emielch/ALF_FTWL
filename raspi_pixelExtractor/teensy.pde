import processing.serial.*;

float gamma = 1.7;

int numPorts=0;  // the number of serial ports in use
int maxPorts=24; // maximum number of serial ports


Serial[] ledSerial = new Serial[maxPorts];     // each port's actual Serial port
int[] ledTeensyID = new int[maxPorts];
int[] maxLeds = new int[maxPorts];
int[] gammatable = new int[256];
int errorCount=0;

volatile byte[] teensySendState = new byte[maxPorts];

void teensySetup() {
  String[] list = Serial.list();
  delay(20);
  println("Serial Ports List:");
  println((Object)list);
  for (int i=0; i<list.length; i++){
    if(list[i].equals("/dev/ttyAMA0")) continue;
    serialConfigure(list[i]);
  }
  if (numPorts == 0){
    println("No Teensy's found");
    exit();
  }

  for (int i=0; i < 256; i++) {
    gammatable[i] = (int)(pow((float)i / 255.0, gamma) * 255.0 + 0.5);
  }
  
  for (int i=0; i<maxPorts; i++){
    teensySendState[i] = 3;
  }
  
}

// ask a Teensy board for its LED configuration, and set up the info for it.
void serialConfigure(String portName) {
  if (numPorts >= maxPorts) {
    println("too many serial ports, please increase maxPorts");
    errorCount++;
    return;
  }
  try {
    ledSerial[numPorts] = new Serial(this, portName);
    if (ledSerial[numPorts] == null) throw new NullPointerException();
    ledSerial[numPorts].write('?');
  } 
  catch (Throwable e) {
    println("Serial port " + portName + " does not exist or is non-functional");
    errorCount++;
    return;
  }
  delay(50);
  String line = ledSerial[numPorts].readStringUntil(10);
  if (line == null) {
    println("Serial port " + portName + " is not responding.");
    println("Is it really a Teensy 3.0 running VideoDisplay?");
    errorCount++;
    return;
  }
  String param[] = line.split(",");
  if (param.length != 3) {
    println("Error: port " + portName + " did not respond to LED config query");
    errorCount++;
    return;
  }
  // only store the info and increase numPorts if Teensy responds properly
  ledTeensyID[numPorts] = Integer.parseInt(param[0]);
  maxLeds[numPorts] = Integer.parseInt(param[1]);
  
  println("teensy: " + portName + " added, id: " + ledTeensyID[numPorts], ", maxLeds: ", + maxLeds[numPorts]   );
  
  numPorts++;
}

void mesh2data(byte[] data, int offset, int teensyID){
  int pixel[] = new int[8];
  int mask;
  
  Segment currentS[] = new Segment[8];
  arrayCopy(teensies[teensyID].channel, currentS);
  int currentLED[] = {0,0,0,0,0,0,0,0};
  
  for(int i = 0; i < maxLeds[teensyID]; i++){
    
    for(int j = 0; j < 8; j++){
      if(currentS[j] == null) pixel[j] = 0;
      else{
        LED l = currentS[j].leds[currentLED[j]];
        pixel[j] = get(l.posX,l.posY);
        pixel[j] = colorWiring(pixel[j]);
        
        if(i == 0 && j == 0) println(red(pixel[j]));
        //This was the last LED, switch to next segment
        if(++currentLED[j] == currentS[j].leds.length){
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

// image2data converts an image to OctoWS2811's raw data format.
// The number of vertical pixels in the image must be a multiple
// of 8.  The data array must be the proper size for the image.
void image2data(byte[] data, int offset, int teensyID) {
  int x, y, mask;
  int pixel[] = new int[8];

  for (int l = 0; l < maxLeds[teensyID]; l++) {

    for (int i=0; i < 8; i++) {
      // fetch 8 pixels from the image, 1 for each pin
      pixel[i] = color(hue,100,10);
      pixel[i] = colorWiring(pixel[i]);
    }
    
    // convert 8 pixels to 24 bytes
    for (mask = 0x800000; mask != 0; mask >>= 1) {
      byte b = 0;
      for (int i=0; i < 8; i++) {
        if ((pixel[i] & mask) != 0) b |= (1 << i);
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
  //red = gammatable[red];
  //green = gammatable[green];
  //blue = gammatable[blue];
  return (green << 16) | (red << 8) | (blue); // GRB - most common wiring
}
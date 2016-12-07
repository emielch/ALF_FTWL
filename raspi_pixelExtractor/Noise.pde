//Fills the background with perlin noise
void bgNoise(color c, float speed){
  float r = c >> 16 & 0xFF;
  float g = c >> 8 & 0xFF;
  float b = c & 0xFF;
  colorMode(RGB, 255);
  for(int si = 0; si < segments.size(); si++){
    Segment s = segments.get(si);
    for(int li = 0; li < s.leds.length; li++){
      LED l = s.leds[li];
      float n = noise(l.posX*0.04,l.posY*0.04,speed*millis());
      set(l.posX,l.posY, color(r*n, g*n, b*n));
    }
  }
}
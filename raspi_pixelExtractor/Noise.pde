//Fills the background with perlin noise
void bgNoise(color c, float speed){
  float r = c >> 16 & 0xFF;
  float g = c >> 8 & 0xFF;
  float b = c & 0xFF;
  colorMode(RGB, 255);
  for(int x = 0; x < width; x++){
    for(int y = 0; y < height; y++){
      float n = noise(x,y,speed*millis());
      set(x,y, color(r*n, g*n, b*n));
    }
  }
}
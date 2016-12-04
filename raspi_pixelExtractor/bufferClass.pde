

class ledBuffer{
  volatile byte[] ledData;
  
  ledBuffer(int s){
    ledData =  new byte[s];
  }
}
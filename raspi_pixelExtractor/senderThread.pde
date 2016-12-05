import java.util.concurrent.CountDownLatch;

class SenderThread extends Thread {
  private Thread t;
  private String name;
  Serial port;
  int ledAm;

  byte[] sendBuffer;
  byte[] writeBuffer;

  volatile boolean writeLock;
  volatile boolean writeFilled;

  CountDownLatch writeLatch;
  CountDownLatch sendLatch;

  boolean sendState; // true = send data, false = send sync

  SenderThread( String _name, Serial _port, int _ledAm) {
    name = _name;
    port = _port;
    ledAm = _ledAm;
    sendBuffer =  new byte[(ledAm * 8 * 3) + ledDataOffset];
    writeBuffer =  new byte[(ledAm * 8 * 3) + ledDataOffset];
    writeLock = false;
    writeFilled = false;

    writeLatch = new CountDownLatch(1);
  }

  public byte[] getWriteBuffer() {
    if (writeLock) {
      writeLatch = new CountDownLatch(1);
      latchWait(writeLatch);
    }
    writeLock = true;
    return writeBuffer;
  }
  
  public void setWriteFilled(){
    writeFilled = true;
    writeLatch.countDown();
  }

  void switchBuffers() {
    byte[] switchBuffer = sendBuffer;
    sendBuffer = writeBuffer;
    writeBuffer = switchBuffer;
    writeLock = false;
    writeFilled = false;
    writeLatch.countDown();
  }

  public void run() {
    if (sendState) {
      switchBuffers();
      port.write(sendBuffer);
    } else {
      port.write('*');
    }
    sendLatch.countDown();
  }

  public void sendData (CountDownLatch latch) {
    if (!writeFilled) { // wait till there is new data in the write buffer to send
      writeLatch = new CountDownLatch(1);
      latchWait(writeLatch);
    }

    sendLatch = latch;
    if (!isAlive()) {
      t = new Thread (this, name);
      sendState = true;
      t.start ();
    }
  }

  public void sendSync (CountDownLatch latch) {

    sendLatch = latch;
    if (!isAlive()) {
      t = new Thread (this, name);
      sendState = false;
      t.start ();
    }
  }
}
import java.util.concurrent.CountDownLatch;

class SenderThread extends Thread {
  private Thread t;
  private String name;
  Serial port;
  int ledAm;

  byte[] sendBuffer;
  byte[] writeBuffer;

  volatile boolean toDo;
  volatile char task;
  volatile boolean sleeping;
  volatile boolean running=true;

  CountDownLatch currentLatch;


  SenderThread( String _name, Serial _port, int _ledAm) {
    name = _name;
    port = _port;
    ledAm = _ledAm;
    sendBuffer =  new byte[(ledAm * 8 * 3) + ledDataOffset];

    currentLatch = new CountDownLatch(1);


    if (!isAlive()) {
      t = new Thread (this, name);
      //sendState = true;
      t.start ();
    }
  }

  public void newPort(Serial _port) {
    port = _port;
  }

  public void writeBuffer(byte[] data) {
    sendBuffer=data.clone();
  }


  public void run() {
    log("SenderThread ", name, " is running");
    
    while (running) {
      if (toDo) {
        try {
          if (task=='s') {
            port.write(sendBuffer);
            iamDone('s');
          } else if (task=='d') {
            port.write('*');
            iamDone('d');
          }
        }
        catch(Exception e) {
          log("error on writing to serial. exiting the program?");
        }
      }
      
      try {
        sleeping=true;
        Thread.sleep(150);
        sleeping=false;
      }
      catch(InterruptedException e) {
        sleeping=false;
      }
    }
  }

  private void iamDone(char taskIn) {
    if (taskIn!=task) {
      log("Something is seriously wrong the thread finished a task it was not supposed to do");
      halt();
    }
    toDo=false;
    currentLatch.countDown();
  }


  public void sendData (CountDownLatch latch) {
    if (toDo==true) {
      log("stopping we are not yet done with the previous thing .. trying to send now");
      return;
    }
    task='s';
    toDo=true;
    currentLatch = latch;
    if (sleeping) {
      t.interrupt();
    }
  }


  public void sendSync (CountDownLatch latch) {
    if (toDo==true) {
      log("stopping we are not yet done with the previous thing .. trying to sync now");
      return;
    }

    task='d';
    toDo=true;
    currentLatch = latch;
    if (sleeping) {
      t.interrupt();
    }
  }


  public void halt() {
    running=false;
    if (sleeping) {
      t.interrupt();
    }
    port.clear();
    port.stop();
  }
}
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


  //boolean sendState; // true = send data, false = send sync

  SenderThread( String _name, Serial _port, int _ledAm) {
    name = _name;
    port = _port;
    ledAm = _ledAm;
    sendBuffer =  new byte[(ledAm * 8 * 3) + ledDataOffset];
    writeBuffer =  new byte[(ledAm * 8 * 3) + ledDataOffset];


    currentLatch = new CountDownLatch(1);


    if (!isAlive()) {
      t = new Thread (this, name);
      //sendState = true;
      t.start ();
    }
  }
  
  void newPort(Serial _port){
    port = _port;
  }

  public void writeBuffer(byte[] data) {
    sendBuffer=data.clone();
  }



  public void run() {
    println("we are running");
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
          println("error on writing to serial. exiting the program?");
        }
      }
      try {
        //println("nothing to do sleeping now");
        sleeping=true;
        Thread.sleep(150);
        sleeping=false;
        //println("done sleeping, lets see");
      }
      catch(InterruptedException e) {
        // println("got interputed");
        sleeping=false;
      }
    }
  }
  private void iamDone(char taskIn) {
    if (taskIn!=task) {

      println("Something is seriously wrong the thread finished a task it was not supposed to do");
      halt();
    }
    toDo=false;
    currentLatch.countDown();
  }


  public void sendData (CountDownLatch latch) {
    if (toDo==true) {
      println("stopping we are not yet done with the previous thing .. trying to send now");
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
      println("stopping we are not yet done with the previous thing .. trying to sync now");
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
    //t.join();
    port.clear();
    port.stop();
  }
}
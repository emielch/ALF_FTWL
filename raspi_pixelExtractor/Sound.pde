import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer bgLoop;
AudioSample voiceSample[][];
AudioSample touchSample[][];

void setupSound(){
  minim = new Minim(this);
  bgLoop = minim.loadFile("bgLoop.wav");
  bgLoop.loop();
  
  //Load all samples in for loops
  
}
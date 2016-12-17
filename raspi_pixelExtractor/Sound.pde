import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer bgLoop;
int voiceN = 8;
int touchN = 15;
AudioSample voiceSample[] = new AudioSample[voiceN];
AudioSample touchSample[] = new AudioSample[touchN];
int touchTriggered[] = new int[touchN];
float voiceGain = 0; //in dB, minus for attennuation
float touchGain = 0;

void setupSound(){
  minim = new Minim(this);
  bgLoop = minim.loadFile("bgLoop.wav");
  bgLoop.loop();
  
  //Load all samples
  for(int i = 0; i<touchN; i++){
    touchSample[i] = minim.loadSample("interact/"+String.format("%02d",i)+".wav");
    touchSample[i].setGain(touchGain);
  }
  for(int i = 0; i<voiceN; i++){
    voiceSample[i] = minim.loadSample("voices/voice"+String.format("%02d",i)+".wav");
    voiceSample[i].setGain(voiceGain);
  }
  
}
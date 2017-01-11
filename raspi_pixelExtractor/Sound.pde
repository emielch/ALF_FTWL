import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer bgLoop;
int voiceN = 8;
int touchN = 15;
AudioSample voiceSample[] = new AudioSample[voiceN];
AudioPlayer touchSound[] = new AudioPlayer[touchN];
float voiceGain = -80; //in dB, minus for attennuation, range: (-80.0 to +6.0206)
float touchGain = -80;
float minTouchGain = -60;
float fadeStep = 0.5;

void setupSound(){
  minim = new Minim(this);
  bgLoop = minim.loadFile("bgLoop.wav");
  bgLoop.loop();
  
  //Load all samples
  for(int i = 0; i<touchN; i++){
    touchSound[i] = minim.loadFile("interact/"+String.format("%02d",i+1)+".wav");
    touchSound[i].setGain(minTouchGain);
    touchSound[i].loop();
  }
  for(int i = 0; i<voiceN; i++){
    voiceSample[i] = minim.loadSample("voices/voice"+String.format("%02d",i)+".wav");
    voiceSample[i].setGain(voiceGain);
  }
}

void fadeOutTouchSounds(){
  for(int i = 0; i < touchN; i++){
    float g = touchSound[i].getGain();
    if(g > minTouchGain) touchSound[i].setGain(g-fadeStep);
  }
}
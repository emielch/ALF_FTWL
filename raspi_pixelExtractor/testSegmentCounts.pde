int timePerSegment = 1000;
int lastUpdate = 0;

Segment currentS[] = new Segment[8];

void testSegmentCounts(int tid){
  if(millis() > lastUpdate + timePerSegment){
    background(0);
    for(int i = 0; i < 8; i++){
      if(currentS[i] == null) currentS[i] = teensies[tid].channel[i];
      else{ 
        currentS[i] = currentS[i].next;
        if(currentS[i] == null) currentS[i] = teensies[tid].channel[i];
      }
      for(int j = 0; j < currentS[i].leds.length; j++){
        LED l = currentS[i].leds[j];
        set(l.posX, l.posY, color(255,255,255));
      }
    }
    lastUpdate = millis();
  }
}
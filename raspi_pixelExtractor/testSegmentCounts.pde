int timePerSegment = 1000;
int lastUpdate = 0;

Segment currentS[] = new Segment[8];

void testSegmentCounts(int tid){
  //if(millis() > lastUpdate + timePerSegment){
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
  //}
}

void testChannelLocations(int tid, int cid){
    background(0);
    Teensy t = teensies[tid];
    Segment s = t.channel[cid];
    for(int i = 0; i < 100; i++){
      for(int j = 0; j < s.leds.length; j++){
        LED l = s.leds[j];
        set(l.posX,l.posY,color(255));
      }
      s = s.next;
      if(s == null) break;
    }
}
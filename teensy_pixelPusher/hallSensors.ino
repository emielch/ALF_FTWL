
#if TEENSY_ID == 7

void sendHallState(byte hallID, boolean rising) {   // send 0-2 for falling edges, 3-5 for rising edges
  if (rising) hallID += HALL_AM;
  Serial.print(hallID);
}

#endif




#if TEENSY_ID == 10
void isrRise0() {
  sendHallState(0, true);
}

void isrRise1() {
  sendHallState(1, true);
}

void isrRise2() {
  sendHallState(2, true);
}

void isrFall0() {
  sendHallState(0, false);
}

void isrFall1() {
  sendHallState(1, false);
}

void isrFall2() {
  sendHallState(2, false);
}


void sendHallState(byte hallID, boolean rising) {   // send 0-2 for falling edges, 3-5 for rising edges
  if (rising) hallID += HALL_AM;
  Serial.print(hallID);
}

#endif



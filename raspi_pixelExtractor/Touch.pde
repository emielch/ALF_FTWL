
FloatList touchPos = new FloatList();
float touchBarWidth = 532./2;


void parseTouchString(String s, int id) {
  try {
    touchPos.clear();
    String touchLocs[] = s.split("\t");
    for (int i=0; i<touchLocs.length; i++) {
      if (touchLocs[i]!="") {
        float pos = Float.parseFloat(touchLocs[i]);
        if (id==100) pos = 1-pos;
        pos = 712+pos*touchBarWidth;
        if (id==101) pos+=touchBarWidth;
        touchPos.append(pos);
      }
    }
  }
  catch(Exception e) {
    log("error parsing touch string");
  }
}


void drawTouch() {
  for (int i=0; i<touchPos.size(); i++) {
    float pos = touchPos.get(i);
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
    fill(255);  // Set fill to gray
    ellipse(pos, 500, 30, 30);
  }
}
ArrayList<Segment> segments = new ArrayList<Segment>();

static final int TEENSY_NUMBER = 7;
Teensy[] teensies = new Teensy[TEENSY_NUMBER];

PGraphics mask;

void importMesh(String filename){
  
  JSONObject json = loadJSONObject(filename);
  
  JSONArray ss = json.getJSONArray("segments");
  segments = new ArrayList<Segment>();
  for(int i = 0; i < ss.size(); i++){
    segments.add(new Segment(ss.getJSONObject(i)));
  }
  for(Segment s : segments){ 
    s.updateSegments();
  }
  
  JSONArray ts = json.getJSONArray("teensies");
  for(int i = 0; i < teensies.length; i++){
    teensies[i] = new Teensy(ts.getJSONObject(i));
  } 
  
}

void createMeshMask(){  
  PGraphics black = createGraphics(width,height,P2D);
  black.beginDraw();
  black.background(0);
  black.endDraw();
  
  mask = createGraphics(width, height, P2D);
  
  mask.beginDraw();
  mask.background(255);
  mask.stroke(0);
  mask.strokeWeight(2);
  for(Segment s : segments){
    mask.line(s.startX, s.startY, s.endX, s.endY);
  }
  
  mask.endDraw(); 
  
  black.mask(mask);
  
  mask = black;
}

void maskMesh(){
  imageMode(CORNER);
  image(mask,0,0);
}

class Teensy{
  Segment channel[] = new Segment[8];
  
  Teensy(){
  }
  
  Teensy(JSONObject json){
    fromJson(json);
  }
  
  int LEDCount(int c){
    if(channel[c] == null) return 0;
    Segment s = channel[c];
    int count = s.ledN;
    while(s.next != null){
      s = s.next;
      count += s.ledN;
    }
    return count;
  }
  
  JSONObject toJson(){
    JSONObject out = new JSONObject();
    
    JSONArray ch = new JSONArray();
    for(int i = 0; i<8; i++){
      ch.append(segments.indexOf(channel[i]));
      //if(i == 0) println(segments.indexOf(channel[i]));
    }
    out.setJSONArray("chi", ch);
    
    return out;
  }
  
  void fromJson(JSONObject json){
    for(int i = 0; i < 8; i++){
      int j = json.getJSONArray("chi").getInt(i);
      if(j >= 0){ 
        channel[i] = segments.get(j);
      }
    }    
  }  
}

//Contains variables & methods for each segment of LEDs

class Segment{
  int startX, startY, endX, endY, ledN;
  
  //The indices of the segments above, these can actually be serialized
  Segment next;
  int nexti = -1;
  Segment[] sn = new Segment[2];
  Segment[] en = new Segment[2];
  
  int[] sni = {-1,-1};
  int[] eni = {-1,-1};
  
  LED[] leds;
  
  //For calculating distance to this segment
  float d, ca, sa;
  
  Segment(JSONObject json){
    fromJson(json);
  }
  
  float getDistance(float x, float y){
    float mx = (-startX+x)*ca + (-startY+y)*sa;
    
    if(mx <= 0) return dist(x,y,startX,startY);
    else if(mx >= d) return dist(x,y,endX,endY);
    else return dist(x, y, startX+mx*ca, startY+mx*sa);
  }
  
  //Convert indices to Segments again
  void updateSegments(){
    for(int i = 0; i<2; i++){
      if(sni[i] != -1) sn[i] = segments.get(sni[i]);
      if(eni[i] != -1) en[i] = segments.get(eni[i]);
    }
    if(nexti != -1) next = segments.get(nexti);
  }
  
  JSONObject toJson(){
    JSONObject out = new JSONObject();
    
    out.setInt("startX", startX);
    out.setInt("startY", startY);
    out.setInt("endX", endX);
    out.setInt("endY", endY);
    out.setInt("ledN", ledN);
    out.setInt("nexti", segments.indexOf(next));
    
    JSONArray t = new JSONArray();
    t.append(segments.indexOf(sn[0]));
    t.append(segments.indexOf(sn[1]));
    out.setJSONArray("sni", t);
    t = new JSONArray();
    t.append(segments.indexOf(en[0]));
    t.append(segments.indexOf(en[1]));
    out.setJSONArray("eni", t);
    
    t = new JSONArray();
    for(int i = 0; i<leds.length; i++){
      t.append(leds[i].toJson());
    }
    out.setJSONArray("leds", t);
    
   // out.setBoolean("selected", selected);
    out.setFloat("d", d);
    out.setFloat("ca", ca);
    out.setFloat("sa", sa);
    
    return out;
  }
  
  void fromJson(JSONObject json){
    startX = json.getInt("startX");
    startY = json.getInt("startY");
    endX = json.getInt("endX");
    endY = json.getInt("endY");
    ledN = json.getInt("ledN");
    
    nexti = json.getInt("nexti");
    sni = json.getJSONArray("sni").getIntArray();
    eni = json.getJSONArray("eni").getIntArray();
    
    leds = new LED[ledN];
    JSONArray t = json.getJSONArray("leds");
    for(int i = 0; i<ledN; i++){
      leds[i] = new LED(t.getJSONObject(i));
    }
    
  //  selected = json.getBoolean("selected");
    d = json.getFloat("d");
    ca = json.getFloat("ca");
    sa = json.getFloat("sa");
  }
}

class LED{
  int posX, posY;
  
  LED(int posX, int posY){
    this.posX = posX;
    this.posY = posY;
  }
  
  LED(JSONObject json){
    fromJson(json);
  }
  
  JSONObject toJson(){
    JSONObject out = new JSONObject();
    
    out.setInt("posX", posX);
    out.setInt("posY", posY);
    
    return out;
  }
  
  void fromJson(JSONObject json){
    
    posX = json.getInt("posX");
    posY = json.getInt("posY");
    
  }
}
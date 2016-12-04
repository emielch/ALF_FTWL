ArrayList<Segment> segments = new ArrayList<Segment>();

static final int TEENSY_NUMBER = 7;
Teensy[] teensies = new Teensy[TEENSY_NUMBER];

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
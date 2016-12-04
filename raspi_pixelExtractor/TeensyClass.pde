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
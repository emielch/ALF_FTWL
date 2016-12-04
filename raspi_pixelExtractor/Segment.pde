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
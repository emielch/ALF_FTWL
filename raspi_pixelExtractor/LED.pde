PImage LED_Sprite;

class LED{
  int posX, posY;
  color c;
  
  LED(int posX, int posY){
    this.posX = posX;
    this.posY = posY;
  }
  
  LED(JSONObject json){
    fromJson(json);
  }
  
  void draw(){
    imageMode(CENTER);
    tint(c);
    image(LED_Sprite, posX, posY);
  }
  
  void setColor(int r, int g, int b, int a){
    c = color(r,g,b,a);
  }
  
  void setColor(color c){
    this.c = c;
  }
  
  JSONObject toJson(){
    JSONObject out = new JSONObject();
    
    out.setInt("posX", posX);
    out.setInt("posY", posY);
    out.setInt("c", c);
    
    return out;
  }
  
  void fromJson(JSONObject json){
    
    posX = json.getInt("posX");
    posY = json.getInt("posY");
    c = json.getInt("c");
    
  }
}
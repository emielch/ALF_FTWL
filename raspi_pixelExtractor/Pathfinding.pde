//Returns the direction a pulse should travel a segment when coming from another segment. 1 for start to end, -1 for reverse. 0 if segments are not neighbours
int getDir(Segment from, Segment to){
  if(to.sn[0] == from || to.sn[1] == from) return 1;
  else if(to.en[0] == from || to.en[1] == from) return -1;
  return 0;
}

//Returns a path of segments that leads to the closest point to the target marked by tx and ty. [dir] gives the direction in which the first segment is travelled
Segment[] getPath (Segment from, int tx, int ty, int dir){
  ArrayList<Segment> path = new ArrayList<Segment>();
  
  Segment s = from;
  path.add(from);
  
  for(int i = 0; i < 100; i++){ //For loop since we don't want to have a chance of being stuck in a while. 100 segments should be enough to reach the goal
    if(dir > 0){
      float curDist = dist(s.endX, s.endY, tx, ty);
      if(s.en[0] == null && s.en[1] == null){
        if(dist(s.startX, s.startY, tx, ty) > curDist && dist(s.startX, s.startY, tx, ty) > curDist) break;
        path.add(s);
        dir = -dir;
      }
      else if(s.en[0] == null){
        dir = getDir(s, s.en[1]);
        if(dir > 0){
          if(dist(s.en[1].endX, s.en[1].endY, tx, ty) > curDist && dist(s.startX, s.startY, tx, ty) > curDist) break;
        }
        else if(dist(s.en[1].startX, s.en[1].startY, tx, ty) > curDist && dist(s.startX, s.startY, tx, ty) > curDist) break;
        path.add(s.en[1]);
        s = s.en[1];
      }
      else if(s.en[1] == null){
        dir = getDir(s, s.en[0]);
        if(dir > 0){
          if(dist(s.en[0].endX, s.en[0].endY, tx, ty) > curDist && dist(s.startX, s.startY, tx, ty) > curDist) break;
        }
        else if(dist(s.en[0].startX, s.en[0].startY, tx, ty) > curDist && dist(s.startX, s.startY, tx, ty) > curDist) break;
        path.add(s.en[0]);
        s = s.en[0];
      }
      else{
        float[] dist = new float[2];
        
        for(int j = 0; j < 2; j++){
          int d = getDir(s, s.en[j]);
          if(d > 0) dist[j] = dist(s.en[j].endX, s.en[j].endY, tx, ty);
          else dist[j] = dist(s.en[j].startX, s.en[j].startY, tx, ty);
        }
                
        if(dist[0] > curDist && dist[1] > curDist && dist(s.startX, s.startY, tx, ty) > curDist) break;
        
        dist[0] = curDist - dist[0];
        dist[1] = curDist - dist[1];
        
        float prob;
        if(dist[0] > 0 && dist[1] > 0) prob = dist[0]/(dist[0]+dist[1]);
        else if(dist[0] < 0 && dist[1] < 0) prob = 1-dist[0]/(dist[0]+dist[1]);
        else if(dist[0] < 0) prob = 1-(0.5+0.5*(dist[1]/(dist[1]-dist[0])));
        else prob = (0.5+0.5*(dist[0]/(dist[0]-dist[1])));
        
        //float prob = dist[0]/(dist[0]+dist[1]);
        if(random(1) < prob){ 
          dir = getDir(s, s.en[0]);
          path.add(s.en[0]);
          s = s.en[0];
        }
        else{ 
          dir = getDir(s, s.en[1]);
          path.add(s.en[1]);
          s = s.en[1];
        }
      }       
    }
    else{
      float curDist = dist(s.startX, s.startY, tx, ty);
      if(s.sn[0] == null && s.sn[1] == null){
        if(dist(s.endX, s.endY, tx, ty) > curDist && dist(s.endX, s.endY, tx, ty) > curDist) break;
        path.add(s);
        dir = -dir;
      }
      else if(s.sn[0] == null){
        dir = getDir(s, s.sn[1]);
        if(dir > 0){
          if(dist(s.sn[1].endX, s.sn[1].endY, tx, ty) > curDist && dist(s.endX, s.endY, tx, ty) > curDist) break;
        }
        else if(dist(s.sn[1].startX, s.sn[1].startY, tx, ty) > curDist && dist(s.endX, s.endY, tx, ty) > curDist) break;
        path.add(s.sn[1]);
        s = s.sn[1];
      }
      else if(s.sn[1] == null){
        dir = getDir(s, s.sn[0]);
        if(dir > 0){
          if(dist(s.sn[0].endX, s.sn[0].endY, tx, ty) > curDist && dist(s.endX, s.endY, tx, ty) > curDist) break;
        }
        else if(dist(s.sn[0].startX, s.sn[0].startY, tx, ty) > curDist && dist(s.endX, s.endY, tx, ty) > curDist) break;
        path.add(s.sn[0]);
        s = s.sn[0];
      }
      else{
        float[] dist = new float[2];
        
        for(int j = 0; j < 2; j++){
          int d = getDir(s, s.sn[j]);
          if(d > 0) dist[j] = dist(s.sn[j].endX, s.sn[j].endY, tx, ty);
          else dist[j] = dist(s.sn[j].startX, s.sn[j].startY, tx, ty);
        }
                
        if(dist[0] > curDist && dist[1] > curDist && dist(s.endX, s.endY, tx, ty) > curDist) break;
        
        dist[0] = curDist - dist[0];
        dist[1] = curDist - dist[1];
        
        float prob;
        if(dist[0] > 0 && dist[1] > 0) prob = dist[0]/(dist[0]+dist[1]);
        else if(dist[0] < 0 && dist[1] < 0) prob = 1-dist[0]/(dist[0]+dist[1]);
        else if(dist[0] < 0) prob = 1-(0.5+0.5*(dist[1]/(dist[1]-dist[0])));
        else prob = (0.5+0.5*(dist[0]/(dist[0]-dist[1])));
        
        //float prob = dist[0]/(dist[0]+dist[1]);
        if(random(1) < prob){ 
          dir = getDir(s, s.sn[0]);
          path.add(s.sn[0]);
          s = s.sn[0];
        }
        else{ 
          dir = getDir(s, s.sn[1]);
          path.add(s.sn[1]);
          s = s.sn[1];
        }
      }
    }
  }
  
  Segment[] result = new Segment[path.size()];
  return path.toArray(result);
}
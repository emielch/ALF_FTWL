PrintWriter logger;

void setupLog(){
  logger = createWriter("logs/"+day()+"-"+month()+" "+hour()+"-"+minute()+"-"+second()+".log");
}

void log(String... strings){
  print("["+hour()+":"+minute()+":"+second()+"] ");
  logger.print("["+hour()+":"+minute()+":"+second()+"] ");
  for(int i = 0; i<strings.length; i++){ 
    print(strings[i]);
    logger.print(strings[i]);
  }
  println();
  logger.println();
  logger.flush();
}
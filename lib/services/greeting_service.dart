String getGreeting(){
  DateTime now = DateTime.now();
  if(now.hour<12){
    return "Good Morning!";
  }else if(now.hour>=12 && now.hour<16){
    return "Good Afternoon!";
  }else{
    return "Good Evening!";
  }
}
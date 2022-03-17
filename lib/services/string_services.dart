class StringServices{

  static List<String> splitStringToList(String inputString,int quanta){

    List<String> splitString=[];

    List<String> characters=[];

    for(int i=0;i<inputString.length;i++){
      characters.add(inputString[i]);
      if((i+1)%quanta==0 || i==inputString.length-1){
        splitString.add(characters.join());
        characters.clear();
      }
    }

    return splitString;
  }

}
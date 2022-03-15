class AssetMapping{
  static Map<String,String> businessIconPathMap={
    "activision":"activision.png",
    "epic":"epic-games.png",
    "facebook":"facebook.png",
    "github":"github.png",
    "google":"google.png",
    "gmail":"google.png",
    "instagram":"instagram.png",
    "line":"line.png",
    "linkedin":"linkedin.png",
    "microsoft":"microsoft.png",
    "ola":"ola.png",
    "reddit":"reddit.png",
    "slack":"slack.png",
    "snapchat":"snapchat.png",
    "telegram":"telegram.png",
    "whatsapp":"whatsapp.png",
    "xiaomi":"xiaomi.png",
    "mi":"xiaomi.png",
    "yahoo":"yahoo.png",
    "steam":"steam.png",
    "twitter":"twitter.png",
    "no_company":"no_company.png",
  };

  static String getBusinessIconPath(String businessName){
    String cleanedBusinessName=businessName.replaceAll(" ", "").trim().toLowerCase();
    final Iterable<String> keys=businessIconPathMap.keys;
    for(final key in keys){
      if(cleanedBusinessName.contains(key)){
        return businessIconPathMap[key]!;
      }
    }
    return businessIconPathMap["no_company"]!;

  }

}
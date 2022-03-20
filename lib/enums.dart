enum CounterAction{
  add,
  subtract
}

enum Screen{
  home,
  settings
}

enum CloudAccountType{
  none,
  google,
  apple,
  github,
}

enum CloudSyncType{
  localLatest,
  cloudLatest,
  inSync,
}

enum CloudSyncStatus{
  success,
  encryptionPasswordNotSet,
  notSignedIn,
  networkError,
}
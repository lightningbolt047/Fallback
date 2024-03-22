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

enum KeysInputType{
  add,
  edit,
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
  userCancelled,
  wrongEncryptionPassword,
}
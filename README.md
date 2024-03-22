<div align="center">
    <img src="readme_assets/fallback_squircle_logo.png" alt="logo" width="150" height="150"/>
    <h1>Fallback</h1>
</div>

Downloads from GitHub Releases: ![Downloads](https://img.shields.io/github/downloads/lightningbolt047/Fallback/total)

<div>
    <h2>About</h2>
    <p>An application you "Fallback" to when you don't have access to your 2FA codes. Fallback is built using Flutter and follows Material Design 3. The Android app is now available on <a href="https://play.google.com/store/apps/details?id=com.lightning.fallback">Google Play Store</a>.</p>
</div>

<div>
    <h2>What does it do?</h2>
    <p>Fallback lets you store and retrieve your backup keys. Stored keys are always encrypted and the user must use a biometric method to be able to view the keys</p>
</div>

<div>
    <h2>Features</h2>
    <ul>
        <li>Cloud Sync: Keys can be synced to the project's firestore and can be retrieved by the user anytime (even across devices)</li>
        <li>Local Backups: Users who don't want to or can't use Cloud Sync can also make backups and restore their keys.</li>
        <li>Fully Encrypted: Keys are fully encrypted at all times. Keys are encrypted using the password that the user sets which is then synced to the cloud or stored as a local backup. Users cannot use cloud sync or make local backups without setting their encryption password.</li>
        <li>Data Deletion: You can delete all cloud synced data by disconnecting your account from the setting page</li>
    </ul>
</div>

<div>
    <h2>Requirements</h2>
    <ul>
        <li>
            Android 10+
        </li>
        <li>
            Biometric authentication of some sort (Mostly Fingerprint on Android since most Face Unlock implementations are not supported by this app). 
        </li>
        <li>
            GMS (Google Mobile Services) if you want to use Cloud Sync.
        </li>
    </ul>
</div>

<div>
    <h2>How do I download?</h2>
    <p>The app can be downloaded in two ways:</p>
    <ul>
        <li>Google Play Store: <a href="https://play.google.com/store/apps/details?id=com.lightning.fallback">Download</a>.</li>
        <li>Github Releases: For those who cannot or do not want to install from the Google Play Store can download the apk from this repo's releases. Do note that OTA updates do not work if the app is installed through this method and the user has to manually update the app.</li>
    </ul>
</div>

<div>
    <img src="readme_assets/store_securely.png" alt="store_securely" width="253.333" height="506.666"/>
    <img src="readme_assets/cloud_sync.png" alt="store_securely" width="253.333" height="506.666"/>
    <img src="readme_assets/local_backups.png" alt="store_securely" width="253.333" height="506.666"/>
</div>


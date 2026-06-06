# Kakao Login Setup

## Required keys

- Kakao Developers > App > Platform keys > Native app key
- Optional for web later: JavaScript key

## Android setup

Add the Native app key to `android/local.properties`:

```properties
kakao.native_app_key=YOUR_NATIVE_APP_KEY
```

Android builds read this value and inject both the manifest redirect scheme and
the Flutter SDK runtime key:

```text
kakaoYOUR_NATIVE_APP_KEY://oauth
```

No `--dart-define` is required for Android Studio Run after this value is set.

If JavaScript key is needed later for web, pass it to Dart:

```sh
flutter run --dart-define=KAKAO_JAVASCRIPT_APP_KEY=YOUR_JAVASCRIPT_APP_KEY
```

Current Android package name for Kakao Developers:

```text
com.example.magicsorafront
```

## iOS URL scheme

Current iOS Bundle ID for Kakao Developers:

```text
com.example.magicsorafront
```

Copy the example file:

```sh
cp ios/Flutter/KakaoKeys.xcconfig.example ios/Flutter/KakaoKeys.xcconfig
```

Then edit `ios/Flutter/KakaoKeys.xcconfig`:

```xcconfig
KAKAO_NATIVE_APP_KEY_SCHEME=kakaoYOUR_NATIVE_APP_KEY
```

`ios/Flutter/KakaoKeys.xcconfig` is ignored by git.

## Kakao Developers console

- Enable Kakao Login.
- Register Android package name: `com.example.magicsorafront` unless the app id changes.
- Register debug/release key hashes.
- Register iOS Bundle ID: `com.example.magicsorafront` unless the bundle id changes.

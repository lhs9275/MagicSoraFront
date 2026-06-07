# Kakao Login Setup

## Required keys

- Kakao Developers > App > Platform keys > Native app key
- Optional for web later: JavaScript key

## Android setup

The shared Native app key is committed in `android/gradle.properties`:

```properties
kakao.native_app_key=YOUR_NATIVE_APP_KEY
```

Android builds read this value from `android/gradle.properties`, with optional
overrides from `android/local.properties` or the `KAKAO_NATIVE_APP_KEY`
environment variable. It injects both the manifest redirect scheme and the
Flutter SDK runtime key:

```text
kakaoYOUR_NATIVE_APP_KEY://oauth
```

No `--dart-define` is required for Android Studio Run after this value is set.

Do not commit `android/local.properties`. It contains machine-specific values
such as `sdk.dir` and `flutter.sdk`.

Debug builds use the committed shared debug keystore:

```text
android/app/shared-debug.keystore
```

Register this Android key hash in Kakao Developers for local debug builds:

```text
J1NUaASiofzkZFL1ghYe8FO6RRE=
```

You can recalculate it with:

```sh
keytool -exportcert -alias androiddebugkey -keystore android/app/shared-debug.keystore -storepass android | openssl sha1 -binary | openssl base64
```

Use this shared keystore for development only. Register a separate release key
hash, or the Google Play App Signing key hash, before production distribution.

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

# Kakao Login Setup

## Required keys

- Kakao Developers > App > Platform keys > Native app key
- Optional for web later: JavaScript key
- BFF login base URL for token exchange: `BFF_BASE_URL`

## Android setup

Set the Native app key locally in `android/local.properties`:

```properties
kakao.native_app_key=YOUR_NATIVE_APP_KEY
```

Android builds read this value from `android/local.properties`, with optional
fallbacks from the `kakao.native_app_key` Gradle property or the
`KAKAO_NATIVE_APP_KEY` environment variable. It injects both the manifest
redirect scheme and the Flutter SDK runtime key:

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

Debug and release builds use a placeholder scheme by default:

```xcconfig
KAKAO_NATIVE_APP_KEY_SCHEME=kakaoYOUR_NATIVE_APP_KEY
```

To override it locally, copy the example file:

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

## BFF token exchange

After Kakao SDK login succeeds, the app posts the Kakao access token to BFF
and expects the service token in return.

Run the app with the BFF URL:

```sh
flutter run --dart-define=BFF_BASE_URL=https://bff.noctide.dev
```

Optional login endpoint override:

```sh
flutter run \
  --dart-define=BFF_BASE_URL=https://bff.noctide.dev \
  --dart-define=BFF_KAKAO_LOGIN_PATH=/mapi/auth/kakao
```

Default request from the Flutter app:

```http
POST /mapi/auth/kakao
Content-Type: application/json

{
  "kakaoAccessToken": "kakao-access-token"
}
```

Expected BFF response shape:

```json
{
  "token_type": "Bearer",
  "access_token": "bff-access-token",
  "access_token_expires_in": 900,
  "refresh_token": "optional-refresh-token",
  "refresh_token_expires_in": 1209600
}
```

The BFF login endpoint itself must be open to unauthenticated requests,
otherwise the client will receive `401` before token exchange completes.

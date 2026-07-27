# ADR-009: Firebase App Distribution for updates

**Date:** 2026-07-27
**Status:** Accepted

## Decision

App updates are distributed to both testers via **Firebase App Distribution** rather
than manually sending APK files.

## Why

The app has two users (the developer and their girlfriend). There is no Play Store
listing. Previously, every update required building a release APK and sending it
manually (e.g. via WhatsApp). Firebase App Distribution is:

- Free on the Spark plan
- Already integrated (project uses Firebase CLI)
- Automatic: testers get a push/email notification when a new build is uploaded and
  can install it in one tap via the Firebase App Tester companion app

## How to release an update

```bash
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:538976807059:android:aed5f6962c35be14414566 \
  --release-notes "What changed" \
  --testers "david.bumba0607@gmail.com,miruna.petrosanu@gmail.com"
```

Testers must install the **Firebase App Tester** companion app once to receive
notifications and updates.

## Trade-offs

- Not automatic — the developer still has to build and run the upload command manually.
  There is no CI pipeline in V1.
- If the project moves to the Play Store (e.g. for push notification support requiring
  the Blaze plan), this setup can be replaced with the Play Store internal testing track.

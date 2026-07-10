# Post-V1 ideas

Things deliberately left out of V1. Don't add these speculatively — pick one up when V1 is stable and you want to grow the app.

## Push notifications
- Needs FCM + Cloud Functions → requires Firebase Blaze plan (pay-as-you-go).
- Use case: partner adds a shared note, you get notified.
- Complexity: medium. Cloud Function triggers on Firestore write, sends FCM payload.

## Photo / media notes
- Needs Firebase Storage.
- Also on Blaze plan.
- UI: image picker → upload → store download URL in note.

## iOS support
- Flutter codebase is already cross-platform. Main work is provisioning, App Store setup, and testing on iOS.
- Firebase config needs an iOS `GoogleService-Info.plist`.

## Unpair / leave-couple flow
- Currently there's no way to unpair. Would need to handle orphaned notes.
- Decision needed: what happens to shared notes when a couple unpairs?

## Soft delete / undo
- Currently hard deletes with a confirmation dialog.
- Undo would need either a trash collection or a Firestore transaction with a short TTL.

## Shared todos / calendar / love-notes
- New feature tabs on the home bottom nav.
- Relatively low effort once the shared-notes pattern is established.

## Markdown rendering
- Render note body as markdown in the list preview and editor.
- Package: `flutter_markdown`.

## Accent color / font customization
- Per-user color seed stored in `users/{userId}.accentColor`.
- Already has a `themeMode` field — accent color would extend this.

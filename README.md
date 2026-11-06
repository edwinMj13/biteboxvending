# BiteBox 24/7

One Flutter project with **two separate apps** that share one Firebase backend:

| App | Entry file | What it is |
|-----|-----------|------------|
| Public website | `lib/main.dart` | The site visitors see |
| Admin portal | `lib/main_admin.dart` | Where you edit what the public site shows |

```
Admin portal ──writes──▶ Firestore ──live updates──▶ Public website
```

## Running

```bash
# Public website
flutter run -d chrome -t lib/main.dart

# Admin portal
flutter run -d chrome -t lib/main_admin.dart
```

## Building for the web

```bash
flutter build web -t lib/main.dart                          # → build/web
flutter build web -t lib/main_admin.dart -o build/admin     # → build/admin
```

Host the two folders on separate sites or subdomains, for example
`bitebox.in` and `admin.bitebox.in`.

## Folder structure

```
lib/
├── main.dart                 PUBLIC entry point
├── main_admin.dart           ADMIN entry point
├── core/
│   ├── content/              Shared by both apps
│   │   ├── site_content_models.dart   data classes + built-in defaults
│   │   ├── content_repository.dart    all Firestore reads/writes
│   │   └── content_providers.dart     Riverpod providers
│   ├── router/  theme/
├── features/                 Public website pages
├── shared/widgets/           Widgets used by both apps
└── admin/                    Admin portal only
    ├── admin_app.dart        login gate + admin check
    ├── screens/              login + dashboard
    ├── sections/             one file per editable tab
    └── widgets/
```

## What the admin portal controls

| Admin tab | Firestore location | Shown on the public site |
|-----------|-------------------|--------------------------|
| Contact Details | `site_content/contact` | Header helpline, footer, Get In Touch page, franchise WhatsApp/email target |
| Home Numbers | `site_content/home_stats` | Home page, "BiteBox in Numbers" (Active Machines etc.) |
| Machine Locations | `machines/{id}` | Find Us page (shows "No machines" when empty) |
| Franchise Enquiries | `enquiries/{id}` | Read-only list of enquiries sent from the Franchise page |

Until the admin saves something, contact details and home numbers use the built-in values in
`SiteDefaults` (`site_content_models.dart`), so it never shows an empty page.

### Franchise enquiry flow

When a visitor submits the franchise form, they choose one of three options:

1. **Send via WhatsApp**: opens WhatsApp to the admin-configured number with the details filled in.
2. **Send via Email**: opens their email app addressed to the *Franchise Enquiry Email*.
3. **Submit Enquiry**: sends it straight to the team.

Whichever option the visitor picks, the enquiry is also saved to Firestore, so
it appears in the admin portal's **Franchise Enquiries** tab.

## One-time Firebase setup

1. **Enable services.** In the Firebase console, turn on **Firestore Database**
   and **Authentication → Email/Password**.
2. **Log in once.** Open the admin portal and log in with mobile
   `+91 96568 61728` and OTP `4321` (dummy OTP, no SMS is sent; settings are in
   `lib/admin/admin_config.dart`). The first login creates a shared Firebase
   account automatically and shows "Not an admin" with its **UID**.
3. **Mark the account as an admin.** In Firestore, create a collection
   `admins` and add a document whose ID is that UID (any fields). Refresh the
   portal.
4. **Apply the security rules.** Copy `firestore.rules` into
   Firestore → Rules → *Publish*. You can also add
   `"firestore": { "rules": "firestore.rules" }` to `firebase.json` and run
   `firebase deploy --only firestore:rules`.

   > ⚠️ The Firebase project (`chatapp-ad94d`) may also be used by another
   > app. Publishing these rules **replaces** any existing Firestore rules, so
   > merge them with what's already there.

## Adding another editable field

1. Add the field to a model (and its default) in `site_content_models.dart`.
2. Add read/write methods in `content_repository.dart` and a provider in `content_providers.dart`.
3. Add a section widget in `lib/admin/sections/` and register it in `_tabs` in `admin_dashboard_screen.dart`.
4. On the public page, read it with `ref.watch(yourProvider)`.
5. Add a matching `match` block in `firestore.rules`.

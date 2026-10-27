
<div align="center">
  <img src="assets/images/latest_logo.png" alt="Masiter app icon" width="112" />
  <h1>Masiter | مسيطر</h1>
  <p><strong>Practical business management for shops and small businesses.</strong></p>
  <p>Manage products, sales invoices, customers, inventory, and outstanding balances in one place.</p>
  <p>
    <a href="https://github.com/rimonnnn/Warshity">Repository</a>
    &nbsp;•&nbsp;
    <a href="https://github.com/rimonnnn/Warshity/releases">APK Releases</a>
    &nbsp;•&nbsp;
    <a href="https://rimonnnn.github.io/">Developer Portfolio</a>
  </p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-App-02569B?logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black" alt="Firebase" />
    <img src="https://img.shields.io/badge/Supabase-Storage-3FCF8E?logo=supabase&logoColor=white" alt="Supabase" />
  </p>
</div>

---

## Overview

**Masiter (مسيطر)** is a Flutter application designed to help shop owners and small businesses organize day-to-day operations without relying on scattered paper records. It brings product management, sales invoices, customer records, stock follow-up, and receivables into one workflow, with cloud-backed data and interfaces for mobile and web use.

The application supports Arabic and English, light and dark themes, and printable invoice layouts for common paper sizes. Its product model is based on a **one-time purchase rather than a recurring subscription**.

## Key Features

### 📦 Products & Inventory
- Organize products with details such as category and unit.
- Store product images using Supabase Storage.
- Receive low-stock notifications to help identify items that need attention.

### 🧾 Sales Invoices
- Create and manage customer sales invoices.
- Generate invoices as PDFs and print them in formats designed for:
  - **58 mm** thermal printers
  - **80 mm** thermal printers
  - **A4** paper

### 👥 Customers & Receivables
- Keep customer details and purchase history together.
- Track customer balances and outstanding debts.
- Apply debt payments against the oldest outstanding invoice first.
- Receive morning reminders related to outstanding receivables.

### 🔐 Account Access
- Register and sign in with Firebase Authentication.
- Support an email-verification flow during account creation.

### 🌐 User Experience
- Arabic and English localization, including right-to-left layouts where applicable.
- Light and dark themes.
- Responsive layouts for mobile and web interfaces.
- Network-image caching and image error handling for a smoother product-browsing experience.

## Technology Stack

| Area | Technologies |
|---|---|
| Application | Flutter, Dart |
| State management | `flutter_bloc` (BLoC/Cubit) |
| Navigation | `go_router` |
| Dependency injection | `get_it` |
| Responsive UI | `flutter_screenutil`, `responsive_framework` |
| Localization | `easy_localization` |
| Authentication | Firebase Authentication |
| Cloud data | Cloud Firestore |
| Product-image storage | Supabase Storage |
| PDF generation & printing | `pdf`, `printing` |
| Image loading | `cached_network_image` |
| Local preferences and secure storage | `shared_preferences`, `flutter_secure_storage` |
| Web hosting | Firebase Hosting |

The codebase uses **data and presentation responsibilities**, with BLoC/Cubit for UI state and dependency injection to manage service dependencies.

## Getting Started

### Prerequisites

- Flutter SDK compatible with the Dart SDK constraint declared in `pubspec.yaml` (`^3.10.3`).
- Git.
- Android Studio or another configured Android SDK environment for Android builds.
- Firebase and Supabase projects with the services required by the application enabled.

### 1. Clone the repository

```bash
git clone https://github.com/rimonnnn/Warshity.git
cd Warshity
```

The repository currently uses the `development` branch for active development. If your clone opens on a different branch, switch to it with:

```bash
git checkout development
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure backend services

Before running the application, verify that its Firebase and Supabase configuration matches the projects you are authorized to use:

- **Firebase:** configure Firebase Authentication and Cloud Firestore for the relevant app platforms.
- **Supabase:** configure the project URL and the appropriate client-side key for product-image storage.
- Review the app's existing initialization/configuration files before changing project identifiers or service settings.

**Security note:** Never put a Supabase service-role key or other server-side secret inside a Flutter client application, and do not commit private credentials to the repository.

### 4. Run the application

```bash
flutter run
```

Choose a connected device or a configured target when prompted.

## Build

### Android APK

Build a release APK:

```bash
flutter build apk --release
```

The generated APK is normally located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

To produce separate APKs for different CPU architectures (which can reduce each individual download size), use:

```bash
flutter build apk --release --split-per-abi
```

Each split APK targets a specific architecture, so distribute the file that matches the user's device. Use the standard release APK when you prefer one file that is easier to share.

### Web

Build the web version:

```bash
flutter build web --release
```

If Firebase Hosting is configured for your project and the Firebase CLI is installed and authenticated, deploy with:

```bash
firebase deploy --only hosting
```

## Download

Check the [GitHub Releases page](https://github.com/rimonnnn/Warshity/releases) for published APKs. A release must be created and an APK attached before a downloadable build will appear there.

## Repository Structure

```text
.
├── android/                 # Android platform configuration
├── ios/                     # iOS platform project
├── web/                     # Web platform files
├── lib/                     # Flutter application source
├── assets/
│   ├── images/              # App and UI assets
│   ├── fonts/               # Fonts
│   └── translations/        # Localization resources
├── test/                    # Automated tests
├── firebase.json            # Firebase Hosting configuration
├── firestore.rules          # Firestore security rules
├── firestore.indexes.json   # Firestore indexes
└── pubspec.yaml             # Dependencies and Flutter configuration
```

## Design Direction

The current visual identity uses a restrained teal-and-slate palette:

- **Primary teal:** `#0F766E`
- **Dark slate:** `#0F172A`
- **Light background:** `#F8FAFC`

## Testing & Code Quality

Run the automated tests available in the repository with:

```bash
flutter test
```

For changes involving authentication, invoices, balances, or shared business data, test both the expected flow and relevant failure cases before releasing a build.

## Developer

**Rimon Abdelmasih** — Flutter Developer

- [GitHub](https://github.com/rimonnnn)
- [LinkedIn](https://www.linkedin.com/in/rimon-abdelmasih/)
- [Portfolio](https://rimonnnn.github.io/)

Masiter has been developed collaboratively. The repository and application branding may continue to evolve as the project is maintained.

## License

No license file is currently included in the repository. Please contact the maintainer before reusing, modifying, or redistributing this code.

---

<details>
  <summary><strong>النسخة العربية</strong></summary>

  <h2>مسيطر — إدارة عملية للمحلات والمشروعات الصغيرة</h2>

  **مسيطر (Masiter)** هو تطبيق مبني باستخدام Flutter لمساعدة أصحاب المحلات والمشروعات الصغيرة على تنظيم المنتجات، والمخزون، وفواتير البيع، والعملاء، والديون من مكان واحد، بدلًا من الاعتماد على السجلات الورقية المتفرقة.

  ### أهم المميزات

  - **إدارة المنتجات والمخزون:** تنظيم المنتجات حسب بياناتها مثل التصنيف والوحدة، مع تخزين صور المنتجات ومتابعة انخفاض المخزون.
  - **فواتير البيع:** إنشاء الفواتير وتصديرها بصيغة PDF وتجهيزها للطباعة بمقاسات A4 وحراري 58 مم و80 مم.
  - **العملاء والديون:** حفظ بيانات العملاء ومتابعة المشتريات والأرصدة والمبالغ المستحقة.
  - **تسجيل التحصيلات:** توزيع السداد على أقدم فاتورة مستحقة أولًا.
  - **التنبيهات:** تنبيهات انخفاض المخزون وتذكيرات تحصيل المبالغ المستحقة.
  - **مشاركة بيانات النشاط:** إتاحة مشاركة بيانات النشاط مع حساب آخر من خلال آلية مشاركة مرتبطة بالبريد الإلكتروني.
  - **الحسابات:** تسجيل الدخول وإنشاء الحسابات باستخدام Firebase Authentication مع دعم التحقق من البريد الإلكتروني.
  - **تجربة استخدام مرنة:** دعم العربية والإنجليزية، والوضع الفاتح والداكن، وواجهات متجاوبة للموبايل والويب.
  - **نموذج الشراء:** شراء لمرة واحدة دون اشتراك دوري.

  ### التقنيات المستخدمة

  Flutter وDart، وBLoC/Cubit لإدارة الحالة، وGoRouter للتنقل، وGetIt للحقن المعتمد، وEasyLocalization للترجمة، وFirebase Authentication وCloud Firestore للحسابات والبيانات، وSupabase Storage لصور المنتجات، ومكتبتا `pdf` و`printing` لإنشاء الفواتير وطباعتها.

  ### تشغيل المشروع محليًا

  ```bash
  git clone https://github.com/rimonnnn/Warshity.git
  cd Warshity
  git checkout development
  flutter pub get
  flutter run
  

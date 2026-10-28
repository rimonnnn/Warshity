<div align="center">
  <img src="assets/images/latest_logo.png" alt="Masiter app icon" width="112" />
  <h1>Masiter | مسيطر</h1>
  <p><strong>Practical business management for shops and small businesses.</strong></p>
  <p>Products, sales invoices, customers, inventory, and outstanding balances in one place.</p>

  <p>
    <a href="https://masiter.web.app/"><strong>🌐 Live Web App</strong></a>
    &nbsp;•&nbsp;
    <a href="https://github.com/rimonnnn/Warshity/releases/download/v1.0.0/app-release.apk"><strong>⬇️ Download APK</strong></a>
  </p>
  <p>
    <a href="screenshots.md">🖼️ Screenshots</a>
    &nbsp;•&nbsp;
    <a href="https://github.com/rimonnnn/Warshity/releases">📦 Releases</a>
    &nbsp;•&nbsp;
    <a href="https://rimonnnn.github.io/">👤 Portfolio</a>
    &nbsp;•&nbsp;
    <a href="#arabic">🇪🇬 العربية</a>
  </p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-App-02569B?logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black" alt="Firebase" />
    <img src="https://img.shields.io/badge/Supabase-Storage-3FCF8E?logo=supabase&logoColor=white" alt="Supabase" />
    <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20Web-0F766E" alt="Platforms: Android and Web" />
    <img src="https://img.shields.io/badge/Languages-EN%20%7C%20AR-0F172A" alt="Languages: English and Arabic" />
  </p>
</div>

<p align="center">
  <img src="docs/screenshots/mobile/dashboard_en_light.jpg" width="22%" alt="Mobile dashboard, English, light" />
  <img src="docs/screenshots/mobile/invoices_en_light.jpg" width="22%" alt="Mobile invoices, English, light" />
  <img src="docs/screenshots/mobile/dashboard_en_dark.jpg" width="22%" alt="Mobile dashboard, English, dark" />
  <img src="docs/screenshots/mobile/dashboard_ar_light.jpg" width="22%" alt="Mobile dashboard, Arabic, light" />
</p>

---

## Table of Contents

- [Overview](#overview)
- [Try It and Download](#try-it-and-download)
- [Key Features](#key-features)
- [Screenshots](#screenshots)
- [Supported Platforms and Configurations](#supported-platforms-and-configurations)
- [Tech Stack and Architecture](#tech-stack-and-architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Build](#build)
- [Testing](#testing)
- [Design Direction](#design-direction)
- [Author](#author)
- [License](#license)
- [النسخة العربية](#arabic)

---

## Overview

**Masiter (مسيطر)** is a Flutter application that replaces scattered paper records with one organized workflow: product management, sales invoices, customer records, stock follow-up, and receivables.

|                  |                                               |
| :--------------- | :-------------------------------------------- |
| 🌍 **Languages** | Arabic (RTL) and English                      |
| 🎨 **Themes**    | Light and dark                                |
| 🖨️ **Printing**  | 58 mm thermal, 80 mm thermal, and A4 invoices |
| ☁️ **Data**      | Cloud-backed, available on mobile and web     |
| 💳 **Model**     | One-time purchase, no recurring subscription  |

## Try It and Download

| Platform            | Link                                                                                                             |
| :------------------ | :--------------------------------------------------------------------------------------------------------------- |
| 🌐 **Web**          | [**Open the web app →**](https://masiter.web.app/)                                                               |
| 🤖 **Android**      | [**Download the APK (v1.0.0) →**](https://github.com/rimonnnn/Warshity/releases/download/v1.0.0/app-release.apk) |
| 📦 **All releases** | [GitHub Releases](https://github.com/rimonnnn/Warshity/releases)                                                 |

> [!NOTE]
> To install the APK, allow installation from unknown sources on your Android device when prompted.

## Key Features

|     | Feature                     | What it does                                                                                                                                       |
| :-: | :-------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| 📦  | **Products & Inventory**    | Organize products by category and unit, store product images in Supabase Storage, and get low-stock notifications.                                 |
| 🧾  | **Sales Invoices**          | Create and manage invoices, export them as PDF, and print on **58 mm**, **80 mm**, or **A4** paper.                                                |
| 👥  | **Customers & Receivables** | Keep customer details and purchase history together, track balances and debts, and get morning reminders about outstanding receivables.            |
| 💰  | **Debt Collection**         | Payments are applied to the oldest outstanding invoice first.                                                                                      |
| 🤝  | **Business Data Sharing**   | Share business data with another account through an email-based sharing mechanism.                                                                 |
| 🔐  | **Account Access**          | Register and sign in with Firebase Authentication, including email verification.                                                                   |
| 🌐  | **User Experience**         | Arabic and English localization with RTL, light and dark themes, responsive mobile and web layouts, and cached product images with error handling. |

## Screenshots

Masiter across supported platforms, languages, and themes.

**[View the full screenshot gallery →](screenshots.md)**

<p align="center">
  <img src="docs/screenshots/web/web_dashboard_en_light.png" width="80%" alt="Web dashboard, English, light" />
</p>

## Supported Platforms and Configurations

| Dimension           | Support                                                                                                                                              |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Platforms           | Android ([APK](https://github.com/rimonnnn/Warshity/releases/download/v1.0.0/app-release.apk)) and Web ([masiter.web.app](https://masiter.web.app/)) |
| Themes              | Light and Dark                                                                                                                                       |
| Languages           | English and Arabic (with RTL)                                                                                                                        |
| Invoice print sizes | 58 mm, 80 mm, A4                                                                                                                                     |

## Tech Stack and Architecture

| Area                               | Technologies                                   |
| ---------------------------------- | ---------------------------------------------- |
| Application                        | Flutter, Dart                                  |
| State management                   | `flutter_bloc` (BLoC/Cubit)                    |
| Navigation                         | `go_router`                                    |
| Dependency injection               | `get_it`                                       |
| Responsive UI                      | `flutter_screenutil`, `responsive_framework`   |
| Localization                       | `easy_localization`                            |
| Authentication                     | Firebase Authentication                        |
| Cloud data                         | Cloud Firestore                                |
| Product-image storage              | Supabase Storage                               |
| PDF generation & printing          | `pdf`, `printing`                              |
| Image loading                      | `cached_network_image`                         |
| Local preferences / secure storage | `shared_preferences`, `flutter_secure_storage` |
| Web hosting                        | Firebase Hosting                               |

The code separates data and presentation responsibilities: BLoC/Cubit manages UI state, and `get_it` provides service dependencies.

## Project Structure

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
├── docs/screenshots/        # Screenshots used by README.md and screenshots.md
├── test/                    # Automated tests
├── firebase.json            # Firebase Hosting configuration
├── firestore.rules          # Firestore security rules
├── firestore.indexes.json   # Firestore indexes
└── pubspec.yaml             # Dependencies and Flutter configuration
```

## Getting Started

### Prerequisites

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml` (`^3.10.3`)
- Git
- Android Studio or another configured Android SDK environment (for Android builds)
- Firebase and Supabase projects with the required services enabled

### 1. Clone the repository

```bash
git clone https://github.com/rimonnnn/Warshity.git
cd Warshity
git checkout development   # active development branch
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure backend services

- **Firebase:** enable Authentication and Cloud Firestore for the platforms you target.
- **Supabase:** set the project URL (`<SUPABASE_URL>`) and the public client key (`<SUPABASE_ANON_KEY>`) used for product-image storage.
- Review the app's existing initialization files before changing project identifiers.
- Make sure the configuration points to projects you are authorized to use.

> [!WARNING]
> Never place a Supabase service-role key or any server-side secret in a Flutter client, and never commit private credentials.

### 4. Run

```bash
flutter run
```

Choose a connected device or target when prompted.

## Build

<details>
<summary><strong>🤖 Android APK</strong></summary>

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

For smaller per-architecture APKs, distribute the file matching the target device:

```bash
flutter build apk --release --split-per-abi
```

</details>

<details>
<summary><strong>🌐 Web (Firebase Hosting)</strong></summary>

```bash
flutter build web --release
```

With Firebase Hosting configured and the Firebase CLI installed and authenticated:

```bash
firebase deploy --only hosting
```

</details>

## Testing

```bash
flutter test
```

For changes touching authentication, invoices, balances, or shared business data, test both the expected flow and relevant failure cases before releasing.

## Design Direction

A restrained teal-and-slate palette:

| Role             |                              Color                               | Hex       |
| :--------------- | :--------------------------------------------------------------: | :-------- |
| Primary teal     | ![#0F766E](https://img.shields.io/badge/-%20%20%20%20%20-0F766E) | `#0F766E` |
| Dark slate       | ![#0F172A](https://img.shields.io/badge/-%20%20%20%20%20-0F172A) | `#0F172A` |
| Light background | ![#F8FAFC](https://img.shields.io/badge/-%20%20%20%20%20-F8FAFC) | `#F8FAFC` |

## Author

**Rimon Abdelmasih** — Flutter Developer

[GitHub](https://github.com/rimonnnn) • [LinkedIn](https://www.linkedin.com/in/rimon-abdelmasih/) • [Portfolio](https://rimonnnn.github.io/)

**Kirolos Emad** — Flutter Developer

[GitHub](https://github.com/kero12-eg) • [LinkedIn](https://www.linkedin.com/in/kirolos-emad-805612369?utm_source=share_via&utm_content=profile&utm_medium=member_ios) • [Portfolio](https://rimonnnn.github.io/)

Masiter has been developed collaboratively. Repository and application branding may continue to evolve.

## License

No license file is currently included. Please contact the maintainer before reusing, modifying, or redistributing this code.

---

<a id="arabic"></a>

<details>
  <summary><strong>🇪🇬 النسخة العربية</strong></summary>

<div dir="rtl" align="right">

<h2>مسيطر — إدارة عملية للمحلات والمشروعات الصغيرة</h2>

**مسيطر (Masiter)** هو تطبيق مبني باستخدام Flutter لمساعدة أصحاب المحلات والمشروعات الصغيرة على تنظيم المنتجات، والمخزون، وفواتير البيع، والعملاء، والديون من مكان واحد، بدلًا من الاعتماد على السجلات الورقية المتفرقة.

<h3>جرّب التطبيق</h3>

- 🌐 **الويب:** [افتح التطبيق على الويب](https://masiter.web.app/)
- 🤖 **أندرويد:** [تحميل ملف APK مباشرة](https://github.com/rimonnnn/Warshity/releases/download/v1.0.0/app-release.apk)

<h3>أهم المميزات</h3>

- 📦 **إدارة المنتجات والمخزون:** تنظيم المنتجات حسب بياناتها مثل التصنيف والوحدة، مع تخزين صور المنتجات ومتابعة انخفاض المخزون.
- 🧾 **فواتير البيع:** إنشاء الفواتير وتصديرها بصيغة PDF وتجهيزها للطباعة بمقاسات A4 وحراري 58 مم و80 مم.
- 👥 **العملاء والديون:** حفظ بيانات العملاء ومتابعة المشتريات والأرصدة والمبالغ المستحقة.
- 💰 **تسجيل التحصيلات:** توزيع السداد على أقدم فاتورة مستحقة أولًا.
- 🔔 **التنبيهات:** تنبيهات انخفاض المخزون وتذكيرات تحصيل المبالغ المستحقة.
- 🤝 **مشاركة بيانات النشاط:** إتاحة مشاركة بيانات النشاط مع حساب آخر من خلال آلية مشاركة مرتبطة بالبريد الإلكتروني.
- 🔐 **الحسابات:** تسجيل الدخول وإنشاء الحسابات باستخدام Firebase Authentication مع دعم التحقق من البريد الإلكتروني.
- 🌐 **تجربة استخدام مرنة:** دعم العربية والإنجليزية، والوضع الفاتح والداكن، وواجهات متجاوبة للموبايل والويب.
- 💳 **نموذج الشراء:** شراء لمرة واحدة دون اشتراك دوري.

<h3>التقنيات المستخدمة</h3>

Flutter وDart، وBLoC/Cubit لإدارة الحالة، وGoRouter للتنقل، وGetIt لحقن الاعتماديات، وEasyLocalization للترجمة، وFirebase Authentication وCloud Firestore للحسابات والبيانات، وSupabase Storage لصور المنتجات، ومكتبتا `pdf` و`printing` لإنشاء الفواتير وطباعتها.

<h3>تشغيل المشروع محليًا</h3>

</div>

```bash
git clone https://github.com/rimonnnn/Warshity.git
cd Warshity
git checkout development
flutter pub get
flutter run
```

<p align="right">🖼️ <a href="screenshots.md">معرض الصور</a> • 📦 <a href="https://github.com/rimonnnn/Warshity/releases">كل الإصدارات</a></p>

</details>

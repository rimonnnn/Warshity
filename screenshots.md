<div align="center">
  <h1>Masiter | مسيطر — Screenshot Gallery</h1>
  <p><a href="README.md">← Back to README</a></p>
</div>

Screenshots are grouped by **platform → language → theme**. Expand a section to browse it.

- [Mobile](#mobile)
- [Web](#web)
- [Adding screenshots](#adding-screenshots)

---

## Mobile

### English

<details open>
<summary><strong>Light Mode</strong></summary>
<br />

<p align="center">
  <img src="docs/screenshots/mobile/dashboard_en_light.jpg" width="240" alt="Masiter mobile dashboard, English, light mode" /><br />
  <strong>Dashboard</strong>
</p>
<p align="center">
  <img src="docs/screenshots/mobile/clients_en_light.jpg" width="240" alt="Masiter mobile clients, English, light mode" /><br />
  <strong>Clients</strong>
</p>
<p align="center">
  <img src="docs/screenshots/mobile/invoices_en_light.jpg" width="240" alt="Masiter mobile invoices, English, light mode" /><br />
  <strong>Invoices</strong>
</p>

</details>

<details>
<summary><strong>Dark Mode</strong></summary>
<br />

<p align="center">
  <img src="docs/screenshots/mobile/dashboard_en_dark.jpg" width="240" alt="Masiter mobile dashboard, English, dark mode" /><br />
  <strong>Dashboard</strong>
</p>

</details>

### Arabic

<details>
<summary><strong>Light Mode</strong></summary>
<br />

<p align="center">
  <img src="docs/screenshots/mobile/dashboard_ar_light.jpg" width="240" alt="Masiter mobile dashboard, Arabic, light mode" /><br />
  <strong>Dashboard</strong>
</p>

</details>

---

## Web

### English

<details open>
<summary><strong>Light Mode</strong></summary>
<br />

<p align="center">
  <img src="docs/screenshots/web/web_dashboard_en_light.png" width="720" alt="Masiter web dashboard, English, light mode" /><br />
  <strong>Dashboard</strong>
</p>

</details>

---

## Adding screenshots

Current convention: files live in `docs/screenshots/<platform>/` and are named `<screen>_<lang>_<theme>.<ext>`, for example `invoices_en_dark.jpg`.

- **platform:** `mobile` or `web` (web files are currently prefixed `web_`)
- **screen:** lowercase English feature name (`dashboard`, `products`, `invoices`, `clients`, `settings`)
- **lang:** `en` or `ar`
- **theme:** `light` or `dark`

To add one: drop the file in the matching folder, then add an `<img>` block (mobile `width="240"`, web `width="720"`) under the right platform / language / theme section above. Add a new `<details>` block only when a configuration has its first screenshot. Do not add placeholders for screenshots that do not exist yet.
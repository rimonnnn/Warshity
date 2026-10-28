<div align="center">
  <h1>Masiter | مسيطر — Screenshot Gallery</h1>
  <p><a href="README.md">← Back to README</a></p>
</div>

Screenshots are grouped by **platform → language → theme**. Expand a section to browse it.

| Platform | Language | Theme |
|:--|:--|:--|
| [📱 Mobile](#-mobile) | English / Arabic | Light / Dark |
| [🖥️ Web](#️-web) | English / Arabic | Light / Dark |

---

## 📱 Mobile

### English

<details open>
<summary><strong>☀️ Light Mode</strong></summary>
<br />

<table align="center">
  <tr>
    <td align="center"><img src="docs/screenshots/mobile/dashboard_en_light.jpg" width="220" alt="Dashboard, English, light" /><br /><strong>Dashboard</strong></td>
    <td align="center"><img src="docs/screenshots/mobile/clients_en_light.jpg" width="220" alt="Clients, English, light" /><br /><strong>Clients</strong></td>
    <td align="center"><img src="docs/screenshots/mobile/invoices_en_light.jpg" width="220" alt="Invoices, English, light" /><br /><strong>Invoices</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/mobile/products_en_light.jpg" width="220" alt="Products, English, light" /><br /><strong>Products</strong></td>
    <td align="center"><img src="docs/screenshots/mobile/settings_en_light.jpg" width="220" alt="Settings, English, light" /><br /><strong>Settings</strong></td>
    <td></td>
  </tr>
</table>

</details>

<details>
<summary><strong>🌙 Dark Mode</strong></summary>
<br />

<table align="center">
  <tr>
    <td align="center"><img src="docs/screenshots/mobile/dashboard_en_dark.jpg" width="220" alt="Dashboard, English, dark" /><br /><strong>Dashboard</strong></td>
    <td align="center"><img src="docs/screenshots/mobile/clients_en_dark.jpg" width="220" alt="Clients, English, dark" /><br /><strong>Clients</strong></td>
    <td align="center"><img src="docs/screenshots/mobile/invoices_en_dark.jpg" width="220" alt="Invoices, English, dark" /><br /><strong>Invoices</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/mobile/products_en_dark.jpg" width="220" alt="Products, English, dark" /><br /><strong>Products</strong></td>
    <td align="center"><img src="docs/screenshots/mobile/settings_en_dark.jpg" width="220" alt="Settings, English, dark" /><br /><strong>Settings</strong></td>
    <td></td>
  </tr>
</table>

</details>

### Arabic — العربية

<details>
<summary><strong>☀️ Light Mode</strong></summary>
<br />

<table align="center">
  <tr>
    <td align="center"><img src="docs/screenshots/mobile/dashboard_ar_light.jpg" width="220" alt="Dashboard, Arabic, light" /><br /><strong>Dashboard</strong></td>
    <td align="center"><img src="docs/screenshots/mobile/clients_ar_light.jpg" width="220" alt="Clients, Arabic, light" /><br /><strong>Clients</strong></td>
    <td align="center"><img src="docs/screenshots/mobile/invoices_ar_light.jpg" width="220" alt="Invoices, Arabic, light" /><br /><strong>Invoices</strong></td>
  </tr>
</table>

---

## 🖥️ Web

### English

<details open>
<summary><strong>☀️ Light &nbsp;|&nbsp; 🌙 Dark (side by side)</strong></summary>
<br />

<table align="center">
  <tr>
    <th align="center">☀️ Light</th>
    <th align="center">🌙 Dark</th>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/web/web_dashboard_en_light.png" width="460" alt="Web dashboard, English, light" /><br /><strong>Dashboard</strong></td>
    <td align="center"><img src="docs/screenshots/web/web_dashboard_en_dark.png" width="460" alt="Web dashboard, English, dark" /><br /><strong>Dashboard</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/web/web_invoices_en_light.png" width="460" alt="Web invoices, English, light" /><br /><strong>Invoices</strong></td>
    <td align="center"><img src="docs/screenshots/web/web_invoices_en_dark.png" width="460" alt="Web invoices, English, dark" /><br /><strong>Invoices</strong></td>
  </tr>
</table>

</details>

### Arabic — العربية

<details>
<summary><strong>☀️ Light &nbsp;|&nbsp; 🌙 Dark (side by side)</strong></summary>
<br />

<table align="center">
  <tr>
    <th align="center">☀️ Light</th>
    <th align="center">🌙 Dark</th>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/web/web_dashboard_ar_light.png" width="460" alt="Web dashboard, Arabic, light" /><br /><strong>Dashboard</strong></td>
    <td align="center"><img src="docs/screenshots/web/web_dashboard_ar_dark.png" width="460" alt="Web dashboard, Arabic, dark" /><br /><strong>Dashboard</strong></td>
  </tr>
</table>

</details>

---

## Adding screenshots

Files live in `docs/screenshots/<platform>/` and are named `<screen>_<lang>_<theme>.<ext>`, for example `invoices_en_dark.jpg`.

| Part | Values |
|:--|:--|
| **platform** | `mobile` or `web` (web files are prefixed `web_`) |
| **screen** | lowercase English name: `dashboard`, `products`, `invoices`, `clients`, `settings` |
| **lang** | `en` or `ar` |
| **theme** | `light` or `dark` |

**To add one:** drop the file in the matching folder, then add a `<td>` cell under the right platform / language / theme section (mobile `width="220"`, web `width="460"`). Add a new `<details>` block only when a configuration gets its first screenshot. Do not add placeholders for screenshots that do not exist yet.
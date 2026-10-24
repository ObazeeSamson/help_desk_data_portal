# ICT Help Desk Data Portal

An enterprise administrative dashboard for monitoring, assigning, and managing internal ICT support requests across organizational departments. Developed as a Student Industrial Work Experience Scheme (SIWES) project for the **Nigerian Ports Authority (NPA)** ICT Department.

---

## 🌟 Live Demo
* **Production URL:** [https://npa-helpdesk-requestform.alwaysdata.net](https://npa-helpdesk-requestform.alwaysdata.net)
* **Access Password:** `samson`

---

## 🚀 Key Features

* **🔐 Administrative Gatekeeper:** Secure password-protected authentication screen verifying credentials against a backend endpoint before granting access to dashboard records.
* **⚡ Live Auto-Polling & Notification Banner:** Background poller checks for new submissions every **5 seconds** without showing obstructive loaders. Displays a prominent floating notification banner and a `# new` badge whenever new tickets arrive.
* **👨‍🔧 Independent Technician Assignment:** Supervisors can assign or reassign an ICT technician to any ticket at any time by clicking `+ Assign` or the technician's name in the table, opening an interactive modal with the full complaint context.
* **🔄 Manual Ticket Lifecycle Management:** 1-click status transitions (`Pending` ➔ `In Progress` ➔ `Resolved`) synced directly with the MySQL database.
* **📅 Date Range Filtering:** Interactive date-picker filters requests between specific dates, complete with a quick-reset action and an active record counter.
* **📑 Tabular View & Pagination:** Clean enterprise table with zebra-striping, clamped issue descriptions, status color badges, and an 8-records-per-page pagination controller.
* **🗑️ Protected Ticket Deletion:** Permanent deletion safeguarded by an interactive confirmation dialog to prevent accidental data loss.

---

## 🏗️ System Architecture

The application adopts a robust **3-Tier Architecture**:

```mermaid
flowchart LR
    subgraph Client["Presentation Tier (Frontend)"]
        F["Flutter Web Dashboard"]
    end

    subgraph Server["Application Tier (Backend API)"]
        P1["verify_password.php"]
        P2["get_requests.php"]
        P3["update_status.php"]
        P4["delete_request.php"]
    end

    subgraph Database["Data Tier (Cloud Storage)"]
        DB[("AlwaysData MySQL Cloud\n`help_requests` table")]
    end

    F -->|HTTPS POST| P1
    F -->|HTTPS GET (Every 5s)| P2
    F -->|HTTPS POST| P3
    F -->|HTTPS POST| P4

    P1 -.->|Verify Credentials| Server
    P2 -->|SELECT query| DB
    P3 -->|Prepared UPDATE| DB
    P4 -->|Prepared DELETE| DB
```

### Technology Stack
| Layer | Technology | Details |
| :--- | :--- | :--- |
| **Frontend** | Flutter Web (Dart 3.x) | Custom Google Fonts Inter, enterprise responsive design tokens |
| **Backend API** | PHP 8.x (RESTful) | Strict typing, CORS headers, MySQLi prepared statements |
| **Database** | MySQL 8.0 | High-availability cloud instance on AlwaysData Cloud |
| **Hosting** | AlwaysData Cloud | Reverse-proxied HTTPS deployment with SSH/SCP automation |

---

## 📂 Project Structure

```text
help_desk_data_portal/
├── lib/
│   ├── constants.dart                     # Global API endpoints & base URLs
│   ├── main.dart                          # Application entry point & MaterialApp configuration
│   ├── models/
│   │   └── support_request.dart           # Domain model & JSON deserialization
│   ├── screens/
│   │   ├── password_screen/
│   │   │   └── password_screen.dart       # Authentication gateway screen
│   │   └── request_screen/
│   │       ├── request_screen.dart        # Dashboard coordinator & auto-polling controller
│   │       └── widgets/
│   │           ├── assign_technician_dialog.dart  # Modal dialog for assigning technicians
│   │           ├── filter_bar.dart                # Date range picker & record count indicator
│   │           ├── pagination_bar.dart            # Page navigation controls
│   │           ├── request_header.dart            # Top navigation bar with logout/lock
│   │           ├── request_row.dart               # Tabular data row with interactive cells
│   │           ├── request_table.dart             # DataTable wrapper with horizontal scrolling
│   │           ├── status_badge.dart              # Color-coded status badge chips
│   │           └── status_dropdown.dart           # Status modification dropdown
│   ├── services/
│   │   └── help_desk_service.dart         # HTTP network layer communicating with PHP API
│   └── theme/
│       └── app_theme.dart                 # Global theme colors, typography, and button styles
├── db_connect.php                         # Centralized MySQL database connection script
├── delete_request.php                     # API endpoint: permanently removes a ticket record
├── get_requests.php                       # API endpoint: retrieves all logged complaints
├── update_status.php                      # API endpoint: updates status and/or technician
├── verify_password.php                    # API endpoint: verifies administrative password
├── deploy.ps1                             # PowerShell script: automated build & cloud deploy
├── pubspec.yaml                           # Flutter dependencies & assets manifest
└── README.md                              # Project documentation
```

---

## 🗄️ Database Schema (`help_requests` Table)

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | `INT AUTO_INCREMENT PRIMARY KEY` | Unique numerical database identifier |
| `requesting_department` | `VARCHAR(100)` | Department submitting the issue (e.g. Finance, Audit) |
| `room_extension` | `VARCHAR(50)` | Room number or telephone extension |
| `requesting_officer` | `VARCHAR(100)` | Full name of the officer requesting assistance |
| `requester_designation` | `VARCHAR(100)` | Official job title of the requester |
| `complaint_description` | `TEXT` | Detailed description of the hardware/software fault |
| `diagnosed_by` | `VARCHAR(100)` | Full name of the assigned ICT technician |
| `status` | `ENUM('pending', 'in_progress', 'resolved')` | Operational lifecycle status of the ticket |
| `created_at` | `TIMESTAMP DEFAULT CURRENT_TIMESTAMP` | Submission timestamp |

---

## 🛡️ Security Features

1. **SQL Injection Defense:** All mutating endpoints (`update_status.php`, `delete_request.php`) utilize MySQLi **Prepared Statements** with parameterized inputs (`bind_param`) to guarantee queries cannot be manipulated.
2. **Strict Status Whitelisting:** Input statuses are checked against an explicit whitelist (`pending`, `in_progress`, `resolved`) on the backend before executing any SQL queries.
3. **Session Lockdown:** The dashboard header includes a prominent **"Lock Portal"** button that clears the active session and navigates back to the authentication screen.

---

## 💻 Getting Started Locally

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.19 or higher)
* [Google Chrome](https://www.google.com/chrome/) or Microsoft Edge
* [Git](https://git-scm.com/)

### Installation & Run
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/help_desk_data_portal.git
   cd help_desk_data_portal
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Verify code integrity:**
   ```bash
   flutter analyze
   ```

4. **Launch the development server in Chrome:**
   ```bash
   flutter run -d chrome
   ```

---

## 🚀 Deployment to Production

The project includes an automated deployment script ([`deploy.ps1`](./deploy.ps1)) for Windows PowerShell:

```powershell
.\deploy.ps1
```

**What the script does:**
1. Compiles a production-optimized release bundle (`flutter build web --release`).
2. Archives the build into `web.tar.gz`.
3. Uploads the archive to the AlwaysData server via SCP.
4. Unpacks the build in the server's web root (`www/`).
5. Uploads the latest backend PHP scripts to `www/help_desk_request/`.

---

## 🎓 Academic Defense & SIWES Context

* **Project Title:** Design and Implementation of an ICT Help Desk Data Portal
* **Organization:** Nigerian Ports Authority (NPA)
* **Program:** Students Industrial Work Experience Scheme (SIWES)
* **Author:** Samson

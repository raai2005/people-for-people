# People for People

> _"Bridging the gap between compassion and action."_

**People for People** is a comprehensive mobile ecosystem built with Flutter that connects Donors, Non-Governmental Organizations (NGOs), and Volunteers. It serves as a unified platform to foster community support, transparency in social work, and impactful collaboration.

---

## 🚀 The Mission

Our motive is simple yet powerful: **To democratize social impact.**
We believe that everyone has something to give—whether it's money, time, or skills. However, the path to contribution is often cluttered with friction. Our goal is to remove these barriers, making social work as accessible as ordering food or booking a cab. We aim to build a community where "People help People" seamlessly.

## ❓ The Problem

In the current landscape of social work and philanthropy, several disconnects exist:

- **Fragmentation:** There is no centralized hub where Donors, NGOs, and Volunteers coexist. Donors often don't know where their money is going, and Volunteers struggle to find legitimate causes that match their skills.
- **Visibility for NGOs:** Smaller, grassroots NGOs often do the most impactful work but lack the marketing budget or technical know-how to reach a wider audience.
- **Trust Deficit:** A lack of transparency can deter potential donors and volunteers. Users want to see the impact of their contributions.
- **Inefficient Coordination:** Managing volunteers and donations manually is time-consuming for NGOs, taking focus away from their core fieldwork.

## 💡 The Solution

**People for People** addresses these challenges by creating a transparent, role-based ecosystem:

1.  **Unified Platform:** A single app hosting all three key stakeholders.
2.  **For Donors:** A curated list of verified NGOs and causes. Donors can view detailed profiles, track where their donations go, and receive updates, ensuring peace of mind and continued engagement.
3.  **For NGOs:** A digital identity. NGOs can build professional profiles, post specific needs (funds or volunteers), and manage their incoming resources efficiently through a dedicated dashboard.
4.  **For Volunteers:** A smart discovery tool. Volunteers can filter opportunities based on their location, interests, and availability, ensuring their time is used effectively.

---

## ✨ Key Features

### 🔐 Secure & Role-Based Access

- **Authentication:** Robust login and registration system powered by **Firebase Auth**.
- **Role Selection:** tailored onboarding flows for Donors, NGOs, and Volunteers ensuring a personalized user experience.

### 🤝 For Organizations (NGOs)

- **Profile Management:** Create detailed profiles with mission statements, contact info, and gallery.
- **Campaign Creation:** Post specific requests for donations or call for volunteers.
- **Resource Management:** Track incoming donations and volunteer applications in real-time.

### ❤️ For Donors

- **Discover Causes:** Browse NGOs by category, location, or urgency.
- **Easy Donation:** Seamless flows to support causes securely (logic handled via `donation_service.dart`).
- **Impact Tracking:** See history of contributions and updates from the NGOs supported.

### 🙌 For Volunteers

- **Opportunity Finder:** Browse active volunteering events.
- **Application System:** One-tap apply for events.
- **Skill Matching:** Find roles that match specific skill sets (Teaching, Medical, Logistics, etc.).

### 🛠 Technical Highlights

- **Media Integration:** High-performance image and document uploads (e.g., proof of work, profile pictures) via **Cloudinary**.
- **Real-time Updates:** Instant notifications for new opportunities or donation receipts.
- **Modern UI/UX:** Built with **Material 3** guidelines, ensuring a clean, accessible, and responsive interface across iOS and Android.

---

## 🛠 Tech Stack

- **Frontend:** Flutter (Dart) - _For cross-platform native performance._
- **Backend:** Firebase (Firestore, Auth) - _For real-time data and serverless scalability._
- **Storage:** Cloudinary - _For optimized media management._
- **State Management:** Native Flutter state handling for efficiency.

---

## 📦 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- An IDE (VS Code or Android Studio).
- A Firebase project set up.

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/yourusername/people-for-people.git
    cd people
    ```

2.  **Install Dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Environment Setup (Crucial):**
    This project uses `flutter_dotenv` to manage sensitive keys.
    - Create a `.env` file in the root directory.
    - **Refer to [ENV_SETUP.md](ENV_SETUP.md)** for the exact keys required (Cloudinary credentials, etc.).

4.  **Run the App:**
    ```bash
    flutter run
    ```

---

## 📂 Project Structure

```
lib/
├── main.dart           # Entry point
├── models/             # Data models (User, NGO, Donation, etc.)
├── screens/            # UI implementation
│   ├── auth/           # Login & Registration screens
│   ├── donor/          # Donor-specific views
│   ├── ngo/            # NGO dashboard & profile management
│   └── volunteer/      # Volunteer opportunities & profile
├── services/           # Business Logic (Firebase, Cloudinary)
├── widgets/            # Reusable UI components
└── theme/              # App styling and color palette
```

## 🤝 Contributing

We welcome contributions! If you have ideas to make this platform better:

1.  Fork the repo.
2.  Create a feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes.
4.  Push to the branch.
5.  Open a Pull Request.

---

_Built with ❤️ for the community._

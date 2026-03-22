# People for People

> _"Bridging the gap between compassion and action."_

**People for People** is a comprehensive mobile ecosystem built with Flutter that connects Donors, Non-Governmental Organizations (NGOs), and Volunteers. It serves as a unified platform to foster community support, transparency in social work, and impactful collaboration.

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)

---

## 🚀 The Mission

Our motive is simple yet powerful: **To democratize social impact.**

We believe that everyone has something to give—whether it's money, time, or skills. However, the path to contribution is often cluttered with friction. Our goal is to remove these barriers, making social work as accessible as ordering food or booking a cab. We aim to build a community where "People help People" seamlessly.

---

## ❓ The Problem

In the current landscape of social work and philanthropy, several disconnects exist:

- **Fragmentation:** No centralized hub where Donors, NGOs, and Volunteers coexist
- **Visibility for NGOs:** Smaller grassroots NGOs lack marketing reach despite impactful work
- **Trust Deficit:** Lack of transparency deters potential donors and volunteers
- **Inefficient Coordination:** Manual management takes focus away from core fieldwork

---

## 💡 The Solution

**People for People** addresses these challenges by creating a transparent, role-based ecosystem:

### 🎯 For Donors
- Curated list of verified NGOs
- Track donation impact in real-time
- Download PDF receipts with QR codes
- View donation history and statistics
- Profile completion tracking (70% required)

### 🏢 For NGOs
- Professional digital identity
- Create donation requests
- Manage incoming donations with verification codes
- Assign volunteers to pickups
- Real-time dashboard with stats
- Document verification system

### 🤝 For Volunteers
- Browse available pickup tasks
- Accept assignments with one tap
- Track completed deliveries and hours
- Real-time approval status
- Dedicated profile with statistics

### 👨‍💼 For Admins
- Secret admin panel (5-tap logo trigger)
- Approve/reject NGOs and Volunteers
- Document verification with status buttons
- Send email and in-app notifications
- User management dashboard
- Platform statistics overview

---

## ✨ Key Features

### 🔐 Authentication & Security
- Firebase Authentication (email/password)
- Role-based access control (Donor, NGO, Volunteer, Admin)
- Admin approval workflow for NGOs and Volunteers
- Pending approval screen with status tracking
- Profile completion requirements

### 📧 Notification System
- **Email Notifications** (via EmailJS)
  - Account approval emails
  - Rejection emails with admin-provided reasons
  - Document verification feedback
- **In-App Notifications**
  - Real-time notification delivery
  - Unread notification tracking
  - Notification history

### 📄 Document Management
- Government document upload and verification
- Head of organization ID verification
- Admin verification buttons (Verified/Rejected)
- Document status tracking in Firestore
- Image viewer for document review

### 💰 Donation System
- Quick donate to any NGO
- Donation request system
- Transaction management (Incoming/Pending/Completed)
- Verification code generation
- PDF receipt generation with QR codes
- Real-time donation tracking

### 🚚 Volunteer Pickup System
- Real-time pickup opportunities from Firestore
- Accept pickup assignments
- Volunteer assignment to transactions
- Track completed deliveries
- Hours volunteered calculation

### 📊 Real-Time Dashboards
- **Donor Dashboard**: Donation stats, history, impact tracking
- **NGO Dashboard**: Total donations, active volunteers, transactions
- **Volunteer Dashboard**: Tasks completed, deliveries, hours
- **Admin Dashboard**: User stats, pending approvals, platform overview

---

## 🛠 Tech Stack

### Frontend
- **Flutter 3.10+** - Cross-platform mobile framework
- **Dart** - Programming language
- **Material 3** - Modern UI design system

### Backend & Services
- **Firebase Auth** - User authentication
- **Cloud Firestore** - Real-time NoSQL database
- **Cloudinary** - Media storage and optimization
- **EmailJS** - Email notification service

### Key Packages
- `firebase_core` & `firebase_auth` - Firebase integration
- `cloud_firestore` - Database operations
- `flutter_dotenv` - Environment variable management
- `http` - API requests for EmailJS
- `pdf` - Receipt generation
- `image_picker` & `file_picker` - Media uploads
- `share_plus` - Share receipts
- `url_launcher` - Open external links
- `intl` - Date formatting

---

## 📦 Getting Started

### Prerequisites

- [Flutter SDK 3.10+](https://docs.flutter.dev/get-started/install)
- [Firebase Account](https://firebase.google.com)
- [Cloudinary Account](https://cloudinary.com)
- [EmailJS Account](https://www.emailjs.com) (free tier: 200 emails/month)
- IDE: VS Code or Android Studio

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/people-for-people.git
   cd people
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Environment setup:**

   Create a `.env` file in the `people/` directory:

   ```env
   # Cloudinary
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   CLOUDINARY_UPLOAD_PRESET=your_preset
   
   # EmailJS
   EMAILJS_SERVICE_ID=service_xxxxx
   EMAILJS_TEMPLATE_ID=template_xxxxx
   EMAILJS_PUBLIC_KEY=your_public_key
   ```

   See [EMAIL_SETUP.md](EMAIL_SETUP.md) for detailed EmailJS configuration.

4. **Firebase setup:**

   - Create a Firebase project
   - Enable Authentication (Email/Password)
   - Create Firestore database
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Run: `flutterfire configure`

5. **Run the app:**

   ```bash
   flutter run -d chrome  # For web
   flutter run            # For mobile
   ```

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
│
├── models/                      # Data models
│   ├── user_models.dart         # User, NGO, Volunteer, Donor models
│   ├── transaction_model.dart   # Transaction and status enums
│   ├── donation_request.dart    # Donation request model
│   ├── donation_receipt.dart    # Receipt model
│   └── notification_model.dart  # Notification model
│
├── screens/                     # UI screens
│   ├── auth/                    # Authentication
│   │   ├── role_selection_screen.dart
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   │
│   ├── admin/                   # Admin panel
│   │   ├── admin_dashboard.dart
│   │   └── admin_users_screen.dart
│   │
│   ├── donor/                   # Donor features
│   │   ├── donor_dashboard.dart
│   │   ├── donor_discover_screen.dart
│   │   ├── donor_donate_screen.dart
│   │   ├── donor_history_screen.dart
│   │   ├── donor_deliveries_screen.dart
│   │   └── donor_profile_screen.dart
│   │
│   ├── ngo/                     # NGO features
│   │   ├── ngo_dashboard.dart
│   │   ├── ngo_profile_screen.dart
│   │   ├── ngo_donate_screen.dart
│   │   ├── ngo_transactions_screen.dart
│   │   └── create_donation_request_screen.dart
│   │
│   ├── volunteer/               # Volunteer features
│   │   ├── volunteer_dashboard.dart
│   │   ├── volunteer_pickup_screen.dart
│   │   └── volunteer_profile_screen.dart
│   │
│   ├── common/                  # Shared screens
│   │   ├── pending_approval_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── public_ngo_profile_screen.dart
│   │   ├── public_donor_profile_screen.dart
│   │   └── public_volunteer_profile_screen.dart
│   │
│   └── splash_screen.dart       # Initial loading screen
│
├── services/                    # Business logic
│   ├── auth_service.dart        # Authentication operations
│   ├── donation_service.dart    # Donation management
│   ├── notification_service.dart # In-app notifications
│   ├── email_service.dart       # Email notifications (EmailJS)
│   ├── receipt_service.dart     # PDF receipt generation
│   ├── cloudinary_service.dart  # Media uploads
│   └── file_picker_helper.dart  # File selection helper
│
├── widgets/                     # Reusable components
│   └── custom_text_field.dart
│
└── theme/                       # App styling
    └── app_theme.dart           # Colors, text styles, themes
```

---

## 🔥 Firestore Collections

### `users`
```javascript
{
  "uid": "user_id",
  "role": "donor" | "ngo" | "volunteer" | "admin",
  "email": "user@example.com",
  "name": "User Name",
  "isApproved": true/false,
  "isVerified": true/false,
  
  // NGO specific
  "organizationName": "NGO Name",
  "category": "education" | "health" | "food" | ...,
  "govtVerifiedDocUrl": "cloudinary_url",
  "govtVerifiedDocVerified": true/false/null,
  "headOfOrgIdUrl": "cloudinary_url",
  "headOfOrgIdVerified": true/false/null,
  
  // Volunteer specific
  "qualification": "Degree/Certification",
  "isWorkingInNGO": true/false,
  "ngoName": "Associated NGO",
  
  "createdAt": Timestamp,
  "approvedAt": Timestamp
}
```

### `transactions`
```javascript
{
  "id": "transaction_id",
  "donorId": "donor_uid",
  "donorName": "Donor Name",
  "ngoId": "ngo_uid",
  "ngoName": "NGO Name",
  "amount": 1000,
  "itemName": "Donation Item",
  "status": "incoming" | "pendingDelivery" | "needsVolunteer" | "volunteerAssigned" | "completed" | "rejected",
  "volunteerId": "volunteer_uid",
  "volunteerName": "Volunteer Name",
  "verificationCode": "ABC123",
  "isDonorDelivering": true/false,
  "createdAt": Timestamp
}
```

### `donations`
```javascript
{
  "id": "donation_id",
  "donorId": "donor_uid",
  "donorName": "Donor Name",
  "ngoId": "ngo_uid",
  "ngoName": "NGO Name",
  "amount": 1000,
  "category": "education",
  "message": "Optional message",
  "createdAt": Timestamp
}
```

### `notifications`
```javascript
{
  "id": "notification_id",
  "userId": "user_uid",
  "title": "Notification Title",
  "message": "Notification message",
  "type": "approval" | "rejection" | "document_verification" | "revoke",
  "isRead": false,
  "createdAt": Timestamp
}
```

---

## 🎯 User Flows

### Donor Flow
1. Register → Auto-approved
2. Complete profile (70% required)
3. Discover NGOs
4. Make donation (Quick or Request-based)
5. Download PDF receipt
6. Track donation history

### NGO Flow
1. Register with documents
2. Wait for admin approval
3. Receive approval email
4. Access dashboard
5. Create donation requests
6. Manage incoming donations
7. Assign volunteers to pickups
8. Generate verification codes

### Volunteer Flow
1. Register
2. Wait for admin approval
3. Receive approval email
4. Browse pickup opportunities
5. Accept pickup tasks
6. Complete deliveries
7. Track statistics

### Admin Flow
1. Secret login (5-tap logo on role selection)
2. View pending approvals
3. Review documents (Verify/Reject)
4. Send document feedback notifications
5. Approve/Reject accounts with reasons
6. Manage all users
7. Monitor platform statistics

---

## 📧 Email Notification Setup

The app uses **EmailJS** for sending email notifications. Setup takes only 5 minutes:

1. Create free EmailJS account at [emailjs.com](https://www.emailjs.com)
2. Add email service (Gmail recommended)
3. Create email template (see [EMAIL_SETUP.md](EMAIL_SETUP.md))
4. Copy Service ID, Template ID, and Public Key
5. Add to `.env` file

**Email Types:**
- ✅ Account approval
- ❌ Account rejection (with reason)
- 📄 Document verification feedback

See [NOTIFICATION_SYSTEM.md](NOTIFICATION_SYSTEM.md) for complete documentation.

---

## 🔒 Admin Access

**Secret Admin Login:**
1. Go to Role Selection screen
2. Tap the logo **5 times** within 3 seconds
3. Admin login dialog appears
4. Enter admin credentials
5. System verifies `role: admin` in Firestore

**Admin Account Setup:**
```javascript
// In Firestore users collection
{
  "uid": "admin_uid",  // Must match Firebase Auth UID
  "role": "admin",
  "email": "admin@example.com",
  "name": "Admin Name"
}
```

---

## 🧪 Testing

### Test Accounts

**Donor:**
- Register normally
- Auto-approved
- Test donations and receipts

**NGO:**
- Register with test documents
- Wait for admin approval
- Test dashboard and transactions

**Volunteer:**
- Register
- Wait for admin approval
- Test pickup acceptance

**Admin:**
- Use 5-tap secret login
- Test approval workflow
- Test email notifications

### Run Tests

```bash
# Run on Chrome (recommended for development)
flutter run -d chrome

# Run on Android emulator
flutter run -d android

# Run on iOS simulator
flutter run -d ios
```

---

## 📱 Platform Support

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (Chrome, Firefox, Safari)
- ⚠️ **Windows/macOS/Linux** (Firebase C++ SDK issues)

**Recommended for development:** Chrome (`flutter run -d chrome`)

---

## 📚 Documentation

- [EMAIL_SETUP.md](EMAIL_SETUP.md) - EmailJS configuration guide
- [NOTIFICATION_SYSTEM.md](NOTIFICATION_SYSTEM.md) - Complete notification system docs
- [FINAL_CHECKLIST.md](FINAL_CHECKLIST.md) - Feature completion status
- [DONOR_DONATE_FLOW.md](DONOR_DONATE_FLOW.md) - Donation flow documentation
- [RECEIPT_IMPLEMENTATION.md](RECEIPT_IMPLEMENTATION.md) - PDF receipt system

---

## 🚀 Deployment

### Web Deployment

```bash
flutter build web --release
# Deploy the build/web folder to Firebase Hosting, Netlify, or Vercel
```

### Android Deployment

```bash
flutter build apk --release
# Or for app bundle
flutter build appbundle --release
```

### iOS Deployment

```bash
flutter build ios --release
# Open Xcode and archive for App Store
```

---

## 🤝 Contributing

We welcome contributions! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Contribution Guidelines

- Follow Flutter best practices
- Write clean, documented code
- Test thoroughly before submitting
- Update documentation if needed

---

## 📊 Project Status

**Current Version:** 1.0.0 (MVP)

**All Features Implemented:**
- ✅ Complete authentication system
- ✅ Admin panel with document verification
- ✅ Email & in-app notifications
- ✅ Real-time dashboards for all roles
- ✅ Donation system with PDF receipts
- ✅ Volunteer pickup system
- ✅ Transaction management
- ✅ Profile completion tracking

**Setup Required:**
- EmailJS configuration (5 minutes)
- Firebase project setup
- Cloudinary account setup

---

## 🐛 Known Issues

- Windows desktop build fails with Firebase C++ SDK (use web/mobile instead)
- Email delivery may take 1-2 minutes
- Free EmailJS tier: 200 emails/month limit

---

## 💻 Developer

**Built with ❤️ by Megha Roy**

A solo developer passionate about making social impact accessible to everyone.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Cloudinary for media management
- EmailJS for email notifications
- All testers and early users

---

## 🌟 Star History

If you find this project useful, please consider giving it a ⭐!

---

**"People helping People, one connection at a time."** 💙

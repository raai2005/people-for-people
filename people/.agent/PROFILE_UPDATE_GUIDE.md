# Profile Update Guide

## Overview

Your app now has a complete profile update system that saves all changes to Firebase Firestore. This guide explains how it works and how to use it.

## What's Been Implemented

### 1. **Enhanced User Models** (`lib/models/user_models.dart`)

All user models now include:

- `profileCompletion`: int (0-100) - tracks profile completion percentage
- `verification`: VerificationStatus object with:
  - `email`: boolean
  - `phone`: boolean
  - `governmentId`: boolean
- `donorProfile`: DonorProfile object (for donors only) with:
  - `bio`: string
  - `occupation`: string
  - `location`: string
  - `profileImage`: string
  - `badges`: List<String>
  - `donationCount`: int
  - `rating`: double

### 2. **AuthService Methods** (`lib/services/auth_service.dart`)

#### `updateUserProfile(BaseUser user)`

Updates the entire user profile in Firestore.

```dart
// Example usage:
final updatedUser = DonorUser(
  id: currentUser.id,
  name: "New Name",
  // ... all other fields
);
await authService.updateUserProfile(updatedUser);
```

#### `updateUserFields(String userId, Map<String, dynamic> fields)`

Updates specific fields without replacing the entire document.

```dart
// Example: Update only verification status
await authService.updateUserFields(userId, {
  'verification.email': true,
  'profileCompletion': 50,
});
```

### 3. **Donor Profile Screen** (`lib/screens/donor/donor_profile_screen.dart`)

The donor profile screen now:

- Loads user data from Firestore
- Allows editing of name, location, bio, occupation, and phone
- Saves all changes to Firestore using `AuthService.updateUserProfile()`
- Preserves all existing fields (verification, donorProfile, etc.)
- Shows success/error messages

## How to Update Profile Data

### Method 1: Full Profile Update (Recommended for UI forms)

```dart
// In your profile screen
Future<void> _saveProfile() async {
  // Create updated user object with ALL fields
  final updatedUser = DonorUser(
    id: currentUser.id,
    name: nameController.text.trim(),
    email: currentUser.email,
    // ... include ALL fields, even unchanged ones
    profileCompletion: currentUser.profileCompletion,
    verification: currentUser.verification,
    donorProfile: currentUser.donorProfile,
  );

  // Save to Firestore
  await authService.updateUserProfile(updatedUser);
}
```

### Method 2: Partial Field Update (For specific field changes)

```dart
// Update only specific fields
await authService.updateUserFields(userId, {
  'verification.email': true,
  'profileCompletion': 75,
  'donorProfile.donationCount': 10,
});
```

### Method 3: Update Nested Objects

```dart
// Update verification status
final newVerification = VerificationStatus(
  email: true,
  phone: true,
  governmentId: false,
);

await authService.updateUserFields(userId, {
  'verification': newVerification.toMap(),
});

// Update donor profile
final newDonorProfile = DonorProfile(
  bio: "Passionate about helping others",
  occupation: "Software Engineer",
  donationCount: 15,
  rating: 4.8,
);

await authService.updateUserFields(userId, {
  'donorProfile': newDonorProfile.toMap(),
});
```

## Example: Update Profile Completion

```dart
// Calculate profile completion based on filled fields
int calculateProfileCompletion(DonorUser user) {
  int completed = 0;
  int total = 10;

  if (user.name.isNotEmpty) completed++;
  if (user.email.isNotEmpty) completed++;
  if (user.phone.isNotEmpty) completed++;
  if (user.location.isNotEmpty) completed++;
  if (user.bio?.isNotEmpty == true) completed++;
  if (user.occupation?.isNotEmpty == true) completed++;
  if (user.verification.email) completed++;
  if (user.verification.phone) completed++;
  if (user.verification.governmentId) completed++;
  if (user.profileImageUrl?.isNotEmpty == true) completed++;

  return ((completed / total) * 100).round();
}

// Update it
final completion = calculateProfileCompletion(currentUser);
await authService.updateUserFields(userId, {
  'profileCompletion': completion,
});
```

## Example: Mark Email as Verified

```dart
Future<void> markEmailVerified(String userId) async {
  await authService.updateUserFields(userId, {
    'verification.email': true,
  });
}
```

## Example: Add a Badge to Donor

```dart
Future<void> addBadge(String userId, String badgeName) async {
  final user = await authService.getUserProfile() as DonorUser;
  final updatedBadges = [...user.donorProfile.badges, badgeName];

  await authService.updateUserFields(userId, {
    'donorProfile.badges': updatedBadges,
  });
}
```

## Example: Increment Donation Count

```dart
Future<void> recordDonation(String userId) async {
  final user = await authService.getUserProfile() as DonorUser;
  final newCount = user.donorProfile.donationCount + 1;

  await authService.updateUserFields(userId, {
    'donorProfile.donationCount': newCount,
  });
}
```

## Testing the Profile Update

1. **Run your app**: `flutter run`
2. **Login as a donor**
3. **Navigate to Profile tab**
4. **Click "Edit Profile"**
5. **Make changes** to name, bio, occupation, etc.
6. **Click "Save Changes"**
7. **Check Firebase Console** → Firestore → users collection → your user document
8. **Verify** that all changes are saved

## Firebase Firestore Structure

Your user documents now look like this:

```json
{
  "id": "user123",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "location": "New York",
  "role": "donor",
  "profileCompletion": 75,
  "verification": {
    "email": true,
    "phone": true,
    "governmentId": false
  },
  "donorProfile": {
    "bio": "Passionate about helping others",
    "occupation": "Software Engineer",
    "location": "New York",
    "profileImage": "",
    "badges": ["Email Verified", "Trusted Donor"],
    "donationCount": 15,
    "rating": 4.8
  },
  "qualification": "Bachelor's Degree",
  "isApproved": true,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

## Important Notes

1. **Always preserve existing fields** when updating to avoid data loss
2. **Use try-catch blocks** to handle errors gracefully
3. **Show user feedback** (success/error messages) after updates
4. **Validate data** before saving to Firestore
5. **Check user authentication** before allowing updates

## Next Steps

You can now:

- Add profile image upload functionality
- Implement email/phone verification flows
- Create admin approval system for government ID
- Add profile completion progress tracking
- Implement badge earning system
- Track donation history

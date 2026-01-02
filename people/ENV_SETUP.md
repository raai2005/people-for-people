# Environment Variables Setup Guide

## Overview

This project uses environment variables to store sensitive credentials and configuration settings. The `.env` file is **already in `.gitignore`** to prevent accidental commits of sensitive data.

## Quick Start

### 1. Your `.env` file has been created

The `.env` file has already been created from the `.env.example` template.

### 2. Add Your Credentials

Open the `.env` file and replace the placeholder values with your actual credentials:

```env
CLOUDINARY_CLOUD_NAME=your_actual_cloud_name
CLOUDINARY_API_KEY=your_actual_api_key
CLOUDINARY_API_SECRET=your_actual_api_secret
CLOUDINARY_UPLOAD_PRESET=your_actual_upload_preset
```

## Getting Cloudinary Credentials

1. **Sign up/Login** to [Cloudinary](https://cloudinary.com/)
2. Go to your [Dashboard](https://cloudinary.com/console)
3. You'll find:
   - **Cloud Name**: Displayed at the top
   - **API Key**: In the "Account Details" section
   - **API Secret**: Click "Reveal" next to API Secret
4. **Upload Preset**:
   - Go to Settings → Upload
   - Scroll to "Upload presets"
   - Create a new preset or use an existing one

## Using Environment Variables in Flutter

### Option 1: Using flutter_dotenv package

1. Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

2. Add to `pubspec.yaml` assets:

```yaml
flutter:
  assets:
    - .env
```

3. Load in `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

4. Access variables:

```dart
String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
```

### Option 2: Using envied package (Type-safe)

1. Add to `pubspec.yaml`:

```yaml
dependencies:
  envied: ^0.5.4+1

dev_dependencies:
  envied_generator: ^0.5.4+1
  build_runner: ^2.4.6
```

2. Create `lib/env/env.dart`:

```dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'CLOUDINARY_CLOUD_NAME')
  static const String cloudinaryCloudName = _Env.cloudinaryCloudName;

  @EnviedField(varName: 'CLOUDINARY_API_KEY')
  static const String cloudinaryApiKey = _Env.cloudinaryApiKey;

  @EnviedField(varName: 'CLOUDINARY_API_SECRET', obfuscate: true)
  static const String cloudinaryApiSecret = _Env.cloudinaryApiSecret;
}
```

3. Generate code:

```bash
flutter pub run build_runner build
```

4. Use in your code:

```dart
import 'package:your_app/env/env.dart';

String cloudName = Env.cloudinaryCloudName;
```

## Security Best Practices

✅ **DO:**

- Keep `.env` in `.gitignore` (already done)
- Use `.env.example` as a template for team members
- Store different credentials for development/staging/production
- Rotate credentials regularly
- Use obfuscation for sensitive values (with envied package)

❌ **DON'T:**

- Commit `.env` to version control
- Share `.env` files via email or chat
- Hardcode credentials in source code
- Use production credentials in development

## Verification

Check that `.env` is properly ignored:

```bash
git status
```

The `.env` file should NOT appear in the list of untracked files.

## Troubleshooting

**Problem**: `.env` appears in git status
**Solution**: Make sure `.env` is listed in `.gitignore` and run:

```bash
git rm --cached .env
```

**Problem**: Environment variables not loading
**Solution**:

- Check file name is exactly `.env` (not `.env.txt`)
- Verify the file is in the project root
- Ensure no spaces around `=` in variable definitions
- Restart your IDE/editor after creating `.env`

## Team Setup

When a new team member joins:

1. They copy `.env.example` to `.env`
2. They request credentials from the team lead
3. They fill in their `.env` file with the provided values
4. They never commit the `.env` file

---

**Note**: The `.env` file is already configured and ready to use. Just add your actual credentials!

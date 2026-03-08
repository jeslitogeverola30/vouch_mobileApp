# Vouch Flutter App - Release Build Guide

## Step 1: Generate Keystore (One-time setup)

Run this command to generate a keystore file for signing your APK:

```bash
keytool -genkey -v -keystore ~/vouch_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vouch
```

This will prompt you for:

- **Store Password**: Create a strong password (remember it!)
- **Key Password**: Same or different password (remember it!)
- **Common Name (CN)**: Your full name
- **Organization**: Your organization name
- **Organization Unit**: Leave blank or use your department
- **City**: Your city
- **State**: Your state
- **Country**: Your country code (e.g., US)

The keystore file will be created at `~/vouch_key.jks`

## Step 2: Update key.properties

Edit `android/key.properties` and fill in the credentials:

```properties
storePassword=your_store_password_here
keyPassword=your_key_password_here
keyAlias=vouch
storeFile=/home/your_username/vouch_key.jks
```

**Important**:

- Replace `/home/your_username/` with your actual home directory path
- Never commit this file to Git (it's in .gitignore)
- Keep these passwords safe!

## Step 3: Verify All Services

Before building, ensure your `.env` file has all required values:

```env
SUPABASE_URL=https://iughctuvswasmttswwnk.supabase.co
SUPABASE_ANON_KEY=sb_publishable_j7Wwu5oPpslcgsEftBSY9A_RegZBX5F
CLOUDINARY_CLOUD_NAME=dplnujrx8
CLOUDINARY_UPLOAD_PRESET=event_pictures
CLOUDINARY_PROFILE_UPLOAD_PRESET=profile_pictures
CLOUDINARY_RECEIPT_UPLOAD_PRESET=receipt_pictures
```

## Step 4: Build Release APK

Run these commands to build the release version:

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

The APK will be located at:

```
build/app/outputs/apk/release/app-release.apk
```

## Step 5: Build App Bundle (For Play Store)

For Google Play Store submission, build an app bundle instead:

```bash
flutter build appbundle --release
```

The bundle will be located at:

```
build/app/outputs/bundle/release/app-release.aab
```

## Step 6: Test the Release Build

You can install and test the APK on a device:

```bash
# Install on connected device
flutter install --release -v

# Or manually:
adb install -r build/app/outputs/apk/release/app-release.apk
```

## Troubleshooting

### "key.properties not found" error

- Make sure you created `android/key.properties`
- Verify the file path to storeFile is absolute and correct

### "Unable to find valid keystore" error

- Check that the storeFile path exists
- Verify the keystore file wasn't moved

### "Invalid password for keystore" error

- Verify storePassword in key.properties matches the keystore password

### "Key password incorrect" error

- Verify keyPassword in key.properties is correct

## Security Notes

- **Never** commit `android/key.properties` to Git
- **Never** share the keystore file or passwords
- Store the keystore file in a safe location
- Back up your keystore - losing it means you can't update the app on Play Store
- Consider storing credentials in a password manager

## App Details

- **Application ID**: com.vouchapp
- **Min SDK**: 21
- **Target SDK**: Latest (configured in flutter.compileSdkVersion)
- **Version**: 1.0.0+1 (update in pubspec.yaml)

## Features Included

✅ Supabase Authentication & Database
✅ Cloudinary Image Upload (Events, Profiles, Receipts)
✅ QR Code Generation & Scanning
✅ Local Notifications
✅ Encrypted Local Storage (shared_preferences)
✅ Image Picker Integration

All these services are configured and will work in the release build.

# GitHub Actions Setup Guide for macOS App Distribution

This guide will help you set up GitHub Actions to automatically build, sign, notarize, and distribute your macOS app.

## Prerequisites

1. **Apple Developer Account**: You need an active Apple Developer Program membership
2. **Developer ID Certificate**: For signing apps distributed outside the App Store
3. **App-Specific Password**: For notarization

## Step 1: Get a Developer ID Application Certificate

**Important**: You need a "Developer ID Application" certificate, not just an "Apple Development" certificate. The Developer ID certificate is specifically for distributing apps outside the App Store.

### Creating the Certificate:
1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/certificates/list)
2. Click the **"+"** button to create a new certificate
3. Select **"Developer ID Application"** (under "Production" section)
4. Follow the instructions to create a Certificate Signing Request (CSR)
5. Upload your CSR and download the certificate
6. Double-click the downloaded certificate to install it in Keychain Access

### Exporting the Certificate:
1. Open **Keychain Access** on your Mac
2. In the left sidebar, select **login** keychain
3. In the category list, select **Certificates**
4. Find your "Developer ID Application: Your Name (TEAM_ID)" certificate
5. Right-click on it and select **Export**
6. Choose **Personal Information Exchange (.p12)** format
7. Save it with a secure password (you'll need this password later)
8. Convert the .p12 file to base64:
   ```bash
   base64 -i /path/to/your/certificate.p12 | pbcopy
   ```
   This copies the base64 string to your clipboard

## Step 2: Get Your Team ID

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Sign in with your Apple ID
3. Go to **Membership** section
4. Your **Team ID** is displayed there (it's a 10-character alphanumeric string)

## Step 3: Create App-Specific Password

1. Go to [Apple ID account page](https://appleid.apple.com/)
2. Sign in with your Apple ID
3. In the **Security** section, under **App-Specific Passwords**, click **Generate Password**
4. Enter a label like "GitHub Actions Notarization"
5. Copy the generated password (you won't be able to see it again)

## Step 4: Find Your Code Sign Identity

Run this command in Terminal to find your code signing identity:
```bash
security find-identity -v -p codesigning
```

Look for the "Developer ID Application" certificate and copy the full name (e.g., "Developer ID Application: Your Name (TEAM_ID)")

## Step 5: Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets:

### Required Secrets:

1. **CERTIFICATES_P12**
   - Value: The base64 string from Step 1

2. **CERTIFICATES_P12_PASSWORD**
   - Value: The password you used when exporting the .p12 file

3. **DEVELOPMENT_TEAM**
   - Value: Your Team ID from Step 2

4. **CODE_SIGN_IDENTITY**
   - Value: The full certificate name from Step 4

5. **APPLE_ID**
   - Value: Your Apple ID email address

6. **APPLE_APP_PASSWORD**
   - Value: The app-specific password from Step 3

## Step 6: Test the Workflow

### Two Workflows Available:

1. **Development Workflow** (`build-and-release-dev.yml`): 
   - Runs on every push to main/master
   - Uses development signing (no special certificates needed)
   - Creates ZIP artifacts for testing
   - Good for testing the build process

2. **Production Workflow** (`build-and-release.yml`):
   - Runs on version tags (v1.0.0, etc.)
   - Requires Developer ID certificate setup
   - Creates signed, notarized DMG files
   - Used for public releases

### Testing Options:

#### Option 1: Test Development Build (No certificates needed)
1. Push your code to the main branch
2. The development workflow will run automatically
3. Download the ZIP artifact from the Actions tab

#### Option 2: Manual Trigger Production Workflow
1. Go to your repository → **Actions** tab
2. Select "Build and Release macOS App" workflow
3. Click **Run workflow** → **Run workflow**

#### Option 3: Create a Release Tag (Production)
```bash
git tag v1.0.0
git push origin v1.0.0
```

## What the Workflow Does

1. **Builds** your app using Xcode
2. **Code signs** it with your Developer ID certificate
3. **Notarizes** it with Apple (required for macOS Gatekeeper)
4. **Creates a DMG** installer
5. **Uploads** the DMG as a GitHub release (for tagged commits) or artifact

## Troubleshooting

### Common Issues:

1. **Code signing fails**: 
   - Verify your certificate is valid and not expired
   - Check that the CODE_SIGN_IDENTITY matches exactly

2. **Notarization fails**:
   - Ensure your Apple ID and app-specific password are correct
   - Verify your Team ID is correct

3. **Build fails**:
   - Check that your Xcode project builds locally first
   - Ensure all dependencies are properly configured

### Debugging:

- Check the Actions logs for detailed error messages
- Test locally with the same xcodebuild commands
- Verify all secrets are set correctly (no extra spaces, correct values)

## Security Notes

- Never commit certificates or passwords to your repository
- Use GitHub's encrypted secrets for all sensitive data
- Regularly rotate your app-specific passwords
- Keep your Developer ID certificate secure and backed up

## Distribution

Once the workflow completes successfully:

1. **For tagged releases**: Users can download the DMG from your GitHub releases page
2. **For development builds**: Download the artifact from the Actions run

The DMG will be properly signed and notarized, so users won't get security warnings when installing your app.

## Next Steps

- Consider adding automated testing before building
- Set up different workflows for development vs. release builds
- Add changelog generation for releases
- Consider using GitHub's dependency scanning for security 
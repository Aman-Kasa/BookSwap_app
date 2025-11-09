# Screenshot Capture Guide for Deliverables

## Required Screenshots for Maximum Points

### 1. Dart Analyzer Screenshot
**Command to run**: `flutter analyze`
**What to capture**: Terminal output showing analysis results
**File name**: `dart_analyzer_results.png`

**Steps**:
1. Open terminal in BookSwap_app directory
2. Run: `flutter analyze`
3. Take screenshot of the complete output
4. Save as `dart_analyzer_results.png`

### 2. Firebase Error Screenshots (2 required)

#### Screenshot 1: Firebase Authentication Error
**File name**: `firebase_auth_error.png`
**What to show**: Email verification error in app

**To reproduce**:
1. Run the app: `flutter run -d chrome`
2. Try to sign up with a new email
3. Attempt to sign in before verifying email
4. Capture the error message screen
5. Save as `firebase_auth_error.png`

#### Screenshot 2: Firestore Permission Error
**File name**: `firestore_permission_error.png`
**What to show**: Permission denied error (if reproducible)

**To reproduce** (if needed):
1. Temporarily modify Firestore rules to be restrictive
2. Try to create a book or swap offer
3. Capture the permission error
4. Restore proper rules
5. Save as `firestore_permission_error.png`

### 3. App Screenshots for Documentation

#### Additional screenshots to enhance documentation:

**Login Screen**: `login_screen.png`
**Browse Books**: `browse_books.png`
**Add Book**: `add_book.png`
**Chat Interface**: `chat_interface.png`
**My Listings**: `my_listings.png`
**Swap Offers**: `swap_offers.png`

## Screenshot Directory Structure
```
BookSwap_app/
├── screenshots/
│   ├── dart_analyzer_results.png      # Required
│   ├── firebase_auth_error.png        # Required
│   ├── firestore_permission_error.png # Required
│   ├── login_screen.png               # Optional
│   ├── browse_books.png               # Optional
│   ├── add_book.png                   # Optional
│   ├── chat_interface.png             # Optional
│   ├── my_listings.png                # Optional
│   └── swap_offers.png                # Optional
└── ...
```

## Quick Commands

### Create screenshots directory
```bash
mkdir -p screenshots
```

### Run app for screenshots
```bash
# For web (easier to screenshot)
flutter run -d chrome

# For mobile emulator
flutter run
```

### Run analyzer for screenshot
```bash
flutter analyze > analyzer_output.txt 2>&1
# Then screenshot the terminal or the output file
```

## Tips for Quality Screenshots

1. **Use high resolution**: Ensure screenshots are clear and readable
2. **Full screen capture**: Include relevant context around errors
3. **Consistent sizing**: Try to maintain similar dimensions
4. **Good lighting**: If using mobile, ensure screen is bright and clear
5. **No personal info**: Avoid showing personal data in screenshots

## Converting REFLECTION.md to PDF

### Option 1: Using Markdown to PDF tools
```bash
# Install pandoc (if not installed)
sudo apt install pandoc

# Convert to PDF
pandoc REFLECTION.md -o REFLECTION.pdf
```

### Option 2: Using online converters
1. Open REFLECTION.md in a markdown viewer
2. Use browser "Print to PDF" function
3. Or use online markdown to PDF converters

### Option 3: Using IDE/Editor
1. Open REFLECTION.md in VS Code with markdown preview
2. Use "Markdown PDF" extension
3. Export as PDF

## Final Checklist

- [ ] `dart_analyzer_results.png` - Terminal output of flutter analyze
- [ ] `firebase_auth_error.png` - Email verification error
- [ ] `firestore_permission_error.png` - Permission denied error
- [ ] `REFLECTION.pdf` - Converted from REFLECTION.md
- [ ] GitHub repository is public and accessible
- [ ] DESIGN_SUMMARY.md is complete (1-2 pages)
- [ ] All files are properly formatted and professional

## Submission Files Summary

**Required for Maximum Points**:
1. **REFLECTION.pdf** (with 2+ Firebase error screenshots)
2. **dart_analyzer_results.png** (Dart analyzer screenshot)
3. **GitHub Repository Link**: https://github.com/Aman-Kasa/BookSwap_app.git
4. **DESIGN_SUMMARY.md** (1-2 page design document)

**Supporting Documents** (already created):
- README.md (comprehensive documentation)
- PROJECT_REPORT.md (technical report)
- DELIVERABLES_SUMMARY.md (this summary)
- All source code files with clean structure
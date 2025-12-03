# App Store Submission Checklist

## Pre-Submission Preparation

### 1. Apple Developer Account
- [ ] Enrolled in Apple Developer Program ($99/year)
- [ ] Account in good standing
- [ ] Agreements accepted
- [ ] Tax information submitted
- [ ] Banking information added (for paid apps)

### 2. App Bundle & Certificates
- [ ] Bundle ID created: `com.yourdomain.Yomikae`
- [ ] App ID registered in Developer Portal
- [ ] Distribution certificate created
- [ ] Provisioning profile created
- [ ] Push notification entitlements (if needed)

---

## Build Preparation

### 3. Version & Build Number
- [ ] Version set to: `1.0`
- [ ] Build number: `1` (increment for each upload)
- [ ] Xcode project settings match Info.plist

**Check in Xcode**:
```
Target > General > Identity
- Display Name: Yomikae
- Bundle Identifier: com.yourdomain.Yomikae
- Version: 1.0
- Build: 1
```

### 4. App Configuration
- [ ] Deployment target: iOS 17.0+
- [ ] Supported devices: iPhone, iPad
- [ ] Supported orientations: Portrait (primary), Landscape (if needed)
- [ ] Required capabilities declared
- [ ] Optional capabilities configured

### 5. Build Settings
- [ ] Release configuration selected
- [ ] Bitcode enabled (if required)
- [ ] Symbols included for crash reports
- [ ] Code signing: Distribution certificate
- [ ] Provisioning profile: App Store distribution

### 6. Archive & Upload
- [ ] Clean build folder: `Cmd + Shift + K`
- [ ] Archive app: `Product > Archive`
- [ ] Validate archive (check for warnings)
- [ ] Upload to App Store Connect
- [ ] Wait for processing (10-30 minutes)

**Xcode Upload Process**:
```
1. Product > Archive
2. Window > Organizer
3. Select your archive
4. Click "Distribute App"
5. Choose "App Store Connect"
6. Upload
7. Wait for email confirmation
```

---

## App Store Connect Setup

### 7. App Information
- [ ] App name: **Yomikae - Learn Kanji via Chinese**
- [ ] Subtitle: **Learn Japanese Using Chinese**
- [ ] Primary language: English
- [ ] Bundle ID: Select from dropdown
- [ ] SKU: `yomikae-1.0`

### 8. Pricing & Availability
- [ ] Price: Free (or select tier)
- [ ] Availability: All countries (or select specific)
- [ ] Release: Automatic or Manual
- [ ] Pre-order: No (for 1.0)

### 9. App Privacy
- [ ] Privacy policy URL: `https://yourdomain.com/yomikae/privacy`
- [ ] Data collection: **None**
- [ ] Data types: **None collected**
- [ ] Third-party tracking: **No**
- [ ] Privacy nutrition label completed

**Privacy Questions to Answer**:
```
Do you collect data from this app?
→ No

Do you or third-party partners use data for tracking?
→ No

Does your app use advertising?
→ No
```

---

## Version Information

### 10. What's New (Version 1.0)
- [ ] Copied from METADATA.md
- [ ] Under 4000 characters
- [ ] Highlights key features
- [ ] Mentions it's the initial release

**Text**:
```
🎉 Welcome to Yomikae 1.0!

We're excited to launch Yomikae, the first app designed specifically
for Chinese speakers learning Japanese kanji.

✨ Complete Character Database
⚠️ False Friends Collection (40+ characters)
🔍 Smart Search (offline)
📚 JLPT Integration (N5-N1)
🎯 Learning Tools (bookmarks, history)

Thank you for being an early adopter!
加油！頑張って！
```

### 11. Description
- [ ] Copied from METADATA.md
- [ ] Under 4000 characters
- [ ] Compelling hook in first paragraph
- [ ] Key features highlighted
- [ ] Target audience clear
- [ ] No marketing claims that can't be verified

### 12. Keywords
- [ ] Copied from METADATA.md
- [ ] Under 100 characters
- [ ] Separated by commas
- [ ] No spaces after commas
- [ ] No repeated words
- [ ] No app name in keywords

**Keywords**:
```
japanese,kanji,chinese,mandarin,learn,jlpt,hanzi,language,study,pinyin,reading,onyomi,kunyomi
```

### 13. Promotional Text (Optional)
- [ ] Under 170 characters
- [ ] Can be updated anytime
- [ ] Highlights current features/offers

---

## Visual Assets

### 14. App Icon
- [ ] 1024x1024 PNG uploaded
- [ ] No transparency
- [ ] No rounded corners (iOS adds them)
- [ ] Matches in-app icon
- [ ] High quality, no compression artifacts

### 15. iPhone Screenshots (Required)
**6.7" Display (1290 x 2796)**:
- [ ] Screenshot 1: Hero/Search
- [ ] Screenshot 2: Character Detail
- [ ] Screenshot 3: False Friends List
- [ ] Screenshot 4: False Friend Detail
- [ ] Screenshot 5: Search Results

**6.5" Display (1242 x 2688)**:
- [ ] Same 5 screenshots, resized

### 16. iPad Screenshots (Optional)
**12.9" Display (2048 x 2732)**:
- [ ] All 5 screenshots captured on iPad

### 17. App Preview Video (Optional)
- [ ] Video uploaded (15-30 seconds)
- [ ] Correct format (.mov or .mp4)
- [ ] Correct resolution
- [ ] No audio issues
- [ ] Demonstrates key features

---

## App Review Information

### 18. Contact Information
- [ ] First name: [Your first name]
- [ ] Last name: [Your last name]
- [ ] Phone number: [Your phone]
- [ ] Email: support@yourdomain.com

### 19. Demo Account (if needed)
- [ ] Demo username: N/A (no login required)
- [ ] Demo password: N/A
- [ ] Account notes: "No login required"

### 20. Notes for Reviewer
```
Thank you for reviewing Yomikae!

This app is designed for Chinese speakers learning Japanese. Key features:
- Dual Chinese/Japanese character readings
- False friends database (characters that mean different things)
- Offline functionality - no internet required
- No user accounts or data collection

Test suggestions:
1. Search for a character like "手" to see dual readings
2. Navigate to False Friends tab to see the unique feature
3. Search works offline - can be tested in airplane mode

The app is fully functional and ready for use. No special setup needed.

Thank you!
```

---

## Age Rating

### 21. Content Rating Questionnaire
Answer all questions about content:

- [ ] Cartoon/Fantasy Violence: None
- [ ] Realistic Violence: None
- [ ] Sexual Content: None
- [ ] Profanity/Crude Humor: None
- [ ] Medical/Treatment Information: None
- [ ] Alcohol/Tobacco/Drug Use: None
- [ ] Gambling: None
- [ ] Horror/Fear Themes: None
- [ ] Mature/Suggestive Themes: None
- [ ] Unrestricted Web Access: No
- [ ] User-Generated Content: No

**Result**: Age 4+ (Everyone)

---

## Legal & Compliance

### 22. Export Compliance
- [ ] Does your app use encryption? **No** (or follow guidelines if yes)
- [ ] Export compliance declaration completed

### 23. Content Rights
- [ ] You own all content in the app
- [ ] Licensed content properly attributed
- [ ] No copyrighted material without permission
- [ ] Character data sources are legitimate

### 24. Government Restrictions
- [ ] App doesn't violate any country's laws
- [ ] No restricted content for specific regions

---

## Localization

### 25. English (Primary)
- [ ] App name localized
- [ ] Description localized
- [ ] Keywords localized
- [ ] Screenshots localized (optional)

### 26. Simplified Chinese
- [ ] All metadata translated
- [ ] Keywords appropriate for Chinese market
- [ ] Screenshots with Chinese UI (optional)

### 27. Traditional Chinese
- [ ] All metadata translated
- [ ] Taiwan-specific keywords

### 28. Japanese
- [ ] All metadata translated
- [ ] Japan-specific keywords

---

## Final Checks

### 29. App Functionality
- [ ] Tested on physical iPhone
- [ ] Tested on physical iPad (if supported)
- [ ] Tested on multiple iOS versions (17.0+)
- [ ] No crashes on launch
- [ ] All features working
- [ ] Search functionality tested
- [ ] Database populates correctly
- [ ] False friends display properly
- [ ] Navigation flows correctly
- [ ] Dark mode works (if supported)

### 30. Performance
- [ ] Launch time < 2 seconds
- [ ] No memory leaks
- [ ] Smooth scrolling
- [ ] Responsive UI
- [ ] Battery usage acceptable

### 31. Quality Assurance
- [ ] No placeholder text
- [ ] No Lorem ipsum content
- [ ] No "TODO" comments visible
- [ ] No test data visible to users
- [ ] All strings translated
- [ ] No broken links
- [ ] Proper error handling

### 32. App Store Guidelines Compliance
Review against [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/):

- [ ] 1.1 - Objectionable content: None
- [ ] 2.1 - App completeness: Fully functional
- [ ] 2.3 - Accurate metadata: Yes
- [ ] 3.1 - In-app purchases: None (for now)
- [ ] 4.0 - Design: Follows iOS guidelines
- [ ] 5.1 - Privacy: Policy provided, no data collection

---

## Support Infrastructure

### 33. Website
- [ ] Marketing page live: `https://yourdomain.com/yomikae`
- [ ] Support page live: `https://yourdomain.com/yomikae/support`
- [ ] Privacy policy live: `https://yourdomain.com/yomikae/privacy`
- [ ] All links working
- [ ] Contact form functional

### 34. Support Channels
- [ ] Support email monitored: support@yourdomain.com
- [ ] Auto-reply configured
- [ ] FAQ page available
- [ ] Response process defined

### 35. Social Media (Optional)
- [ ] Twitter/X account created: @yomikaeapp
- [ ] Instagram account: @yomikaeapp
- [ ] Launch post drafted
- [ ] Community guidelines written

---

## Submission

### 36. Final Review
- [ ] Re-read app description for typos
- [ ] Check all screenshots are correct
- [ ] Verify keywords
- [ ] Confirm pricing
- [ ] Review privacy settings
- [ ] Check support URLs

### 37. Submit for Review
- [ ] Click "Submit for Review"
- [ ] Review submission summary
- [ ] Confirm submission
- [ ] Note submission date/time

### 38. Post-Submission
- [ ] Save confirmation email
- [ ] Set calendar reminder to check status (24 hours)
- [ ] Prepare for possible rejection (common first time)
- [ ] Draft responses to common rejection reasons

---

## Common Rejection Reasons (Be Prepared)

### 1. Metadata Issues
**Rejection**: "App name too long" or "Keywords inappropriate"
**Fix**: Shorten name, revise keywords

### 2. Crash on Launch
**Rejection**: "App crashed during review"
**Fix**: Test more thoroughly, submit new build

### 3. Missing Features
**Rejection**: "App incomplete or lacks functionality"
**Fix**: Ensure all features work, add more content

### 4. Privacy Policy Issues
**Rejection**: "Privacy policy not accessible" or "doesn't match data collection"
**Fix**: Verify URL works, update policy

### 5. Screenshots Don't Match App
**Rejection**: "Screenshots show features not in app"
**Fix**: Use actual app screenshots only

---

## Review Timeline

**Typical Timeline**:
- Submission: Day 0
- "In Review": Day 1-3
- Approval/Rejection: Day 2-5
- If approved, live in 24-48 hours

**Status Checks**:
- App Store Connect Dashboard
- Email notifications
- Mobile app: "App Store Connect"

---

## If Rejected

### Response Process
1. Read rejection reason carefully
2. Review attached screenshots/videos
3. Fix all issues mentioned
4. Test thoroughly
5. Respond in Resolution Center (if clarification needed)
6. Submit new build (if code changes needed)
7. Resubmit for review

### Common First Rejection
Don't panic! ~40% of apps are rejected first time. It's part of the process.

---

## If Approved

### Launch Day
- [ ] App goes live automatically (or manually release)
- [ ] Download app yourself to verify
- [ ] Test on fresh device
- [ ] Share on social media
- [ ] Email early supporters
- [ ] Post in communities (Reddit, forums)
- [ ] Monitor reviews closely

### First Week
- [ ] Respond to all reviews (positive and negative)
- [ ] Track crash reports
- [ ] Monitor user feedback
- [ ] Fix critical bugs immediately
- [ ] Plan first update (1-2 weeks post-launch)

### First Month
- [ ] Analyze metrics (downloads, retention)
- [ ] Gather feature requests
- [ ] Plan roadmap for next 3 versions
- [ ] Consider ASO (App Store Optimization) tweaks

---

## Post-Launch Checklist

- [ ] Thank early users on social media
- [ ] Ask for reviews (politely, not too pushy)
- [ ] Monitor App Store ranking for keywords
- [ ] Set up analytics (if using)
- [ ] Create feedback collection system
- [ ] Plan version 1.1 features
- [ ] Celebrate! 🎉

---

## Emergency Contacts

**Apple**:
- Developer Support: https://developer.apple.com/support/
- App Review: Through App Store Connect Resolution Center
- Phone: 1-800-633-2152 (US)

**Resources**:
- App Store Connect: https://appstoreconnect.apple.com
- Developer Forums: https://developer.apple.com/forums/
- Guidelines: https://developer.apple.com/app-store/review/guidelines/

---

## Useful Commands

### Build & Archive
```bash
# Clean build
xcodebuild clean -project Yomikae.xcodeproj -scheme Yomikae

# Archive for distribution
xcodebuild archive \
  -project Yomikae.xcodeproj \
  -scheme Yomikae \
  -archivePath ./build/Yomikae.xcarchive

# Export for App Store
xcodebuild -exportArchive \
  -archivePath ./build/Yomikae.xcarchive \
  -exportPath ./build/ \
  -exportOptionsPlist ExportOptions.plist
```

### Version Bump
```bash
# Increment build number
agvtool next-version -all

# Set version number
agvtool new-marketing-version 1.1
```

---

## Notes

- **First submission typically takes 2-5 days**
- **Subsequent updates usually faster (1-3 days)**
- **Holiday seasons may be slower**
- **Apple doesn't review on major holidays**
- **Rejections are normal - don't be discouraged**

---

**Created**: 2025-12-02
**Version**: 1.0
**Status**: Pre-Submission

---

## Quick Status

Current Status: ☐ Ready to Submit

- [ ] All checklist items completed
- [ ] Build uploaded and processed
- [ ] All metadata entered
- [ ] All assets uploaded
- [ ] Review information provided
- [ ] Submit button clicked

**Next Step**: Complete remaining items, then submit!

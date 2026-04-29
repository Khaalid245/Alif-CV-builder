# Typography & Icon System Guide

## Typography Usage

### Text Styles - ALWAYS use AppTypography

```dart
// ✅ CORRECT - Use AppTypography styles
Text("Page Title", style: AppTypography.h1)
Text("Section Heading", style: AppTypography.h2)
Text("Card Title", style: AppTypography.h3)
Text("Body content", style: AppTypography.body)
Text("Form label", style: AppTypography.label)
Text("Small caption", style: AppTypography.caption)
Text("Button text", style: AppTypography.button)
Text("UPPERCASE LABEL", style: AppTypography.uppercase)

// ✅ CORRECT - Override color when needed
Text("Error message", style: AppTypography.body.copyWith(
  color: AppColors.error,
))

// ❌ WRONG - Never use raw TextStyle
Text("Title", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
Text("Body", style: TextStyle(fontSize: 16, color: Colors.grey))
```

### Text Colors - ONLY use these colors

```dart
// ✅ CORRECT - Use defined text colors
AppColors.textPrimary   // #0A0A0A - Headings, important labels
AppColors.textSecondary // #4A4A4A - Body text, descriptions  
AppColors.textHint      // #9E9E9E - Placeholders, captions
AppColors.primary       // #1565C0 - Links, interactive text
AppColors.success       // #2E7D32 - Success messages
AppColors.error         // #C62828 - Error messages
AppColors.warning       // #E65100 - Warning messages
Colors.white            // Only on blue button backgrounds

// ❌ WRONG - Never use these
Colors.black            // Too harsh
Colors.grey             // Too vague
Color(0xFF000000)       // Use textPrimary instead
```

## Icon System

### Icon Package - ONLY Lucide Icons

```dart
// ✅ CORRECT - Use Lucide icons
import 'package:lucide_icons/lucide_icons.dart';

Icon(LucideIcons.download, size: 20, color: AppColors.primary)
Icon(LucideIcons.user, size: 24, color: AppColors.textPrimary)
Icon(LucideIcons.checkCircle, size: 16, color: AppColors.success)

// ❌ WRONG - Never use Material icons
Icon(Icons.download)              // Material filled
Icon(Icons.download_outlined)     // Still Material
Icon(Icons.person)                // Material filled
```

### Icon Sizes by Context

```dart
// 16px - Inline with text, badges, chips
Icon(LucideIcons.check, size: 16)

// 20px - Standard UI icons (forms, lists)
Icon(LucideIcons.search, size: 20)

// 24px - App bar, bottom nav, main actions
Icon(LucideIcons.menu, size: 24)

// 28-36px - Feature icons, empty states
Icon(LucideIcons.fileText, size: 32)
```

### Icon Colors by Usage

```dart
// Active/Interactive icons
Icon(LucideIcons.edit2, size: 20, color: AppColors.primary)

// Inactive/Decorative icons  
Icon(LucideIcons.info, size: 20, color: AppColors.textPrimary.withOpacity(0.4))

// Inside blue buttons
Icon(LucideIcons.download, size: 16, color: Colors.white)

// Status icons
Icon(LucideIcons.checkCircle, size: 20, color: AppColors.success)
Icon(LucideIcons.xCircle, size: 20, color: AppColors.error)
Icon(LucideIcons.alertTriangle, size: 20, color: AppColors.warning)
```

## Common Icon Mappings

### Navigation
- `LucideIcons.layoutDashboard` → Dashboard
- `LucideIcons.users` → Students/Users  
- `LucideIcons.fileText` → CVs/Documents
- `LucideIcons.clipboardList` → Audit logs
- `LucideIcons.arrowLeft` → Back navigation
- `LucideIcons.x` → Close/Cancel

### CV Sections
- `LucideIcons.graduationCap` → Education
- `LucideIcons.briefcase` → Experience
- `LucideIcons.zap` → Skills
- `LucideIcons.globe` → Languages
- `LucideIcons.code2` → Projects
- `LucideIcons.award` → Certifications
- `LucideIcons.user` → Personal Info

### Actions
- `LucideIcons.download` → Download
- `LucideIcons.upload` → Upload
- `LucideIcons.edit2` → Edit
- `LucideIcons.trash2` → Delete
- `LucideIcons.plus` → Add/Create
- `LucideIcons.eye` → View/Preview
- `LucideIcons.search` → Search

### Status
- `LucideIcons.checkCircle` → Success/Complete
- `LucideIcons.xCircle` → Error/Failed
- `LucideIcons.alertCircle` → Warning
- `LucideIcons.clock` → Pending/Time
- `LucideIcons.lock` → Secure/Protected

## Complete Example

```dart
class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page title
        Text(
          'CV Dashboard',
          style: AppTypography.h1,
        ),
        
        // Section with icon
        Row(
          children: [
            Icon(
              LucideIcons.graduationCap,
              size: 20,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Education',
              style: AppTypography.h3,
            ),
          ],
        ),
        
        // Body text
        Text(
          'Add your educational background to strengthen your CV.',
          style: AppTypography.body,
        ),
        
        // Caption with custom color
        Text(
          'Last updated 2 hours ago',
          style: AppTypography.caption.copyWith(
            color: AppColors.textHint,
          ),
        ),
        
        // Button with icon
        AppButton(
          text: 'Add Education',
          icon: LucideIcons.plus,
          onPressed: () {},
        ),
      ],
    );
  }
}
```

## Font Weights Reference

- **400** → Body text, captions, placeholders
- **500** → Labels, meta text, form labels  
- **600** → Section headings, card titles, buttons
- **700** → Page titles, strong headings
- **800** → Display headings only

**Never use weights 300 or 900**

## Letter Spacing Reference

- **Display/H1** → -0.02em (tight, confident)
- **H2/H3** → -0.01em  
- **Body** → 0 (default)
- **Buttons** → 0.01em (slightly open)
- **Uppercase** → 0.07em (wide, readable)
# Modern Dashboard Header System

A responsive, modern SaaS dashboard header system for Flutter applications with adaptive layouts for mobile, tablet, and desktop.

## Overview

This header system provides a professional, clean interface that adapts seamlessly across different screen sizes while maintaining consistent functionality and modern design principles.

## Features

### 🎨 **Design Features**
- **Modern SaaS Styling**: Clean, minimal design inspired by top dashboard applications
- **Responsive Layout**: Adapts perfectly to mobile, tablet, and desktop screens
- **Soft Shadows**: Subtle elevation effects for depth and hierarchy
- **Purple Accent Theme**: Consistent purple branding throughout
- **Rounded Elements**: Modern rounded corners for search fields and buttons
- **Smooth Animations**: 200ms transitions for interactive elements

### 📱 **Responsive Behavior**

#### Desktop (> 1024px)
- **Horizontal Layout**: Spacious alignment with generous padding
- **Search Bar**: Full-featured search with focus states and animations
- **User Profile Section**: Complete profile card with name, email, and dropdown
- **Greeting & Date**: Large typography with calendar icon
- **Actions**: Multiple action buttons with proper spacing

#### Tablet (768-1024px)
- **Compact Header**: Optimized for medium screens
- **Menu Button**: Hamburger menu for sidebar control
- **Simplified Layout**: Essential elements with good spacing
- **Notification Badge**: Clear notification indicators

#### Mobile (< 768px)
- **Minimal Header**: Compact design for small screens
- **Essential Elements**: Menu, greeting, notifications, and avatar only
- **Overlay Search**: Full-screen search overlay when needed
- **Touch-Friendly**: Larger touch targets for mobile interaction

## Components

### ModernDashboardHeader

The main header component with comprehensive responsive behavior.

**Properties:**
```dart
ModernDashboardHeader({
  String? userName,              // User's display name
  String? userEmail,             // User's email address
  String? userAvatar,            // Avatar image URL
  VoidCallback? onProfileTap,    // Profile section tap handler
  VoidCallback? onNotificationTap, // Notification button handler
  VoidCallback? onMenuTap,       // Menu button handler (mobile/tablet)
  Function(String)? onSearch,    // Search input handler
  int notificationCount = 0,     // Notification badge count
  bool showSearch = true,        // Show search bar (desktop only)
  List<Widget>? additionalActions, // Extra action buttons
})
```

### DashboardSectionHeader

Specialized header for dashboard sections and pages.

```dart
DashboardSectionHeader({
  required String title,         // Section title
  String? subtitle,              // Optional subtitle
  List<Widget>? actions,         // Action buttons
  Widget? leading,               // Leading widget (icon, etc.)
})
```

### DashboardStatsHeader

Quick stats display for dashboard overview.

```dart
DashboardStatsHeader({
  required List<DashboardStat> stats, // Statistics to display
})

// DashboardStat model
DashboardStat({
  required String label,         // Stat label
  required String value,         // Stat value
  required IconData icon,        // Stat icon
  required Color color,          // Accent color
  double? trend,                 // Trend indicator (+/-)
})
```

## Usage Examples

### Basic Header Implementation

```dart
import 'package:flutter/material.dart';
import '../core/widgets/modern_dashboard_header.dart';

class MyDashboardScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ModernDashboardHeader(
            userName: 'John Doe',
            userEmail: 'john@example.com',
            onProfileTap: () => showProfileMenu(),
            onNotificationTap: () => showNotifications(),
            onMenuTap: () => openSidebar(),
            onSearch: (query) => handleSearch(query),
            notificationCount: 3,
            additionalActions: [
              IconButton(
                onPressed: () => showHelp(),
                icon: Icon(Icons.help_outline),
              ),
            ],
          ),
          Expanded(
            child: YourDashboardContent(),
          ),
        ],
      ),
    );
  }
}
```

### Complete Layout with Header

```dart
ModernDashboardLayoutWithHeader(
  currentIndex: _currentNavIndex,
  onNavigationChanged: _handleNavigation,
  userName: user.fullName,
  userEmail: user.email,
  userAvatar: user.avatarUrl,
  onProfileTap: _showProfileMenu,
  onNotificationTap: _showNotifications,
  onSearch: _handleSearch,
  notificationCount: _notificationCount,
  showSearch: true,
  headerActions: [
    QuickActionButton(),
    HelpButton(),
  ],
  child: YourDashboardContent(),
)
```

### Stats Header Implementation

```dart
DashboardStatsHeader(
  stats: [
    DashboardStat(
      label: 'Total Users',
      value: '1,234',
      icon: LucideIcons.users,
      color: ModernSaaSDashboardTheme.accentPurple,
      trend: 12.5, // 12.5% increase
    ),
    DashboardStat(
      label: 'Revenue',
      value: '\$45.2K',
      icon: LucideIcons.dollarSign,
      color: ModernSaaSDashboardTheme.success,
      trend: -2.1, // 2.1% decrease
    ),
    // More stats...
  ],
)
```

### Mobile Search Integration

```dart
// Show mobile search overlay
void _showMobileSearch() {
  setState(() => _showMobileSearch = true);
}

// In build method
Stack(
  children: [
    YourMainContent(),
    
    if (_showMobileSearch)
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.white.withOpacity(0.95),
          child: SafeArea(
            child: MobileSearchWidget(
              onSearch: _handleSearch,
              onClose: () => setState(() => _showMobileSearch = false),
            ),
          ),
        ),
      ),
  ],
)
```

## Layout Behavior

### Desktop Layout
```
┌─────────────────────────────────────────────────────────────┐
│ Good morning, John    [Search Bar]    [🔔] [Profile Card]   │
│ Monday, January 15, 2024                                    │
└─────────────────────────────────────────────────────────────┘
```

**Features:**
- Large greeting with personalized message
- Full-featured search bar with focus animations
- Complete user profile section with dropdown
- Multiple action buttons
- Generous spacing and typography

### Tablet Layout
```
┌─────────────────────────────────────────────────────────────┐
│ [☰] Good morning, John              [🔔] [Avatar]          │
│     Monday, January 15, 2024                               │
└─────────────────────────────────────────────────────────────┘
```

**Features:**
- Hamburger menu for sidebar control
- Compact greeting and date
- Essential actions only
- Optimized spacing for medium screens

### Mobile Layout
```
┌─────────────────────────────────────────────────────────────┐
│ [☰] Good morning     [🔔] [Avatar]                         │
│     Jan 15, 2024                                           │
└─────────────────────────────────────────────────────────────┘
```

**Features:**
- Minimal essential elements
- Compact date format
- Touch-friendly button sizes
- Overlay search when needed

## Styling System

### Colors

```dart
// Header background
ModernSaaSDashboardTheme.surfaceBackground  // #FFFFFF

// Text colors
ModernSaaSDashboardTheme.primaryText        // #0F172A (greeting)
ModernSaaSDashboardTheme.tertiaryText       // #64748B (date, icons)
ModernSaaSDashboardTheme.mutedText          // #94A3B8 (placeholders)

// Interactive elements
ModernSaaSDashboardTheme.accentPurple       // #7C3AED (focus, active)
ModernSaaSDashboardTheme.hover              // #F8FAFC (button backgrounds)
ModernSaaSDashboardTheme.borderLight        // #F1F5F9 (borders)

// Status colors
ModernSaaSDashboardTheme.error              // #DC2626 (notification badge)
ModernSaaSDashboardTheme.success            // #059669 (positive trends)
```

### Typography

```dart
// Desktop greeting
ModernSaaSDashboardTheme.displaySmall       // 24px, bold, -0.5 letter-spacing

// Tablet greeting  
ModernSaaSDashboardTheme.headlineLarge      // 20px, bold

// Mobile greeting
ModernSaaSDashboardTheme.headlineSmall      // 16px, bold

// Date text
ModernSaaSDashboardTheme.bodyMedium         // 14px, medium weight
ModernSaaSDashboardTheme.bodySmall          // 12px (mobile)

// Search placeholder
ModernSaaSDashboardTheme.bodyMedium         // 14px, muted color
```

### Spacing & Sizing

```dart
// Header heights
Desktop: 88px
Tablet:  80px  
Mobile:  64px

// Horizontal padding
Desktop: 32px
Tablet:  24px
Mobile:  16px

// Avatar sizes
Desktop: 32px (in profile section)
Tablet:  40px
Mobile:  32px

// Button sizes
Desktop: 40x40px
Tablet:  40x40px
Mobile:  32x32px

// Search bar
Max width: 400px
Height: 44px
Border radius: 12px
```

## Interactive States

### Search Bar (Desktop)

**Default State:**
- Light gray background (#F8FAFC)
- Light border (#F1F5F9)
- Muted placeholder text

**Focused State:**
- White background
- Purple border (#7C3AED, 2px)
- Purple search icon
- Subtle shadow with purple tint

**With Content:**
- Clear button (X) appears
- Active search icon

### Notification Button

**Default:**
- Gray icon on light background
- Subtle hover effect

**With Notifications:**
- Red badge with count
- White text on red background
- Badge positioned top-right

**Badge Behavior:**
- Shows count up to 99
- Shows "99+" for counts > 99
- Disappears when count = 0

### User Avatar

**Default:**
- Gradient background (purple theme)
- User initials in white
- Subtle shadow

**With Image:**
- Rounded image with fallback to initials
- Error handling for broken images

**Interactive:**
- Hover effect on desktop
- Tap feedback on mobile
- Opens profile menu

## Animation Details

### Search Bar Focus
```dart
Duration: 200ms
Curve: Curves.easeInOut
Properties: background, border, shadow
```

### Notification Badge
```dart
Duration: 300ms
Curve: Curves.elasticOut
Properties: scale, opacity
```

### Mobile Search Overlay
```dart
Duration: 300ms
Curve: Curves.easeOut
Properties: scale, opacity
Entry: Scale from 0.0 to 1.0
```

### Hover Effects
```dart
Duration: 150ms
Curve: Curves.easeInOut
Properties: background, elevation
```

## Accessibility Features

### Screen Reader Support
- Semantic labels for all interactive elements
- Proper heading hierarchy
- Button roles and states

### Keyboard Navigation
- Tab order follows visual layout
- Enter/Space activation for buttons
- Escape to close overlays

### High Contrast Support
- WCAG AA compliant color ratios
- Focus indicators meet accessibility standards
- Clear visual hierarchy

### Touch Accessibility
- Minimum 44px touch targets
- Adequate spacing between elements
- Clear visual feedback

## Best Practices

### 1. Consistent Theming
```dart
// Always use theme constants
Container(
  decoration: BoxDecoration(
    color: ModernSaaSDashboardTheme.surfaceBackground,
    border: Border.all(
      color: ModernSaaSDashboardTheme.borderLight,
    ),
  ),
)
```

### 2. Responsive Design
```dart
// Use ResponsiveBuilder for adaptive layouts
ResponsiveBuilder(
  builder: (context, deviceType) {
    return deviceType.isMobile 
        ? MobileHeader() 
        : DesktopHeader();
  },
)
```

### 3. Performance Optimization
```dart
// Dispose controllers properly
@override
void dispose() {
  _searchController.dispose();
  _focusNode.dispose();
  super.dispose();
}
```

### 4. State Management
```dart
// Handle search state efficiently
void _handleSearch(String query) {
  // Debounce search input
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 300), () {
    // Perform search
    searchProvider.search(query);
  });
}
```

## Integration Examples

### With Riverpod State Management

```dart
final notificationProvider = StateNotifierProvider<NotificationController, int>(
  (ref) => NotificationController(),
);

class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationCount = ref.watch(notificationProvider);
    
    return ModernDashboardHeader(
      notificationCount: notificationCount,
      onNotificationTap: () {
        ref.read(notificationProvider.notifier).markAllAsRead();
        showNotifications();
      },
    );
  }
}
```

### With Search Functionality

```dart
class SearchController extends StateNotifier<String> {
  SearchController() : super('');
  
  void search(String query) {
    state = query;
    // Perform search logic
  }
}

// In widget
onSearch: (query) => ref.read(searchProvider.notifier).search(query),
```

### With Navigation

```dart
void _handleNavigation() {
  // Close mobile search if open
  if (_showMobileSearch) {
    setState(() => _showMobileSearch = false);
  }
  
  // Navigate
  context.go('/new-route');
}
```

This header system provides a solid foundation for modern dashboard applications while maintaining flexibility for customization and excellent user experience across all devices.
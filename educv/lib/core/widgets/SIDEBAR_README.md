# Modern SaaS Sidebar System

A professional, responsive sidebar system for Flutter dashboard applications inspired by Linear, Vercel, Notion, and Stripe.

## Overview

This sidebar system provides a modern, professional navigation experience that adapts seamlessly across different device types while maintaining consistent branding and user experience.

## Features

### 🎨 **Design Features**
- **Modern Professional Styling**: Clean, minimal design inspired by top SaaS platforms
- **Gradient Brand Elements**: Beautiful gradient logo and user avatar
- **Smooth Animations**: 300ms transitions for collapse/expand and hover effects
- **Purple Active Indicators**: Consistent purple accent color for active states
- **Soft Hover Effects**: Subtle background changes on hover
- **Rounded Active Items**: Modern rounded corners for active menu items

### 📱 **Responsive Behavior**
- **Desktop (> 1024px)**: Fixed left sidebar (280px width)
- **Tablet (768-1024px)**: Collapsible sidebar with overlay
- **Mobile (< 768px)**: Hidden sidebar, bottom navigation instead

### 🧩 **Component Structure**
- **ModernSaaSSidebar**: Main sidebar component
- **ResponsiveSidebarWrapper**: Responsive wrapper handling different layouts
- **ModernResponsiveDashboardLayout**: Complete dashboard layout system
- **SidebarItem**: Reusable sidebar item widget

## Sidebar Sections

The sidebar is organized into logical sections:

### Main Navigation
- **Dashboard** - Overview and analytics
- **My CV** - CV profile management

### CV Builder
- **Experience** - Work experience management
- **Skills** - Skills and competencies
- **Projects** - Project portfolio
- **Downloads** - Generated CV downloads

### Tools
- **AI Assistant** - AI-powered CV suggestions (with "NEW" badge)
- **Templates** - CV template gallery

### Account
- **Settings** - Application settings
- **Account** - User account management

## Usage

### Basic Implementation

```dart
import 'package:flutter/material.dart';
import '../core/layout/modern_responsive_dashboard_layout.dart';
import '../core/widgets/modern_dashboard_cards.dart';

class MyDashboardScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return ModernResponsiveDashboardLayout(
      title: 'Dashboard',
      currentIndex: 0,
      onNavigationChanged: (index) {
        // Handle navigation
        switch (index) {
          case 0: context.go('/dashboard'); break;
          case 1: context.go('/cv/profile'); break;
          // ... more cases
        }
      },
      userName: 'John Doe',
      userEmail: 'john@example.com',
      onProfileTap: () => showProfileMenu(),
      onUpgradeTap: () => showUpgradeDialog(),
      child: ModernDashboardContent(
        children: [
          ModernWelcomeCard(...),
          // ... more content
        ],
      ),
    );
  }
}
```

### Advanced Customization

```dart
ModernResponsiveDashboardLayout(
  title: 'Custom Dashboard',
  currentIndex: _currentIndex,
  onNavigationChanged: _handleNavigation,
  
  // User information
  userName: user.fullName,
  userEmail: user.email,
  userAvatar: user.avatarUrl, // Optional avatar URL
  
  // Callbacks
  onProfileTap: _showProfileMenu,
  onUpgradeTap: _showUpgradeFlow,
  
  // Premium card configuration
  showPremiumCard: !user.isPremium,
  
  // Top bar actions
  actions: [
    NotificationButton(),
    ProfileButton(),
  ],
  
  child: YourContent(),
)
```

### Navigation Index Mapping

```dart
// Sidebar navigation indices
const int dashboardIndex = 0;
const int myCVIndex = 1;
const int experienceIndex = 2;
const int skillsIndex = 3;
const int projectsIndex = 4;
const int downloadsIndex = 5;
const int aiAssistantIndex = 6;
const int templatesIndex = 7;
const int settingsIndex = 8;
const int accountIndex = 9;

void _handleNavigation(int index) {
  setState(() => _currentIndex = index);
  
  switch (index) {
    case dashboardIndex:
      context.go('/dashboard');
      break;
    case myCVIndex:
      context.go('/cv/profile');
      break;
    case experienceIndex:
      context.go('/cv/experience');
      break;
    // ... handle all cases
  }
}
```

## Component Details

### ModernSaaSSidebar

The main sidebar component with the following features:

**Properties:**
- `currentIndex`: Currently active navigation index
- `onNavigationChanged`: Callback for navigation changes
- `isCollapsed`: Whether sidebar is collapsed (tablet mode)
- `userName`, `userEmail`, `userAvatar`: User information
- `onProfileTap`: Profile section tap callback
- `onUpgradeTap`: Premium upgrade callback
- `showPremiumCard`: Whether to show premium upgrade card

**Sections:**
1. **Header**: Logo and brand name with gradient styling
2. **Navigation**: Organized menu items with sections
3. **Premium Card**: Upgrade promotion (when applicable)
4. **User Profile**: User info and profile access

### ResponsiveSidebarWrapper

Handles responsive behavior across devices:

**Desktop Behavior:**
- Fixed sidebar always visible
- Content area adjusted for sidebar width
- No overlay or collapse functionality

**Tablet Behavior:**
- Sidebar slides in from left when opened
- Dark overlay covers content when sidebar is open
- Tap overlay or navigate to close sidebar
- Smooth 300ms animations

**Mobile Behavior:**
- Sidebar completely hidden
- Bottom navigation bar instead
- Simplified navigation with 4 main items

### Responsive Breakpoints

```dart
// Device type detection
DeviceType.mobile    // < 768px
DeviceType.tablet    // 768px - 1024px  
DeviceType.desktop   // > 1024px
```

## Styling System

### Colors

```dart
// Primary brand colors
ModernSaaSDashboardTheme.accentPurple        // #7C3AED
ModernSaaSDashboardTheme.accentPurpleLight   // #8B5CF6

// Background colors
ModernSaaSDashboardTheme.surfaceBackground   // #FFFFFF
ModernSaaSDashboardTheme.background          // #FAFBFC

// Text colors
ModernSaaSDashboardTheme.primaryText         // #0F172A
ModernSaaSDashboardTheme.secondaryText       // #475569
ModernSaaSDashboardTheme.tertiaryText        // #64748B

// Interactive states
ModernSaaSDashboardTheme.hover               // #F8FAFC
ModernSaaSDashboardTheme.pressed             // #F1F5F9
```

### Animations

```dart
// Sidebar collapse/expand
Duration: 300ms
Curve: Curves.easeInOut

// Hover effects
Duration: 200ms
Curve: Curves.easeInOut

// Overlay fade
Duration: 300ms
Curve: Curves.easeInOut
```

### Spacing

```dart
// Sidebar dimensions
sidebarWidth: 280px
sidebarCollapsedWidth: 80px

// Internal spacing
padding: 16px - 24px (responsive)
itemSpacing: 2px vertical
sectionSpacing: 24px
```

## Premium Card

The premium upgrade card appears near the bottom of the sidebar:

**Features:**
- Gradient background with purple accent
- Crown icon for premium branding
- Compelling upgrade message
- Call-to-action button
- Automatically hidden for premium users

**Customization:**
```dart
ModernResponsiveDashboardLayout(
  showPremiumCard: !user.isPremium,
  onUpgradeTap: () {
    // Handle upgrade flow
    showUpgradeDialog();
  },
)
```

## User Profile Section

Located at the bottom of the sidebar:

**Features:**
- Gradient avatar with user initials
- User name and email display
- Tap to open profile menu
- Responsive sizing (collapses on tablet when needed)

**Profile Menu Integration:**
```dart
void _showProfileMenu() {
  showModalBottomSheet(
    context: context,
    builder: (context) => ProfileBottomSheet(
      user: currentUser,
      onSettings: () => navigateToSettings(),
      onAccount: () => navigateToAccount(),
      onLogout: () => handleLogout(),
    ),
  );
}
```

## Mobile Bottom Navigation

When on mobile devices, the sidebar is replaced with a bottom navigation bar:

**Items:**
- Dashboard
- My CV  
- AI Assistant
- Downloads

**Features:**
- Fixed bottom position
- Purple active indicator
- Smooth transitions
- Safe area handling

## Best Practices

### 1. Navigation State Management

```dart
class DashboardController extends StateNotifier<int> {
  DashboardController() : super(0);
  
  void navigateTo(int index) {
    state = index;
    // Handle routing logic
  }
}
```

### 2. Responsive Content Layout

```dart
ModernDashboardContent(
  children: [
    // Content automatically adapts to available space
    WelcomeCard(),
    StatsGrid(),
    RecentActivity(),
  ],
)
```

### 3. Consistent Theming

```dart
// Always use theme constants
Container(
  padding: EdgeInsets.all(ModernSaaSDashboardTheme.spacingXl),
  decoration: BoxDecoration(
    color: ModernSaaSDashboardTheme.surfaceBackground,
    borderRadius: BorderRadius.circular(ModernSaaSDashboardTheme.radiusLg),
  ),
)
```

### 4. Accessibility

```dart
// Sidebar items include proper semantics
Semantics(
  label: 'Dashboard navigation item',
  button: true,
  selected: isSelected,
  child: SidebarItem(...),
)
```

## Integration Examples

### With State Management (Riverpod)

```dart
final navigationProvider = StateNotifierProvider<NavigationController, int>(
  (ref) => NavigationController(),
);

class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    
    return ModernResponsiveDashboardLayout(
      currentIndex: currentIndex,
      onNavigationChanged: (index) {
        ref.read(navigationProvider.notifier).navigateTo(index);
      },
      child: _buildContent(currentIndex),
    );
  }
}
```

### With Go Router

```dart
void _handleNavigation(int index) {
  final routes = [
    '/dashboard',
    '/cv/profile', 
    '/cv/experience',
    '/cv/skills',
    '/cv/projects',
    '/cv/downloads',
    '/ai/assistant',
    '/templates',
    '/settings',
    '/account',
  ];
  
  if (index < routes.length) {
    context.go(routes[index]);
  }
}
```

## Performance Considerations

- **Lazy Loading**: Navigation items are built on-demand
- **Efficient Animations**: Uses AnimatedBuilder for optimal performance
- **Memory Management**: Proper disposal of animation controllers
- **Responsive Images**: Avatar images are cached and optimized

## Customization Options

### Custom Sidebar Items

```dart
// Add custom items to navigation
List<SidebarItemData> _getCustomItems() {
  return [
    SidebarItemData(
      icon: LucideIcons.customIcon,
      label: 'Custom Feature',
      badge: 'BETA',
      badgeColor: Colors.orange,
    ),
  ];
}
```

### Custom Styling

```dart
// Override theme colors
class CustomSaaSTheme extends ModernSaaSDashboardTheme {
  static const Color customAccent = Color(0xFF6366F1); // Indigo
  // Override other properties as needed
}
```

### Custom Premium Card

```dart
Widget _buildCustomPremiumCard() {
  return Container(
    // Custom premium card implementation
    child: Column(
      children: [
        CustomIcon(),
        CustomMessage(),
        CustomButton(),
      ],
    ),
  );
}
```

This sidebar system provides a solid foundation for modern SaaS dashboard applications while remaining flexible and customizable for specific needs.
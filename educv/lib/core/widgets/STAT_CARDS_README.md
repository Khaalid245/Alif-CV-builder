# Dashboard Statistic Cards System

A modern, responsive dashboard statistic cards system for Flutter applications with animations, hover effects, and comprehensive customization options.

## Overview

This system provides beautifully designed statistic cards that adapt seamlessly across different screen sizes while maintaining consistent functionality and modern SaaS aesthetics.

## Features

### 🎨 **Design Features**
- **Modern SaaS Styling**: Clean, minimal design with soft shadows and rounded corners
- **Responsive Design**: Adapts perfectly to mobile, tablet, and desktop screens
- **Hover Animations**: Smooth scale and shadow effects on web platforms
- **Progress Indicators**: Animated progress bars and accent lines
- **Status Indicators**: Color-coded status badges with dot indicators
- **Trend Indicators**: Up/down trend arrows with percentage changes
- **Loading States**: Skeleton loading animations

### 📱 **Responsive Behavior**

#### Mobile (< 768px)
- **2-column grid layout**
- Compact padding and spacing
- Smaller icons and typography
- Touch-friendly interactions

#### Tablet (768-1024px)
- **2 or 3-column layout** (adaptive based on card count)
- Medium-sized elements
- Balanced spacing

#### Desktop (> 1024px)
- **4-column layout**
- Large icons and typography
- Generous spacing and padding
- Hover effects and animations

## Components

### DashboardStatCard

The main statistic card component with comprehensive customization options.

**Properties:**
```dart
DashboardStatCard({
  required String title,           // Card title
  required String value,           // Main statistic value
  required IconData icon,          // Card icon
  required Color color,            // Accent color
  String? subtitle,                // Optional subtitle
  double? progress,                // Progress value (0.0 - 1.0)
  String? statusText,              // Status indicator text
  Color? statusColor,              // Status indicator color
  VoidCallback? onTap,             // Tap handler
  bool showTrend = false,          // Show trend indicator
  double? trendValue,              // Trend percentage
  bool isLoading = false,          // Loading state
})
```

### DashboardStatsGrid

Responsive grid layout for organizing multiple stat cards.

```dart
DashboardStatsGrid({
  required List<DashboardStatCard> cards,  // Cards to display
  EdgeInsets? padding,                     // Grid padding
  double? spacing,                         // Card spacing
})
```

### Specialized Stat Cards

Pre-configured cards for common use cases:

- **ProfileSectionStatCard** - Profile completion tracking
- **ExperienceStatCard** - Work experience count
- **SkillsStatCard** - Skills count with progress
- **ProjectsStatCard** - Projects count with progress

## Usage Examples

### Basic Stat Card

```dart
DashboardStatCard(
  title: 'Total Users',
  value: '1,234',
  icon: LucideIcons.users,
  color: ModernSaaSDashboardTheme.accentPurple,
  subtitle: 'Active users',
  onTap: () => navigateToUsers(),
)
```

### Card with Progress Bar

```dart
DashboardStatCard(
  title: 'Profile Completion',
  value: '85%',
  icon: LucideIcons.user,
  color: ModernSaaSDashboardTheme.success,
  progress: 0.85,
  statusText: 'Almost Complete',
  statusColor: ModernSaaSDashboardTheme.warning,
  showTrend: true,
  trendValue: 12.5,
  onTap: () => navigateToProfile(),
)
```

### Complete Stats Grid

```dart
DashboardStatsGrid(
  cards: [
    ProfileSectionStatCard(
      completedSections: 5,
      totalSections: 7,
      onTap: () => navigateToProfile(),
    ),
    ExperienceStatCard(
      experienceCount: 3,
      onTap: () => navigateToExperience(),
    ),
    SkillsStatCard(
      skillsCount: 12,
      onTap: () => navigateToSkills(),
    ),
    ProjectsStatCard(
      projectsCount: 4,
      onTap: () => navigateToProjects(),
    ),
  ],
)
```

### Custom Stat Card

```dart
DashboardStatCard(
  title: 'Revenue',
  value: '\$45.2K',
  icon: LucideIcons.dollarSign,
  color: ModernSaaSDashboardTheme.success,
  subtitle: 'This month',
  progress: 0.75,
  statusText: 'On Track',
  statusColor: ModernSaaSDashboardTheme.success,
  showTrend: true,
  trendValue: 8.3,
  onTap: () => showRevenueDetails(),
)
```

## Layout Behavior

### Mobile Layout (2 columns)
```
┌─────────────┬─────────────┐
│   Card 1    │   Card 2    │
├─────────────┼─────────────┤
│   Card 3    │   Card 4    │
└─────────────┴─────────────┘
```

### Tablet Layout (2-3 columns)
```
┌─────────┬─────────┬─────────┐
│ Card 1  │ Card 2  │ Card 3  │
├─────────┴─────────┼─────────┤
│     Card 4        │         │
└───────────────────┴─────────┘
```

### Desktop Layout (4 columns)
```
┌──────┬──────┬──────┬──────┐
│Card 1│Card 2│Card 3│Card 4│
└──────┴──────┴──────┴──────┘
```

## Card Anatomy

### Header Section
- **Icon Container**: Colored background with icon
- **Trend Indicator**: Optional up/down arrow with percentage

### Content Section
- **Value**: Large, prominent number/text
- **Title**: Card label
- **Subtitle**: Optional additional context

### Footer Section
- **Progress Bar**: Animated progress indicator (optional)
- **Accent Line**: Gradient line for visual appeal (fallback)
- **Status Indicator**: Colored dot with status text (optional)

## Animation Details

### Hover Effects (Web)
```dart
Duration: 200ms
Curve: Curves.easeOut
Properties: scale (1.0 → 1.02), shadow, border
```

### Progress Animation
```dart
Duration: 1200ms
Curve: Curves.easeOutCubic
Properties: progress bar width
Delay: 300ms after card appears
```

### Loading Skeleton
```dart
Duration: 800ms
Curve: Curves.easeInOut
Properties: opacity shimmer effect
```

## Styling System

### Colors

```dart
// Card backgrounds
ModernSaaSDashboardTheme.surfaceBackground  // #FFFFFF

// Borders
ModernSaaSDashboardTheme.borderLight        // #F1F5F9 (default)
widget.color.withOpacity(0.2)               // Colored (hover)

// Shadows
Colors.black.withOpacity(0.04)              // Default shadow
widget.color.withOpacity(0.08)              // Hover shadow

// Status colors
ModernSaaSDashboardTheme.success            // #059669
ModernSaaSDashboardTheme.warning            // #D97706
ModernSaaSDashboardTheme.error              // #DC2626
```

### Typography

```dart
// Value text
Mobile:  ModernSaaSDashboardTheme.headlineLarge    // 20px
Tablet:  ModernSaaSDashboardTheme.displaySmall     // 24px
Desktop: ModernSaaSDashboardTheme.displayMedium    // 28px

// Title text
Mobile:  ModernSaaSDashboardTheme.bodyMedium       // 14px
Tablet:  ModernSaaSDashboardTheme.bodyLarge        // 16px
Desktop: ModernSaaSDashboardTheme.bodyLarge        // 16px

// Subtitle text
ModernSaaSDashboardTheme.bodySmall                 // 12px

// Status text
ModernSaaSDashboardTheme.labelSmall                // 11px
```

### Spacing & Sizing

```dart
// Card padding
Mobile:  16px
Tablet:  20px
Desktop: 24px

// Icon sizes
Mobile:  40px
Tablet:  44px
Desktop: 48px

// Grid spacing
Mobile:  16px
Tablet:  20px
Desktop: 24px

// Border radius: 16px
// Progress bar height: 4px
// Status indicator dot: 6px
```

## Specialized Cards

### ProfileSectionStatCard

Tracks profile completion progress.

**Features:**
- Automatic progress calculation
- Dynamic status based on completion
- Trend indicator for recent changes

```dart
ProfileSectionStatCard(
  completedSections: 5,
  totalSections: 7,
  onTap: () => navigateToProfile(),
)
```

### ExperienceStatCard

Displays work experience count.

**Features:**
- Simple count display
- Status indicator (Added/Empty)
- Info color theme

```dart
ExperienceStatCard(
  experienceCount: 3,
  onTap: () => navigateToExperience(),
)
```

### SkillsStatCard

Shows skills count with progress tracking.

**Features:**
- Progress bar (target: 15 skills)
- Dynamic status (Excellent/Good/Add More)
- Trend indicator
- Success color theme

```dart
SkillsStatCard(
  skillsCount: 12,
  onTap: () => navigateToSkills(),
)
```

### ProjectsStatCard

Displays project count with progress.

**Features:**
- Progress bar (target: 5 projects)
- Dynamic status (Great/Good/Add Projects)
- Warning color theme

```dart
ProjectsStatCard(
  projectsCount: 4,
  onTap: () => navigateToProjects(),
)
```

## Integration Examples

### With State Management (Riverpod)

```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(cvProfileProvider);
    
    return profile.when(
      loading: () => DashboardStatsGrid(
        cards: List.generate(4, (index) => 
          DashboardStatCard(
            title: '',
            value: '',
            icon: LucideIcons.loader,
            color: Colors.grey,
            isLoading: true,
          ),
        ),
      ),
      data: (profile) => DashboardStatsGrid(
        cards: [
          ProfileSectionStatCard(
            completedSections: _getCompletedSections(profile),
            totalSections: 7,
            onTap: () => context.go('/profile'),
          ),
          // More cards...
        ],
      ),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### With Navigation

```dart
void _handleCardTap(int sectionIndex) {
  final routes = [
    '/profile',
    '/experience', 
    '/skills',
    '/projects',
  ];
  
  if (sectionIndex < routes.length) {
    context.go(routes[sectionIndex]);
  }
}

// Usage
DashboardStatsGrid(
  cards: [
    ProfileSectionStatCard(
      completedSections: 5,
      totalSections: 7,
      onTap: () => _handleCardTap(0),
    ),
    // More cards...
  ],
)
```

### With Analytics

```dart
DashboardStatCard(
  title: 'Profile Views',
  value: '247',
  icon: LucideIcons.eye,
  color: ModernSaaSDashboardTheme.info,
  subtitle: 'This week',
  showTrend: true,
  trendValue: analytics.getProfileViewsTrend(),
  statusText: analytics.getViewsStatus(),
  statusColor: analytics.getViewsStatusColor(),
  onTap: () => analytics.trackCardTap('profile_views'),
)
```

## Best Practices

### 1. Consistent Color Usage
```dart
// Use theme colors for consistency
final cardColor = switch (cardType) {
  CardType.profile => ModernSaaSDashboardTheme.accentPurple,
  CardType.experience => ModernSaaSDashboardTheme.info,
  CardType.skills => ModernSaaSDashboardTheme.success,
  CardType.projects => ModernSaaSDashboardTheme.warning,
};
```

### 2. Meaningful Progress Values
```dart
// Calculate meaningful progress percentages
final skillsProgress = (skillsCount / 15).clamp(0.0, 1.0);
final projectsProgress = (projectsCount / 5).clamp(0.0, 1.0);
```

### 3. Responsive Grid Usage
```dart
// Let the grid handle responsive behavior
DashboardStatsGrid(
  cards: allCards,
  // Grid automatically adapts column count
)
```

### 4. Loading State Handling
```dart
// Show loading cards while data loads
if (isLoading) {
  return DashboardStatsGrid(
    cards: List.generate(expectedCardCount, (index) =>
      DashboardStatCard(
        title: '',
        value: '',
        icon: LucideIcons.loader,
        color: Colors.grey,
        isLoading: true,
      ),
    ),
  );
}
```

### 5. Accessibility
```dart
// Cards include proper semantics
DashboardStatCard(
  title: 'Profile Sections',
  value: '5/7',
  // Automatically includes:
  // - Semantic labels
  // - Button role (when onTap provided)
  // - Value announcements
  onTap: () => navigateToProfile(),
)
```

## Performance Considerations

- **Efficient Animations**: Uses AnimatedBuilder for optimal performance
- **Lazy Loading**: Grid builds cards on-demand
- **Memory Management**: Proper disposal of animation controllers
- **Hover Optimization**: Hover effects only on web platforms

## Customization Options

### Custom Card Themes
```dart
class CustomStatCard extends DashboardStatCard {
  CustomStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) : super(
    title: title,
    value: value,
    icon: icon,
    color: MyCustomTheme.primaryColor,
    // Custom styling...
  );
}
```

### Custom Grid Layouts
```dart
// Override column count
class CustomStatsGrid extends DashboardStatsGrid {
  @override
  int _getColumnCount(DeviceType deviceType) {
    return switch (deviceType) {
      DeviceType.mobile => 1,    // Single column on mobile
      DeviceType.tablet => 2,    // Always 2 columns on tablet
      DeviceType.desktop => 6,   // 6 columns on desktop
    };
  }
}
```

This statistic cards system provides a solid foundation for modern dashboard applications while remaining flexible and customizable for specific needs.
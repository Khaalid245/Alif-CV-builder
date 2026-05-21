import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../router/app_router.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';

class AppHeaderWithNotifications extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showNotificationBadge;

  const AppHeaderWithNotifications({
    super.key,
    required this.title,
    this.actions,
    this.showNotificationBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      actions: [
        if (showNotificationBadge) ...[
          NotificationBadge(
            onTap: () => context.push(AppRoutes.notificationCenter),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.notifications_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Usage Example in CV Dashboard:
/*
class CVDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeaderWithNotifications(
        title: 'CV Dashboard',
        showNotificationBadge: true,
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.account),
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: CVDashboardContent(),
    );
  }
}
*/

// Provider Setup Example:
/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
            NotificationRepositoryImpl(ApiClient()),
          )..loadNotifications()..loadStats(),
        ),
        // ... other providers
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
      ),
    );
  }
}
*/
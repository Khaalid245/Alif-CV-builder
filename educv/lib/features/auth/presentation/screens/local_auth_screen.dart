import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/local_auth_provider.dart';

class LocalAuthScreen extends HookConsumerWidget {
  const LocalAuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localAuthState = ref.watch(localAuthProvider);
    final notifier = ref.read(localAuthProvider.notifier);

    // Auto-trigger on mount
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!localAuthState.isVerified && !localAuthState.isAuthenticating) {
           notifier.authenticate();
        }
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.lock,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'App Locked',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please authenticate to access your CV data',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 48),
            if (localAuthState.error != null) ...[
              Text(
                localAuthState.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton.icon(
              onPressed: localAuthState.isAuthenticating
                  ? null
                  : () => notifier.authenticate(),
              icon: const Icon(LucideIcons.fingerprint),
              label: Text(
                localAuthState.isAuthenticating
                    ? 'Verifying...'
                    : 'Unlock Now',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

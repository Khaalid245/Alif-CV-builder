import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cv_models.dart';
import 'cv_provider.dart';

class LiveCvProfileNotifier extends Notifier<CVProfileModel?> {
  @override
  CVProfileModel? build() {
    // Watch the remote profile. If it changes (e.g. from a save in a bottom sheet), 
    // update the live profile.
    final remoteProfile = ref.watch(cvProfileProvider).valueOrNull;
    return remoteProfile;
  }

  void updateWith({
    String? phone,
    String? city,
    String? country,
    String? linkedin,
    String? github,
    String? portfolio,
    String? summary,
  }) {
    if (state != null) {
      state = state!.copyWith(
        phone: phone,
        city: city,
        country: country,
        linkedin: linkedin,
        github: github,
        portfolio: portfolio,
        summary: summary,
      );
    }
  }
}

final liveCvProfileProvider = NotifierProvider<LiveCvProfileNotifier, CVProfileModel?>(
  () => LiveCvProfileNotifier(),
);

final liveCvTemplateProvider = StateProvider<String>((ref) => 'modern');

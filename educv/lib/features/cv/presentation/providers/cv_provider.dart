import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/cv_repository.dart';
import '../../data/models/cv_models.dart';
import '../../data/repositories/cv_repository_impl.dart';

// Repository provider
final cvRepositoryProvider = Provider<CVRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CVRepositoryImpl(apiClient);
});

// Form step provider
final cvFormStepProvider = StateProvider<int>((ref) => 0);

// Form loading provider
final cvFormLoadingProvider = StateProvider<bool>((ref) => false);

// Form save callback — step 0 (PersonalInfoStep) registers its save fn here.
final cvFormSaveProvider =
    StateProvider<Future<bool> Function()?> ((ref) => null);

// ── CV Profile ────────────────────────────────────────────────────────────────

final cvProfileProvider =
    AsyncNotifierProvider<CVProfileNotifier, CVProfileModel?>(() {
  return CVProfileNotifier();
});

class CVProfileNotifier extends AsyncNotifier<CVProfileModel?> {
  @override
  Future<CVProfileModel?> build() async {
    return fetch();
  }

  Future<CVProfileModel?> fetch() async {
    // No try/catch — let AsyncNotifier set AsyncError on failure
    final repo = ref.read(cvRepositoryProvider);
    final profile = await repo.getProfile();

    // Populate all section providers from the single profile response.
    // This eliminates 6 separate API calls when the CV form opens.
    if (profile != null) {
      ref.read(educationProvider.notifier).setFromProfile(profile.education);
      ref.read(experienceProvider.notifier).setFromProfile(profile.experiences);
      ref.read(skillsProvider.notifier).setFromProfile(profile.skills);
      ref.read(languagesProvider.notifier).setFromProfile(profile.languages);
      ref.read(projectsProvider.notifier).setFromProfile(profile.projects);
      ref.read(certificationsProvider.notifier)
          .setFromProfile(profile.certifications);
    }
    return profile;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    // FIX S3 — do NOT set AsyncLoading, keep old data visible during update
    final previous = state.valueOrNull;
    try {
      final repo = ref.read(cvRepositoryProvider);
      await repo.updateProfile(data);
      final updated = await repo.getProfile();
      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> uploadPhoto(File photo) async {
    final previous = state.valueOrNull;
    try {
      final repo = ref.read(cvRepositoryProvider);
      await repo.uploadPhoto(photo);
      final updated = await repo.getProfile();
      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(e, st);
    }
  }
}

// CV Completion provider — derived from cvProfileProvider
final cvCompletionProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(cvProfileProvider);
  return profileAsync.maybeWhen(
    data: (profile) => profile?.completionPercentage ?? 0,
    orElse: () => 0,
  );
});

// ── Education ─────────────────────────────────────────────────────────────────

final educationProvider =
    AsyncNotifierProvider<EducationNotifier, List<EducationModel>>(() {
  return EducationNotifier();
});

class EducationNotifier extends AsyncNotifier<List<EducationModel>> {
  @override
  Future<List<EducationModel>> build() async {
    return fetch();
  }

  Future<List<EducationModel>> fetch() async {
    final repo = ref.read(cvRepositoryProvider);
    return await repo.getEducation();
  }

  void setFromProfile(List<EducationModel> items) {
    state = AsyncData(items);
  }

  Future<void> add(Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final newItem = await repo.addEducation(data);
    state = AsyncData([...state.valueOrNull ?? [], newItem]);
    ref.invalidate(cvProfileProvider);
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final updated = await repo.updateEducation(id, data);
    state = AsyncData(
      state.valueOrNull?.map((e) => e.id == id ? updated : e).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }

  Future<void> delete(String id) async {
    final repo = ref.read(cvRepositoryProvider);
    await repo.deleteEducation(id);
    state = AsyncData(
      state.valueOrNull?.where((e) => e.id != id).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }
}

// ── Experience ────────────────────────────────────────────────────────────────

final experienceProvider =
    AsyncNotifierProvider<ExperienceNotifier, List<ExperienceModel>>(() {
  return ExperienceNotifier();
});

class ExperienceNotifier extends AsyncNotifier<List<ExperienceModel>> {
  @override
  Future<List<ExperienceModel>> build() async {
    return fetch();
  }

  Future<List<ExperienceModel>> fetch() async {
    final repo = ref.read(cvRepositoryProvider);
    return await repo.getExperience();
  }

  void setFromProfile(List<ExperienceModel> items) {
    state = AsyncData(items);
  }

  Future<void> add(Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final newItem = await repo.addExperience(data);
    state = AsyncData([...state.valueOrNull ?? [], newItem]);
    ref.invalidate(cvProfileProvider);
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final updated = await repo.updateExperience(id, data);
    state = AsyncData(
      state.valueOrNull?.map((e) => e.id == id ? updated : e).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }

  Future<void> delete(String id) async {
    final repo = ref.read(cvRepositoryProvider);
    await repo.deleteExperience(id);
    state = AsyncData(
      state.valueOrNull?.where((e) => e.id != id).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }
}

// ── Skills ────────────────────────────────────────────────────────────────────

final skillsProvider =
    AsyncNotifierProvider<SkillsNotifier, List<SkillModel>>(() {
  return SkillsNotifier();
});

class SkillsNotifier extends AsyncNotifier<List<SkillModel>> {
  @override
  Future<List<SkillModel>> build() async {
    return fetch();
  }

  Future<List<SkillModel>> fetch() async {
    final repo = ref.read(cvRepositoryProvider);
    return await repo.getSkills();
  }

  void setFromProfile(List<SkillModel> items) {
    state = AsyncData(items);
  }

  Future<void> add(Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final newItem = await repo.addSkill(data);
    state = AsyncData([...state.valueOrNull ?? [], newItem]);
    ref.invalidate(cvProfileProvider);
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final updated = await repo.updateSkill(id, data);
    state = AsyncData(
      state.valueOrNull?.map((e) => e.id == id ? updated : e).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }

  Future<void> delete(String id) async {
    final repo = ref.read(cvRepositoryProvider);
    await repo.deleteSkill(id);
    state = AsyncData(
      state.valueOrNull?.where((e) => e.id != id).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }
}

// ── Languages ─────────────────────────────────────────────────────────────────

final languagesProvider =
    AsyncNotifierProvider<LanguagesNotifier, List<LanguageModel>>(() {
  return LanguagesNotifier();
});

class LanguagesNotifier extends AsyncNotifier<List<LanguageModel>> {
  @override
  Future<List<LanguageModel>> build() async {
    return fetch();
  }

  Future<List<LanguageModel>> fetch() async {
    final repo = ref.read(cvRepositoryProvider);
    return await repo.getLanguages();
  }

  void setFromProfile(List<LanguageModel> items) {
    state = AsyncData(items);
  }

  Future<void> add(Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final newItem = await repo.addLanguage(data);
    state = AsyncData([...state.valueOrNull ?? [], newItem]);
    ref.invalidate(cvProfileProvider);
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final updated = await repo.updateLanguage(id, data);
    state = AsyncData(
      state.valueOrNull?.map((e) => e.id == id ? updated : e).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }

  Future<void> delete(String id) async {
    final repo = ref.read(cvRepositoryProvider);
    await repo.deleteLanguage(id);
    state = AsyncData(
      state.valueOrNull?.where((e) => e.id != id).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }
}

// ── Projects ──────────────────────────────────────────────────────────────────

final projectsProvider =
    AsyncNotifierProvider<ProjectsNotifier, List<ProjectModel>>(() {
  return ProjectsNotifier();
});

class ProjectsNotifier extends AsyncNotifier<List<ProjectModel>> {
  @override
  Future<List<ProjectModel>> build() async {
    return fetch();
  }

  Future<List<ProjectModel>> fetch() async {
    final repo = ref.read(cvRepositoryProvider);
    return await repo.getProjects();
  }

  void setFromProfile(List<ProjectModel> items) {
    state = AsyncData(items);
  }

  Future<void> add(Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final newItem = await repo.addProject(data);
    state = AsyncData([...state.valueOrNull ?? [], newItem]);
    ref.invalidate(cvProfileProvider);
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final updated = await repo.updateProject(id, data);
    state = AsyncData(
      state.valueOrNull?.map((e) => e.id == id ? updated : e).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }

  Future<void> delete(String id) async {
    final repo = ref.read(cvRepositoryProvider);
    await repo.deleteProject(id);
    state = AsyncData(
      state.valueOrNull?.where((e) => e.id != id).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }
}

// ── Certifications ────────────────────────────────────────────────────────────

final certificationsProvider =
    AsyncNotifierProvider<CertificationsNotifier, List<CertificationModel>>(
        () {
  return CertificationsNotifier();
});

class CertificationsNotifier extends AsyncNotifier<List<CertificationModel>> {
  @override
  Future<List<CertificationModel>> build() async {
    return fetch();
  }

  Future<List<CertificationModel>> fetch() async {
    final repo = ref.read(cvRepositoryProvider);
    return await repo.getCertifications();
  }

  void setFromProfile(List<CertificationModel> items) {
    state = AsyncData(items);
  }

  Future<void> add(Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final newItem = await repo.addCertification(data);
    state = AsyncData([...state.valueOrNull ?? [], newItem]);
    ref.invalidate(cvProfileProvider);
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    final repo = ref.read(cvRepositoryProvider);
    final updated = await repo.updateCertification(id, data);
    state = AsyncData(
      state.valueOrNull?.map((e) => e.id == id ? updated : e).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }

  Future<void> delete(String id) async {
    final repo = ref.read(cvRepositoryProvider);
    await repo.deleteCertification(id);
    state = AsyncData(
      state.valueOrNull?.where((e) => e.id != id).toList() ?? [],
    );
    ref.invalidate(cvProfileProvider);
  }
}

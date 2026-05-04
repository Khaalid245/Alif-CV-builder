import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/generated_cv_model.dart';
import '../../data/repositories/pdf_repository_impl.dart';
import '../../domain/pdf_repository.dart';

// Repository provider
final pdfRepositoryProvider = Provider<PDFRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PDFRepositoryImpl(apiClient);
});

// Generate CVs provider
final generateCVsProvider = AsyncNotifierProvider<GenerateCVsNotifier, GenerateResponse?>(() {
  return GenerateCVsNotifier();
});

class GenerateCVsNotifier extends AsyncNotifier<GenerateResponse?> {
  @override
  Future<GenerateResponse?> build() async {
    return null;
  }

  Future<void> generate() async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(pdfRepositoryProvider);
      final response = await repository.generateCVs();
      state = AsyncData(response);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}

// PDF history provider
final pdfHistoryProvider = AsyncNotifierProvider<PDFHistoryNotifier, List<GeneratedCVModel>>(() {
  return PDFHistoryNotifier();
});

class PDFHistoryNotifier extends AsyncNotifier<List<GeneratedCVModel>> {
  @override
  Future<List<GeneratedCVModel>> build() async {
    return [];
  }

  Future<void> fetch() async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(pdfRepositoryProvider);
      final history = await repository.getHistory();
      state = AsyncData(history);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

// Download state enum
enum DownloadStatus { idle, loading, success, error }

// Download state provider
final downloadStateProvider = StateNotifierProvider<DownloadStateNotifier, Map<String, DownloadStatus>>((ref) {
  return DownloadStateNotifier();
});

class DownloadStateNotifier extends StateNotifier<Map<String, DownloadStatus>> {
  DownloadStateNotifier() : super({});

  void startDownload(String templateName) {
    state = {...state, templateName: DownloadStatus.loading};
  }

  void downloadSuccess(String templateName) {
    state = {...state, templateName: DownloadStatus.success};
  }

  void downloadError(String templateName) {
    state = {...state, templateName: DownloadStatus.error};
  }

  void resetDownload(String templateName) {
    state = {...state, templateName: DownloadStatus.idle};
  }
}

// PDF preview provider
final pdfPreviewProvider = StateNotifierProvider<PDFPreviewNotifier, Uint8List?>((ref) {
  return PDFPreviewNotifier(ref);
});

class PDFPreviewNotifier extends StateNotifier<Uint8List?> {
  final Ref ref;

  PDFPreviewNotifier(this.ref) : super(null);

  Future<void> loadPDF(String generatedCvId) async {
    try {
      final repository = ref.read(pdfRepositoryProvider);
      final pdfBytes = await repository.downloadPDF(generatedCvId);
      state = pdfBytes;
    } catch (error) {
      state = null;
      rethrow;
    }
  }

  void clear() {
    state = null;
  }
}
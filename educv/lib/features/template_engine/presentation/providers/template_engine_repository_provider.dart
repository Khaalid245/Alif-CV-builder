import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_client_provider.dart';
import '../../data/repositories/template_engine_repository_impl.dart';
import '../../domain/repositories/template_engine_repository.dart';

final templateEngineRepositoryProvider = Provider<TemplateEngineRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TemplateEngineRepositoryImpl(apiClient);
});
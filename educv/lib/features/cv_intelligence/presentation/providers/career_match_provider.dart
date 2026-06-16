import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/career_match_models.dart';
import '../../data/repositories/career_match/career_match_repository.dart';

class CareerMatchState {
  final bool isLoading;
  final CareerMatchResult? result;
  final String? error;

  CareerMatchState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  CareerMatchState copyWith({
    bool? isLoading,
    CareerMatchResult? result,
    String? error,
  }) {
    return CareerMatchState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}

class CareerMatchNotifier extends StateNotifier<CareerMatchState> {
  final CareerMatchRepository _repository;

  CareerMatchNotifier(this._repository) : super(CareerMatchState());

  Future<void> analyzeMatch(String cvId, String jobDescription) async {
    if (jobDescription.trim().isEmpty) {
      state = state.copyWith(error: "Job description cannot be empty");
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.analyzeMatch(cvId, jobDescription);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = CareerMatchState();
  }
}

final careerMatchProvider = StateNotifierProvider<CareerMatchNotifier, CareerMatchState>((ref) {
  final repository = ref.watch(careerMatchRepositoryProvider);
  return CareerMatchNotifier(repository);
});

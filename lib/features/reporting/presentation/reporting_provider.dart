import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/price_report_model.dart';
import '../data/reporting_repository.dart';

final reportingRepositoryProvider = Provider<ReportingRepository>((ref) {
  return ReportingRepository();
});

class ReportingState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const ReportingState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  ReportingState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return ReportingState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

class ReportingNotifier extends StateNotifier<ReportingState> {
  final ReportingRepository _repository;

  ReportingNotifier(this._repository) : super(const ReportingState());

  Future<bool> submitPriceReport({
    required String itemId,
    required String marketId,
    required double totalPrice,
    required double quantity,
    required String unit,
    required double pricePerStandardUnit,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    try {
      final deviceId = await _repository.getOrCreateDeviceId();
      final report = PriceReportModel(
        itemId: itemId,
        marketId: marketId,
        deviceId: deviceId,
        price: totalPrice,
        quantity: quantity,
        reportedUnit: unit,
        pricePerStandardUnit: pricePerStandardUnit,
        notes: notes,
        reportedAt: DateTime.now(),
      );

      final success = await _repository.submitReport(report);
      if (success) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to submit report. Saved locally.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() {
    state = const ReportingState();
  }
}

final reportingProvider = StateNotifierProvider<ReportingNotifier, ReportingState>((ref) {
  final repo = ref.watch(reportingRepositoryProvider);
  return ReportingNotifier(repo);
});

import 'package:shared/services/review_service.dart';

/// Fake implementation of [ReviewService] for testing and previews.
class FakeReviewService implements ReviewService {
  int successfulCalculations = 0;
  int appOpenCount = 0;
  bool shouldPrompt = false;

  @override
  Future<void> recordFirstLaunchIfNeeded() async {}

  @override
  Future<void> incrementAppOpenCount() async {
    appOpenCount++;
  }

  @override
  Future<void> incrementSuccessfulCalculations() async {
    successfulCalculations++;
  }

  @override
  Future<void> recordReviewPromptShown() async {}

  @override
  Future<bool> shouldRequestReview() async => shouldPrompt;
}

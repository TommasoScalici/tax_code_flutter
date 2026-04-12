import 'package:in_app_review/in_app_review.dart';
import 'package:logger/logger.dart';
import 'package:shared/services/review_service.dart';

/// A mobile-only service that wraps [InAppReview] and coordinates
/// with [ReviewService] to decide when to show the native review
/// dialog.
///
/// This service should be called after positive user moments
/// (e.g. successful tax code calculation, barcode view).
class InAppReviewService {
  final InAppReview _inAppReview;
  final ReviewService _reviewService;
  final Logger _logger;

  InAppReviewService({
    required ReviewService reviewService,
    required Logger logger,
    InAppReview? inAppReview,
  }) : _reviewService = reviewService,
       _logger = logger,
       _inAppReview = inAppReview ?? InAppReview.instance;

  /// Checks whether the review prompt should be shown and, if so,
  /// requests the native in-app review dialog.
  ///
  /// This method is safe to call frequently — it will only trigger
  /// the dialog when all conditions are met and the platform supports it.
  Future<void> maybeRequestReview() async {
    try {
      final shouldRequest = await _reviewService.shouldRequestReview();
      if (!shouldRequest) return;

      final isAvailable = await _inAppReview.isAvailable();
      if (!isAvailable) {
        _logger.d('In-app review not available on this device.');
        return;
      }

      _logger.i('Requesting in-app review.');
      await _inAppReview.requestReview();
      await _reviewService.recordReviewPromptShown();
    } catch (e, s) {
      // Never let a review prompt failure crash the app.
      _logger.w('Failed to request in-app review', error: e, stackTrace: s);
    }
  }

  /// Opens the app's Play Store listing page directly.
  /// Used for the permanent "Rate this app" button.
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing();
    } catch (e, s) {
      _logger.w('Failed to open store listing', error: e, stackTrace: s);
    }
  }
}

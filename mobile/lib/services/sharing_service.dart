import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';

abstract class SharingServiceAbstract {
  Future<ShareResult> share({required String text});
}

class SharingService implements SharingServiceAbstract {
  final Logger _logger;

  SharingService({required Logger logger}) : _logger = logger;
  
  @override
  Future<ShareResult> share({required String text}) async {
    try {
      return await SharePlus.instance.share(ShareParams(text: text));
    } catch (e, s) {
      _logger.e('Failed to share content', error: e, stackTrace: s);
      return ShareResult.unavailable;
    }
  }
}
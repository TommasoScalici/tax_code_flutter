import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';

abstract class ShareAdapter {
  Future<ShareResult> share({required String text});
}

class AppShareAdapter implements ShareAdapter {
  @override
  Future<ShareResult> share({required String text}) {
    return SharePlus.instance.share(ShareParams(text: text));
  }
}

abstract class SharingServiceAbstract {
  Future<ShareResult> share({required String text});
}

class SharingService implements SharingServiceAbstract {
  final Logger _logger;
  final ShareAdapter _shareAdapter;

  SharingService({
    required Logger logger,
    required ShareAdapter shareAdapter, // <-- INIETTATA QUI
  }) : _logger = logger,
       _shareAdapter = shareAdapter;

  @override
  Future<ShareResult> share({required String text}) async {
    try {
      return await _shareAdapter.share(text: text);
    } catch (e, s) {
      _logger.e('Failed to share content', error: e, stackTrace: s);
      return ShareResult.unavailable;
    }
  }
}

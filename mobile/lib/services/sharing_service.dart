import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';

abstract class ShareAdapter {
  Future<ShareResult> share({required String text});
  Future<ShareResult> shareFile({
    required String filePath,
    required String mimeType,
    String? subject,
  });
}

class AppShareAdapter implements ShareAdapter {
  @override
  Future<ShareResult> share({required String text}) {
    return SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Future<ShareResult> shareFile({
    required String filePath,
    required String mimeType,
    String? subject,
  }) {
    return SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath, mimeType: mimeType)],
        subject: subject,
      ),
    );
  }
}

abstract interface class SharingService {
  Future<ShareResult> share({required String text});
  Future<ShareResult> shareFile({
    required String filePath,
    required String mimeType,
    String? subject,
  });

  factory SharingService({
    required Logger logger,
    required ShareAdapter shareAdapter,
  }) = DefaultSharingService;
}

typedef SharingServiceAbstract = SharingService;

class DefaultSharingService implements SharingService {
  final Logger _logger;
  final ShareAdapter _shareAdapter;

  DefaultSharingService({
    required Logger logger,
    required ShareAdapter shareAdapter,
  }) : _logger = logger,
       _shareAdapter = shareAdapter;

  @override
  Future<ShareResult> share({required String text}) async {
    try {
      return await _shareAdapter.share(text: text);
    } on Object catch (e, s) {
      _logger.e('Failed to share content', error: e, stackTrace: s);
      return ShareResult.unavailable;
    }
  }

  @override
  Future<ShareResult> shareFile({
    required String filePath,
    required String mimeType,
    String? subject,
  }) async {
    try {
      return await _shareAdapter.shareFile(
        filePath: filePath,
        mimeType: mimeType,
        subject: subject,
      );
    } on Object catch (e, s) {
      _logger.e('Failed to share file', error: e, stackTrace: s);
      return ShareResult.unavailable;
    }
  }
}

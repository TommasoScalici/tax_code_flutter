import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';
import 'package:logger/logger.dart';

abstract class GoogleVisionServiceAbstract {
  Future<String?> getTextFromImage(String base64Image);
}

class GoogleVisionService implements GoogleVisionServiceAbstract {
  final FirebaseRemoteConfig _remoteConfig;
  final Logger _logger;
  vision.VisionApi? _visionApi;

  GoogleVisionService({required FirebaseRemoteConfig remoteConfig, required Logger logger})
      : _remoteConfig = remoteConfig,
        _logger = logger;

  Future<vision.VisionApi> _getVisionApi() async {
    if (_visionApi != null) return _visionApi!;

    final jsonString = _remoteConfig.getString('tax_code_flutter_vision');
    if (jsonString.isEmpty) {
      _logger.w('Remote config for Vision API credentials is empty.');
      throw Exception('Vision API credentials not configured.');
    }

    final credentials = ServiceAccountCredentials.fromJson(jsonString);
    final authClient = await clientViaServiceAccount(credentials, [vision.VisionApi.cloudVisionScope]);
    return _visionApi = vision.VisionApi(authClient);
  }

  @override
  Future<String?> getTextFromImage(String base64Image) async {
    try {
      final visionApi = await _getVisionApi();
      final feature = vision.Feature(type: 'TEXT_DETECTION');
      final image = vision.Image(content: base64Image);
      final request = vision.AnnotateImageRequest(image: image, features: [feature]);
      final batchRequest = vision.BatchAnnotateImagesRequest(requests: [request]);

      final response = await visionApi.images.annotate(batchRequest);

      if (response.responses == null || response.responses!.isEmpty) {
        _logger.w('Vision API returned no responses.');
        return null;
      }
      return response.responses![0].fullTextAnnotation?.text;
    } catch (e, s) {
      _logger.e('Error during Google Vision API call', error: e, stackTrace: s);
      return null;
    }
  }
}
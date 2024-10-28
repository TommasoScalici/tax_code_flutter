import 'dart:io';

import 'package:app_device_integrity/app_device_integrity.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tax_code_flutter/settings.dart';
import 'package:uuid/uuid.dart';

class IntegrityService {
  static Future<void> checkIntegrity(BuildContext context) async {
    final logger = Logger();
    final remoteConfig = FirebaseRemoteConfig.instance;
    final sessionId = Uuid().v4();
    final gcpProjectId = remoteConfig.getInt(Settings.projectIdNumber);
    final appAttestationPlugin = AppDeviceIntegrity();

    try {
      if (Platform.isAndroid) {
        await appAttestationPlugin.getAttestationServiceSupport(
          challengeString: sessionId,
          gcp: gcpProjectId,
        );
      } else {
        await appAttestationPlugin.getAttestationServiceSupport(
          challengeString: sessionId,
        );
      }
    } catch (e) {
      logger.e('Error during integrity check: $e');
    }
  }
}

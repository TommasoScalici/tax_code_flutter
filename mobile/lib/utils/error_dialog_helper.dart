import 'package:material_ui/material_ui.dart';
import 'package:shared/utils/error_mapper.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/utils/app_failure_l10n.dart';

class ErrorDialogHelper {
  /// Displays a localized error dialog for an [AppFailure], semantic error key [String], or exception [Object].
  static void showErrorDialog(BuildContext context, Object errorOrFailure) {
    final l10n = context.l10n;
    final AppFailure failure;
    if (errorOrFailure is AppFailure) {
      failure = errorOrFailure;
    } else if (errorOrFailure is String) {
      failure = ErrorMapper.fromKey(errorOrFailure);
    } else {
      failure = ErrorMapper.fromException(errorOrFailure);
    }

    final message = failure.toLocalizedMessage(l10n);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.error),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }
}


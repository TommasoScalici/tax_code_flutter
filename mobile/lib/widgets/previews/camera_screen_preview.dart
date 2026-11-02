import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/controllers/camera_page_controller.dart';
import 'package:tax_code_flutter/screens/camera_page.dart';
import 'package:tax_code_flutter/widgets/previews/preview_fakes.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Standalone interactive preview for [CameraPage] UI and ID-1 scanner overlay,
/// using the production widget with [FakeCameraPageController].
class CameraScreenPreview extends StatefulWidget {
  @Preview(name: 'Camera & ID-1 Scanner Screen')
  const CameraScreenPreview({super.key});

  @override
  State<CameraScreenPreview> createState() => _CameraScreenPreviewState();
}

class _CameraScreenPreviewState extends State<CameraScreenPreview> {
  late final FakeCameraPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FakeCameraPageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      maxWidth: 412,
      maxHeight: 892,
      expandChild: true,
      padding: EdgeInsets.zero,
      toolbarActions: (context, _) {
        return [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceChip(
                  label: const Text('Scanner Feed'),
                  selected:
                      _controller.status == CameraStatus.readyToScan ||
                      _controller.status == CameraStatus.pictureTaken,
                  onSelected: (val) {
                    if (val) {
                      _controller.setStatus(CameraStatus.readyToScan);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Permission Denied'),
                  selected: _controller.status == CameraStatus.permissionDenied,
                  onSelected: (val) {
                    if (val) {
                      _controller.setStatus(CameraStatus.permissionDenied);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Error'),
                  selected: _controller.status == CameraStatus.error,
                  onSelected: (val) {
                    if (val) {
                      _controller.setStatus(CameraStatus.error);
                    }
                  },
                ),
              ],
            ),
          ),
        ];
      },
      child: CameraPage(controller: _controller),
    );
  }
}

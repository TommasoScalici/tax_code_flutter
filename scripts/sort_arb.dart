// Compatibility wrapper around tool/arb_tool.dart.
// ignore_for_file: avoid_print

import 'dart:io';

import '../tool/arb_tool.dart';

void main(List<String> args) {
  print(
    '[DEPRECATED] scripts/sort_arb.dart is deprecated. Please use `dart run tool/arb_tool.dart sort`.',
  );
  final arbTool = ArbTool();
  final exitCode = arbTool.run(['sort', ...args]);
  exit(exitCode);
}

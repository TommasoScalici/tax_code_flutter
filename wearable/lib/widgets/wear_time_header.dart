import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';

/// A lightweight, live clock header adhering to Wear OS design standards.
///
/// Displays the current time at the top of the watch display and ticks
/// every minute while active, consuming minimal CPU and battery.
class WearTimeHeader extends StatefulWidget {
  const WearTimeHeader({super.key});

  @override
  State<WearTimeHeader> createState() => _WearTimeHeaderState();
}

class _WearTimeHeaderState extends State<WearTimeHeader> {
  Timer? _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _scheduleNextMinuteTick();
  }

  void _scheduleNextMinuteTick() {
    _timer?.cancel();
    final now = DateTime.now();
    final msUntilNextMinute = (60 - now.second) * 1000 - now.millisecond;
    _timer = Timer(
      Duration(milliseconds: msUntilNextMinute > 0 ? msUntilNextMinute : 1000),
      () {
        if (!mounted) return;
        setState(() {
          _currentTime = DateTime.now();
        });
        _startPeriodicTimer();
      },
    );
  }

  void _startPeriodicTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
    final formattedTime = use24h
        ? DateFormat('HH:mm').format(_currentTime)
        : DateFormat('h:mm a').format(_currentTime);

    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
      child: Center(
        child: Text(
          formattedTime,
          style: WearTypography.clockHeader(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

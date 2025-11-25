import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kronos/flutter_kronos.dart';

void main() {
  runApp(
    MaterialApp(home: Home()),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int? _currentTimeMs;
  int? _currentNtpTimeMs;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Initialize the platform state and fetch initial times.
  Future<void> initPlatformState() async {
    // Start NTP synchronization in the background.
    FlutterKronos.sync();
    await _fetchTimes();

    if (!mounted) return;
    setState(() {});
  }

  // Refresh the displayed times.
  Future<void> _refreshTime() async {
    await _fetchTimes();
    setState(() {});
  }

  // Fetch the current times from the plugin.
  Future<void> _fetchTimes() async {
    try {
      final result = await Future.wait([
        FlutterKronos.getCurrentTimeMs,
        FlutterKronos.getCurrentNtpTimeMs,
      ]);
      _currentTimeMs = result[0];
      _currentNtpTimeMs = result[1];
    } on PlatformException {
      // Handle any platform exceptions.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Kronos Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Time (ms): $_currentTimeMs'),
            Text('Current Time (formatted): ${_currentTimeMs.stringify}'),
            SizedBox(height: 16),
            Text('NTP Time (ms): $_currentNtpTimeMs'),
            Text('NTP Time (formatted): ${_currentNtpTimeMs.stringify}'),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _refreshTime,
                  child: Text('Refresh'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentTimeMs = null;
                      _currentNtpTimeMs = null;
                    });
                  },
                  child: Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension TimeConvert on int? {
  String get stringify => this == null || this! <= 0
      ? 'Not available'
      : DateTime.fromMillisecondsSinceEpoch(this!).toString();
}

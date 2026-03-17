import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const DotTimeApp());
}

class DotTimeApp extends StatelessWidget {
  const DotTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot Time',
      theme: ThemeData.dark(),
      home: const DotScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DotScreen extends StatefulWidget {
  const DotScreen({super.key});

  @override
  State<DotScreen> createState() => _DotScreenState();
}

class _DotScreenState extends State<DotScreen> {
  String _mode = 'Day';
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(
        'https://api.github.com/repos/ZaidKhan1812/dot-time-app/releases/latest',
      ));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion =
            data['tag_name'].toString().replaceAll('v', '');
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        if (latestVersion != currentVersion) {
          final downloadUrl =
              data['assets'][0]['browser_download_url'] as String;
          _showUpdateDialog(downloadUrl);
        }
      }
    } catch (e) {
      // Silently fail if no internet
    }
  }

  void _showUpdateDialog(String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '🔥 Update Available!',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'A new version of Dot Time is available. Update now for the latest features!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Later',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            onPressed: () async {
              final uri = Uri.parse(downloadUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            child: const Text(
              'Update Now 🚀',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  double _getProgress() {
    if (_mode == 'Day') {
      int minutesNow = _now.hour * 60 + _now.minute;
      return minutesNow / 1440;
    } else if (_mode == 'Month') {
      int daysInMonth =
          DateUtils.getDaysInMonth(_now.year, _now.month);
      return _now.day / daysInMonth;
    } else {
      int dayOfYear = DateTime(_now.year, _now.month, _now.day)
              .difference(DateTime(_now.year, 1, 1))
              .inDays +
          1;
      int daysInYear = DateTime(_now.year + 1, 1, 1)
          .difference(DateTime(_now.year, 1, 1))
          .inDays;
      return dayOfYear / daysInYear;
    }
  }

  @override
  Widget build(BuildContext context) {
    const int totalDots = 400;
    double progress = _getProgress();
    int filledDots = (progress * totalDots).round();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toStringAsFixed(1)}% of $_mode gone',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 20,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: totalDots,
                  itemBuilder: (context, index) {
                    bool isFilled = index < filledDots;
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled
                            ? Colors.white
                            : Colors.white.withOpacity(0.12),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['Day', 'Month', 'Year'].map((mode) {
                  bool isSelected = _mode == mode;
                  return GestureDetector(
                    onTap: () => setState(() => _mode = mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin:
                          const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        mode,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
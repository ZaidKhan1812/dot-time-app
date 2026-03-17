import 'dart:async';
import 'package:flutter/material.dart';

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
  String _mode = 'Day'; // Day, Month, or Year
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Refresh every 60 seconds
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Calculate how many dots to fill
  double _getProgress() {
    if (_mode == 'Day') {
      int minutesNow = _now.hour * 60 + _now.minute;
      return minutesNow / 1440;
    } else if (_mode == 'Month') {
      int daysInMonth = DateUtils.getDaysInMonth(_now.year, _now.month);
      return _now.day / daysInMonth;
    } else {
      int dayOfYear = int.parse(
        DateTime(_now.year, _now.month, _now.day)
          .difference(DateTime(_now.year, 1, 1))
          .inDays.toString()
      ) + 1;
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

              // Time display
              Text(
                '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Progress percentage
              Text(
                '${(progress * 100).toStringAsFixed(1)}% of $_mode gone',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),

              const SizedBox(height: 30),

              // Dot Grid
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

              // Mode Toggle Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['Day', 'Month', 'Year'].map((mode) {
                  bool isSelected = _mode == mode;
                  return GestureDetector(
                    onTap: () => setState(() => _mode = mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        mode,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
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
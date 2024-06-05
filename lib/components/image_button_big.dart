import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Handy Multi-purpose Big Image Button


class WidgetButtonBig extends StatefulWidget {
  Widget widget;
  Color color;
  Function function;
  bool enabled;
  bool isLong;
  bool outLined;
  bool timed;
  WidgetButtonBig({
    super.key,
    required this.widget,
    required this.color,
    required this.function,
    required this.enabled,
    this.isLong = true,
    this.outLined = false,
    this.timed = false
  });

  @override
  State<WidgetButtonBig> createState() => _WidgetButtonBigState();
}

class _WidgetButtonBigState extends State<WidgetButtonBig> {
  bool _isCooldown = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;


  @override
  void dispose() {
    _cooldownTimer?.cancel();

    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_cooldownSeconds > 0) {
          _cooldownSeconds--;
        } else {
          _isCooldown = false;
          timer.cancel();
        }
      });
    });
  }

  void _handleTap() {
    if (!_isCooldown) {
      widget.function();
      setState(() {
        _isCooldown = true;
        _cooldownSeconds = 60; // Reset cooldown time to 60 seconds
      });
      _startCooldownTimer();
    }
  }

  Widget get _buttonText {
    if (_isCooldown) {
      return Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 20,
              startDegreeOffset: 180,
              sections: [
                PieChartSectionData(
                  color: Colors.white,
                  value: 60 - _cooldownSeconds.toDouble(),
                  showTitle: false,
                  radius: 5
                ),
                PieChartSectionData(
                  color: Colors.transparent,
                  value: _cooldownSeconds.toDouble(),
                  showTitle: false,
                  radius: 5
                ),
              ],
            ),
          ),
          Center(child: Text('$_cooldownSeconds', style: const TextStyle(fontSize: 20))),
        ],
      );
    } else {
      return widget.widget;
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.enabled && !widget.isLong
        ? widget.function()
        : null,
      onLongPress: () => widget.enabled && widget.isLong
        ? widget.timed
          ? _handleTap()
          : widget.function()
        : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
            color: !widget.outLined
              ? widget.enabled && !_isCooldown
                ? widget.color
                : widget.color.withOpacity(0.2)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              width: 2,
              color: widget.outLined
                ? widget.enabled
                  ? widget.color
                  : widget.color.withOpacity(0.2)
                : Colors.transparent,
        )
        ),
        width: 73,
        height: 73,
        child: Opacity(
          opacity: widget.enabled && !_isCooldown? 1:0.2,
          child: _buttonText),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:aditya_birla/Constant/const_colors.dart';

extension Extension on Widget {
  Widget toProgress(RxBool isLoading, {double? h, double? w}) {
    // Use a StatefulBuilder instead of GetBuilder to avoid scheduling issues
    return StatefulBuilder(
      builder: (context, setState) {
        // Set up the listener only once per widget instance
        return _LoadingWrapper(
          isLoading: isLoading,
          height: h,
          width: w,
          child: this,
        );
      },
    );
  }
}

// Separate stateful widget to handle the loading state
class _LoadingWrapper extends StatefulWidget {
  final RxBool isLoading;
  final Widget child;
  final double? height;
  final double? width;

  const _LoadingWrapper({
    required this.isLoading,
    required this.child,
    this.height,
    this.width,
  });

  @override
  State<_LoadingWrapper> createState() => _LoadingWrapperState();
}

class _LoadingWrapperState extends State<_LoadingWrapper> {
  late bool _isLoading;
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading.value;

    // Setup listener with proper cleanup
    _worker = ever(widget.isLoading, (val) {
      if (mounted) {
        // Only update state if widget is still mounted
        setState(() {
          _isLoading = val as bool;
        });
      }
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? Center(
              child: SizedBox(
                height: widget.height ?? 25,
                width: widget.width ?? 25,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballRotateChase,
                  colors: [ConstColors.green],
                  strokeWidth: 2,
                ),
              ),
            )
          : widget.child,
    );
  }
}

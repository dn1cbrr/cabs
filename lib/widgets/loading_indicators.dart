import 'package:flutter/material.dart';

class LoadingIndicators {
  static Widget getCircularProgressIndicator({
    Color color = Colors.blue,
    double size = 40,
    double strokeWidth = 4,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: strokeWidth,
      ),
    );
  }

  static Widget getLinearProgressIndicator({
    Color color = Colors.blue,
    double height = 4,
  }) {
    return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(color),
      minHeight: height,
    );
  }

  static Widget getShimmerLoading({
    double width = double.infinity,
    double height = 50,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }

  static Widget getLoadingOverlay({
    required bool isLoading,
    required Widget child,
    String? loadingText,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getCircularProgressIndicator(),
                  if (loadingText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      loadingText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class LoadingDialog {
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              LoadingIndicators.getCircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message ?? 'Loading...'),
            ],
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

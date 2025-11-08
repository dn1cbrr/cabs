import 'package:flutter/material.dart';

class KeyboardFocusWrapper extends StatefulWidget {
  final Widget child;
  final bool autofocus;

  const KeyboardFocusWrapper({
    super.key,
    required this.child,
    this.autofocus = true,
  });

  @override
  State<KeyboardFocusWrapper> createState() => _KeyboardFocusWrapperState();
}

class _KeyboardFocusWrapperState extends State<KeyboardFocusWrapper> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: widget.child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Material Design 3 enhanced form fields with proper state management and styling

class Material3TextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool filled;
  final Color? fillColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final String? helperText;
  final String? errorText;

  const Material3TextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.filled = true,
    this.fillColor,
    this.borderRadius = 12.0,
    this.contentPadding,
    this.helperText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: filled,
        fillColor:
            fillColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.3),
        helperText: helperText,
        errorText: errorText,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
      ),
    );
  }
}

class Material3DropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final String label;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final double borderRadius;
  final Color? fillColor;
  final Widget? prefixIcon;
  final String? hintText;

  const Material3DropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.label,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.borderRadius = 12.0,
    this.fillColor,
    this.prefixIcon,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<T>(
      value: value,
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor:
            fillColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}

class Material3DatePickerField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime)? onDateSelected;
  final String? Function(String?)? validator;
  final bool enabled;
  final double borderRadius;
  final Color? fillColor;
  final Widget? prefixIcon;

  const Material3DatePickerField({
    super.key,
    this.controller,
    required this.label,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.validator,
    this.enabled = true,
    this.borderRadius = 12.0,
    this.fillColor,
    this.prefixIcon,
  });

  @override
  State<Material3DatePickerField> createState() =>
      _Material3DatePickerFieldState();
}

class _Material3DatePickerFieldState extends State<Material3DatePickerField> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _selectedDate = widget.initialDate;
    if (_selectedDate != null) {
      _controller.text = DateFormat('MMM dd, yyyy').format(_selectedDate!);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!widget.enabled) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime.now(),
      lastDate:
          widget.lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = DateFormat('MMM dd, yyyy').format(picked);
      });
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: widget.validator,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.prefixIcon ?? const Icon(Icons.calendar_today),
        filled: true,
        fillColor:
            widget.fillColor ??
            theme.colorScheme.surfaceVariant.withOpacity(0.3),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}

class Material3PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final double borderRadius;
  final Color? fillColor;
  final Widget? prefixIcon;

  const Material3PasswordField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.borderRadius = 12.0,
    this.fillColor,
    this.prefixIcon,
  });

  @override
  State<Material3PasswordField> createState() => _Material3PasswordFieldState();
}

class _Material3PasswordFieldState extends State<Material3PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material3TextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      borderRadius: widget.borderRadius,
      fillColor: widget.fillColor,
      prefixIcon: widget.prefixIcon ?? const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}

class Material3SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function()? onClear;
  final bool enabled;
  final double borderRadius;
  final Color? fillColor;
  final Widget? prefixIcon;

  const Material3SearchField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.enabled = true,
    this.borderRadius = 12.0,
    this.fillColor,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Material3TextField(
      controller: controller,
      label: label,
      hintText: hintText,
      onChanged: onChanged,
      enabled: enabled,
      borderRadius: borderRadius,
      fillColor: fillColor,
      prefixIcon: prefixIcon ?? const Icon(Icons.search),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
    );
  }
}

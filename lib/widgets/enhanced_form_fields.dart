import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/enhanced_validators.dart';

/// Enhanced text field with real-time validation feedback
class EnhancedTextField extends StatefulWidget {
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
  final double borderRadius;
  final Color? fillColor;
  final String? helperText;
  final FieldValidationController? validationController;
  final FocusNode? focusNode;
  final void Function(String?)? onSubmitted;
  final bool showValidationIcon;
  final Color? errorColor;
  final Color? successColor;

  const EnhancedTextField({
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
    this.borderRadius = 12.0,
    this.fillColor,
    this.helperText,
    this.validationController,
    this.focusNode,
    this.onSubmitted,
    this.showValidationIcon = true,
    this.errorColor,
    this.successColor,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField> {
  late FieldValidationController _validationController;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _validationController = widget.validationController ?? FieldValidationController();
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.validationController == null) {
      _validationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = widget.errorColor ?? theme.colorScheme.error;
    final successColor = widget.successColor ?? Colors.green;

    return ListenableBuilder(
      listenable: _validationController,
      builder: (context, _) {
        final state = _validationController.state;
        final hasError = state.error != null;
        final isValid = state.isValid && !hasError && widget.controller?.text.isNotEmpty == true;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: hasError ? errorColor : null,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              obscureText: _obscureText,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              onChanged: (value) {
                if (widget.validator != null) {
                  final error = widget.validator!(value);
                  _validationController.updateValidation(error);
                }
                widget.onChanged?.call(value);
              },
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                hintText: widget.hintText,
                filled: true,
                fillColor: widget.fillColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.3),
                prefixIcon: widget.prefixIcon,
                suffixIcon: _buildSuffixIcon(isValid, hasError, successColor, errorColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: hasError ? errorColor : theme.colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: hasError ? errorColor : theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(color: errorColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                errorText: state.error,
                helperText: state.helperText ?? widget.helperText,
                helperStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                errorStyle: theme.textTheme.bodySmall?.copyWith(
                  color: errorColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _buildSuffixIcon(bool isValid, bool hasError, Color successColor, Color errorColor) {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (!widget.showValidationIcon) return widget.suffixIcon;

    if (hasError) {
      return Icon(Icons.error_outline, color: errorColor, size: 20);
    }

    if (isValid && widget.controller?.text.isNotEmpty == true) {
      return Icon(Icons.check_circle_outline, color: successColor, size: 20);
    }

    return widget.suffixIcon;
  }
}

/// Enhanced dropdown field with validation
class EnhancedDropdownField<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String label;
  final String? hintText;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final double borderRadius;
  final Color? fillColor;
  final FieldValidationController? validationController;

  const EnhancedDropdownField({
    super.key,
    this.value,
    required this.items,
    required this.label,
    this.hintText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.borderRadius = 12.0,
    this.fillColor,
    this.validationController,
  });

  @override
  State<EnhancedDropdownField<T>> createState() => _EnhancedDropdownFieldState<T>();
}

class _EnhancedDropdownFieldState<T> extends State<EnhancedDropdownField<T>> {
  late FieldValidationController _validationController;

  @override
  void initState() {
    super.initState();
    _validationController = widget.validationController ?? FieldValidationController();
  }

  @override
  void dispose() {
    if (widget.validationController == null) {
      _validationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListenableBuilder(
      listenable: _validationController,
      builder: (context, _) {
        final state = _validationController.state;
        final hasError = state.error != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: hasError ? theme.colorScheme.error : null,
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<T>(
              value: widget.value,
              items: widget.items,
              onChanged: widget.enabled ? (value) {
                if (widget.validator != null) {
                  final error = widget.validator!(value);
                  _validationController.updateValidation(error);
                }
                widget.onChanged?.call(value);
              } : null,
              decoration: InputDecoration(
                hintText: widget.hintText,
                filled: true,
                fillColor: widget.fillColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: hasError ? theme.colorScheme.error : theme.colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: hasError ? theme.colorScheme.error : theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(color: theme.colorScheme.error),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                errorText: state.error,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Enhanced date picker field
class EnhancedDateField extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String label;
  final String? hintText;
  final void Function(DateTime)? onDateSelected;
  final String? Function(DateTime?)? validator;
  final bool enabled;
  final FieldValidationController? validationController;

  const EnhancedDateField({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.label,
    this.hintText,
    this.onDateSelected,
    this.validator,
    this.enabled = true,
    this.validationController,
  });

  @override
  State<EnhancedDateField> createState() => _EnhancedDateFieldState();
}

class _EnhancedDateFieldState extends State<EnhancedDateField> {
  late FieldValidationController _validationController;
  DateTime? _selectedDate;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _validationController = widget.validationController ?? FieldValidationController();
    _selectedDate = widget.initialDate;
    if (_selectedDate != null) {
      _textController.text = _formatDate(_selectedDate!);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    if (widget.validationController == null) {
      _validationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListenableBuilder(
      listenable: _validationController,
      builder: (context, _) {
        final state = _validationController.state;
        final hasError = state.error != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: hasError ? theme.colorScheme.error : null,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _textController,
              readOnly: true,
              enabled: widget.enabled,
              onTap: widget.enabled ? _selectDate : null,
              decoration: InputDecoration(
                hintText: widget.hintText,
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? theme.colorScheme.error : theme.colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? theme.colorScheme.error : theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.error),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                errorText: state.error,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime.now(),
      lastDate: widget.lastDate ?? DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _textController.text = _formatDate(picked);
      });

      if (widget.validator != null) {
        final error = widget.validator!(picked);
        _validationController.updateValidation(error);
      }

      widget.onDateSelected?.call(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Enhanced time picker field
class EnhancedTimeField extends StatefulWidget {
  final TimeOfDay? initialTime;
  final String label;
  final String? hintText;
  final void Function(TimeOfDay)? onTimeSelected;
  final String? Function(TimeOfDay?)? validator;
  final bool enabled;
  final FieldValidationController? validationController;

  const EnhancedTimeField({
    super.key,
    this.initialTime,
    required this.label,
    this.hintText,
    this.onTimeSelected,
    this.validator,
    this.enabled = true,
    this.validationController,
  });

  @override
  State<EnhancedTimeField> createState() => _EnhancedTimeFieldState();
}

class _EnhancedTimeFieldState extends State<EnhancedTimeField> {
  late FieldValidationController _validationController;
  TimeOfDay? _selectedTime;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _validationController = widget.validationController ?? FieldValidationController();
    _selectedTime = widget.initialTime;
    if (_selectedTime != null) {
      _textController.text = _formatTime(_selectedTime!);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    if (widget.validationController == null) {
      _validationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListenableBuilder(
      listenable: _validationController,
      builder: (context, _) {
        final state = _validationController.state;
        final hasError = state.error != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: hasError ? theme.colorScheme.error : null,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _textController,
              readOnly: true,
              enabled: widget.enabled,
              onTap: widget.enabled ? _selectTime : null,
              decoration: InputDecoration(
                hintText: widget.hintText,
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                prefixIcon: const Icon(Icons.access_time),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? theme.colorScheme.error : theme.colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? theme.colorScheme.error : theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.error),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                errorText: state.error,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _textController.text = _formatTime(picked);
      });

      if (widget.validator != null) {
        final error = widget.validator!(picked);
        _validationController.updateValidation(error);
      }

      widget.onTimeSelected?.call(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }
}

// Este widget está pensado para Flutter Web.
// Usa un HTML input type="time" real, con formato 24 horas.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class TimeInputField extends StatefulWidget {
  const TimeInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<TimeInputField> createState() => _TimeInputFieldState();
}

class _TimeInputFieldState extends State<TimeInputField> {
  late final String _viewType;
  html.InputElement? _inputElement;

  @override
  void initState() {
    super.initState();
    _viewType = 'time-input-${identityHashCode(this)}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final input = html.InputElement()
        ..type = 'time'
        ..value = widget.value
        ..style.width = '100%'
        ..style.height = '46px'
        ..style.boxSizing = 'border-box'
        ..style.padding = '0 12px'
        ..style.border = '1px solid #c7c7c7'
        ..style.borderRadius = '12px'
        ..style.fontSize = '16px'
        ..style.outline = 'none';

      input.onChange.listen((_) {
        final value = input.value;
        if (value != null && value.isNotEmpty) {
          widget.onChanged(value);
        }
      });

      _inputElement = input;
      return input;
    });
  }

  @override
  void didUpdateWidget(covariant TimeInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_inputElement != null && _inputElement!.value != widget.value) {
      _inputElement!.value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: HtmlElementView(viewType: _viewType),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    required this.title,
    this.titleStyle,
    required this.enabled,
    this.enabledColor,
    this.icon,
    this.trailing,
    this.changed,
    super.key,
  });

  final String title;

  final TextStyle? titleStyle;

  final bool enabled;

  final Color? enabledColor;

  final Widget? icon;

  final Widget? trailing;

  final void Function(bool)? changed;

  void onTap() {
    if (changed != null) changed!(!enabled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = TextButton.styleFrom(
      foregroundColor: enabled
          ? enabledColor ?? theme.colorScheme.secondary
          : theme.disabledColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );

    Widget label = Text(
      title,
      style: titleStyle,
    );

    if (trailing != null) {
      label = Row(children: [label, trailing!]);
    }

    // return Container(
    //   color: Colors.white,
    //   child: Row()
    // );

    return icon != null
        ? TextButton.icon(
            style: style,
            icon: icon!,
            onPressed: onTap,
            label: label,
          )
        : TextButton(
            style: style,
            onPressed: onTap,
            child: label,
          );
  }
}

import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    required this.label,
    required this.enabled,
    this.enabledColor,
    this.icon,
    this.trailing,
    this.changed,
    super.key,
  });

  final Widget label;

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
          // * 수정한 부분 - 비활성화 탭 텍스트 색상 변경
          // [ 원본 코드  ]
          // : theme.disabledColor,
          // [ 변경 코드 ]
          : theme.textTheme.displaySmall?.color?.withOpacity(.5),
      // --------------------------------------------------------
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );

    // Widget label = Text(
    //   title,
    //   style: titleStyle,
    // );
    Widget textbuttonLabel = label;

    if (trailing != null) {
      textbuttonLabel = Row(children: [label, trailing!]);
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
            label: textbuttonLabel,
          )
        : TextButton(
            style: style,
            onPressed: onTap,
            child: textbuttonLabel,
          );
  }
}

import 'package:flutter/material.dart';
import 'package:normal_julia_sets/colors.dart';

import 'package:normal_julia_sets/normal_julia_sets/models/set_properties.dart';

class CardControls extends StatelessWidget {
  const CardControls({
    Key? key,
    required this.props,
    required this.onEdit,
    required this.onRemove,
    required this.onCreateClone,
    required this.disabled,
  }) : super(key: key);
  final SetProperties props;
  final bool disabled;
  final void Function(SetProperties props) onEdit;
  final void Function(SetProperties props) onRemove;
  final void Function(SetProperties props) onCreateClone;

  @override
  Widget build(BuildContext context) {
    final buttonIconColor = AppColors.champagnePink.withOpacity(
      !disabled ? 1 : 0.5,
    );
    final buttonBackgroundColor = AppColors.semiTransparentDark.withOpacity(
      !disabled ? 0.5 : 0.2,
    );
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Ink(
              decoration: ShapeDecoration(
                color: buttonBackgroundColor,
                shape: const CircleBorder(),
              ),
              child: IconButton(
                iconSize: 32,
                onPressed: disabled ? null : onEditPress,
                color: buttonIconColor,
                icon: const Icon(
                  Icons.edit_rounded,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Ink(
              decoration: ShapeDecoration(
                color: buttonBackgroundColor,
                shape: const CircleBorder(),
              ),
              child: IconButton(
                iconSize: 32,
                onPressed: disabled ? null : onRemovePress,
                color: buttonIconColor,
                icon: const Icon(
                  Icons.delete_forever_rounded,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Ink(
              decoration: ShapeDecoration(
                color: buttonBackgroundColor,
                shape: const CircleBorder(),
              ),
              child: IconButton(
                iconSize: 32,
                onPressed: disabled ? null : onClonePress,
                color: buttonIconColor,
                icon: const Icon(
                  Icons.copy_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onRemovePress() => onRemove(props);

  void onEditPress() => onEdit(props);

  void onClonePress() => onCreateClone(props);
}

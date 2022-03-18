import 'dart:async';

import 'package:flutter/material.dart';
import 'package:normal_julia_sets/colors.dart';
import 'package:normal_julia_sets/l10n/l10n.dart';
import 'package:normal_julia_sets/normal_julia_sets/models/nullable.dart';
import 'package:normal_julia_sets/normal_julia_sets/models/set_properties.dart';

typedef OnSliderChange = void Function(double value);

class EditingOverlay extends StatefulWidget {
  const EditingOverlay({
    Key? key,
    required this.width,
    required this.height,
    required this.currentProps,
    required this.onChangeProps,
    required this.onSaveEditingSet,
    required this.onCancelEditingSet,
  }) : super(key: key);
  final double width;
  final double height;
  final SetProperties currentProps;
  final void Function(SetProperties props) onChangeProps;
  final VoidCallback onSaveEditingSet;
  final VoidCallback onCancelEditingSet;

  @override
  State<EditingOverlay> createState() => _EditingOverlayState();
}

class _EditingOverlayState extends State<EditingOverlay> {
  Timer? _debounce;
  SetProperties? unsavedProps;

  SetProperties get currentProps => unsavedProps ?? widget.currentProps;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: AppColors.semiTransparentDark,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(l10n.labelMaxIterationsCount),
              Slider(
                min: 50,
                max: 500,
                label: '${currentProps.maxIterations}',
                value: currentProps.maxIterations + 0.0,
                onChanged: onChangeMaxIterations,
              ),
              Text(l10n.labelEscapeRadius),
              Slider(
                min: 1,
                max: 6,
                label: '${currentProps.escape}',
                value: currentProps.escape,
                onChanged: onChangeEscape,
              ),
              Text(l10n.labelRealConstant),
              Slider(
                min: -1,
                label: '${currentProps.constX}',
                value: currentProps.constX,
                onChanged: onChangeConstX,
              ),
              Text(l10n.labelImaginaryConstant),
              Slider(
                min: -1,
                label: '${currentProps.constY}',
                value: currentProps.constY,
                onChanged: onChangeConstY,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: widget.onSaveEditingSet,
                    icon: const Icon(
                      Icons.save_rounded,
                      color: AppColors.champagnePink,
                    ),
                  ),
                  IconButton(
                    onPressed: onRandomizeEditingSet,
                    icon: const Icon(
                      Icons.shuffle_rounded,
                      color: AppColors.champagnePink,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onCancelEditingSet,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.champagnePink,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void onChangePropsDebounced() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      final newProps = unsavedProps;
      if (newProps == null) return;
      widget.onChangeProps(
        newProps.copyWith(
          image: const Nullable(null),
          imageSrc: const Nullable(null),
        ),
      );
    });
  }

  void onChangeConstY(double val) {
    setState(
      () => unsavedProps = currentProps.copyWith(
        constY: val,
      ),
    );
    onChangePropsDebounced();
  }

  void onChangeMaxIterations(double val) {
    setState(
      () => unsavedProps = currentProps.copyWith(
        maxIterations: val.round(),
      ),
    );
    onChangePropsDebounced();
  }

  void onChangeEscape(double val) {
    setState(
      () => unsavedProps = currentProps.copyWith(
        escape: val,
      ),
    );
    onChangePropsDebounced();
  }

  void onChangeConstX(double val) {
    setState(
      () => unsavedProps = currentProps.copyWith(
        constX: val,
      ),
    );
    onChangePropsDebounced();
  }

  void onRandomizeEditingSet() {
    setState(
      () => unsavedProps = SetProperties.random().copyWith(
        id: currentProps.id,
        created: currentProps.created,
      ),
    );
    onChangePropsDebounced();
  }
}

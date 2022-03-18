import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:normal_julia_sets/l10n/l10n.dart';
import 'package:normal_julia_sets/normal_julia_sets/models/set_properties.dart';
import 'package:normal_julia_sets/normal_julia_sets/services/create_set.dart';

class JuliaSetImage extends StatelessWidget {
  const JuliaSetImage({
    Key? key,
    required this.props,
    required this.sideLen,
  }) : super(key: key);
  final double sideLen;
  final SetProperties props;

  @override
  Widget build(BuildContext context) {
    if (props.image != null) {
      return RawImage(
        key: ValueKey('raw-image-${props.id}'),
        image: props.image,
        fit: BoxFit.cover,
        width: sideLen,
        height: sideLen,
      );
    }

    if (props.imageSrc != null) {
      return Image.network(
        props.imageSrc!,
        width: sideLen,
        height: sideLen,
        loadingBuilder: (ctx, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return SizedBox(
            key: const ValueKey('loading-image'),
            width: sideLen,
            height: sideLen,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    }

    return FutureBuilder<ui.Image>(
      future: makeImage(
        constX: props.constX,
        constY: props.constY,
        maxIterations: props.maxIterations,
        escape: props.escape,
      ),
      builder: (context, snapshot) {
        Widget content;
        if (snapshot.hasError) {
          content = Center(child: Text(context.l10n.retriableErrorOcurred));
        } else if (snapshot.data != null) {
          content = RawImage(image: snapshot.data, fit: BoxFit.cover);
        } else {
          content = const Center(
            child: CircularProgressIndicator(),
          );
        }
        return SizedBox(
          width: sideLen,
          height: sideLen,
          child: content,
        );
      },
    );
  }
}

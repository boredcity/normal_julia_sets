import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:normal_julia_sets/normal_julia_sets/models/id.dart';
import 'package:normal_julia_sets/normal_julia_sets/models/nullable.dart';

class SetProperties extends Equatable {
  const SetProperties(
    this.id, {
    required this.maxIterations,
    required this.constX,
    required this.constY,
    required this.escape,
    required this.created,
    required this.imageSrc,
    required this.image,
  });

  factory SetProperties.random() {
    final rng = Random();
    return SetProperties(
      SetProperties.getTempId(),
      constX: rng.nextDouble() * 2 - 1,
      constY: rng.nextDouble() * 2 - 1,
      escape: rng.nextDouble() * 5 + 1,
      maxIterations: rng.nextInt(451) + 50,
      created: Timestamp.now(),
      image: null,
      imageSrc: null,
    );
  }

  factory SetProperties.fromMap(Map<String, dynamic> map) {
    return SetProperties(
      map['id'] as String,
      maxIterations: map['maxIterations'] as int,
      constX: (map['constX'] as num).toDouble(),
      constY: (map['constY'] as num).toDouble(),
      escape: (map['escape'] as num).toDouble(),
      created: map['created'] as Timestamp,
      imageSrc: map['imageSrc'] as String,
      image: null,
    );
  }

  static const tempId = 'TEMP_ID';

  final Id id;
  final int maxIterations;
  final double constX;
  final double constY;
  final double escape;
  final Timestamp created;
  final Image? image;
  final String? imageSrc;

  static String getTempId() {
    return tempId;
  }

  SetProperties copyWith({
    Id? id,
    int? maxIterations,
    double? constX,
    double? constY,
    double? escape,
    Timestamp? created,
    Nullable<Image>? image,
    Nullable<String>? imageSrc,
  }) {
    return SetProperties(
      id ?? this.id,
      maxIterations: maxIterations ?? this.maxIterations,
      constX: constX ?? this.constX,
      constY: constY ?? this.constY,
      escape: escape ?? this.escape,
      created: created ?? this.created,
      image: Nullable.getValueWithFallback(image, this.image),
      imageSrc: Nullable.getValueWithFallback(imageSrc, this.imageSrc),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'maxIterations': maxIterations,
      'constX': constX,
      'constY': constY,
      'escape': escape,
      'created': created,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  List<Object?> get props => [
        maxIterations,
        constX,
        constY,
        escape,
        id,
        created,
        image,
        imageSrc,
      ];
}

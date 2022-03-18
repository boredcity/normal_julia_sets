import 'package:equatable/equatable.dart';

import 'package:normal_julia_sets/normal_julia_sets/models/nullable.dart';
import 'package:normal_julia_sets/normal_julia_sets/models/set_properties.dart';

abstract class SetsState extends Equatable {
  const SetsState({
    required this.isConnecting,
    required this.list,
    required this.err,
  });

  final bool isConnecting;
  final List<SetProperties> list;
  final dynamic? err; // TODO(merelj): use typed errors

  @override
  String toString() {
    return 'SetsState(isConnecting: $isConnecting, list: $list, err: $err)';
  }

  SetsState copyWith({
    bool? isConnecting,
    List<SetProperties>? list,
    Nullable<dynamic>? err,
  });

  @override
  List<Object?> get props => [err, isConnecting, list];
}

/// local state is not synched
class LocalSetsState extends SetsState {
  const LocalSetsState({
    required List<SetProperties> list,
    required bool isConnecting,
  }) : super(
          isConnecting: isConnecting,
          list: list,
          err: null,
        );

  @override
  LocalSetsState copyWith({
    bool? isConnecting,
    List<SetProperties>? list,
    Nullable<dynamic>? err,
  }) {
    return LocalSetsState(
      list: list ?? this.list,
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }
}

/// local state is synched
class ConnectedSetsState extends SetsState {
  const ConnectedSetsState({
    required List<SetProperties> list,
    required dynamic? err,
  }) : super(
          isConnecting: false,
          list: list,
          err: err,
        );

  @override
  ConnectedSetsState copyWith({
    bool? isConnecting,
    List<SetProperties>? list,
    Nullable<dynamic>? err,
  }) {
    return ConnectedSetsState(
      err: Nullable.getValueWithFallback<dynamic>(err, this.err),
      list: list ?? this.list,
    );
  }
}

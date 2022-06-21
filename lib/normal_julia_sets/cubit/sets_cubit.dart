import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:normal_julia_sets/normal_julia_sets/cubit/sets_state.dart';
import 'package:normal_julia_sets/normal_julia_sets/models/nullable.dart';

import 'package:normal_julia_sets/normal_julia_sets/models/set_properties.dart';
import 'package:normal_julia_sets/normal_julia_sets/services/create_set.dart';
import 'package:normal_julia_sets/normal_julia_sets/services/firestore.dart';

class SetsCubit extends Cubit<SetsState> {
  SetsCubit({required this.setService})
      : super(
          const LocalSetsState(list: [], isConnecting: true),
        ) {
    getSets();
  }
  final SetsService setService;

  Future<void> getSets() async {
    final originalState = state;
    emit(LocalSetsState(list: originalState.list, isConnecting: true));
    try {
      final sets = await setService.getSets();
      emit(ConnectedSetsState(list: sets, err: null));
    } catch (err) {
      final newState = ConnectedSetsState(list: originalState.list, err: err);
      emit(newState);
      debugPrint(err.toString());
    }
  }

  Future<void> addSet(SetProperties setProps) async {
    final newList = [setProps, ...state.list];
    emit(LocalSetsState(isConnecting: false, list: newList));
  }

  Future<void> updateSet(SetProperties setProps) async {
    final originalState = state;
    final newList = originalState.list
        .map(
          (el) => el.id != setProps.id ? el : setProps,
        )
        .toList();
    emit(LocalSetsState(isConnecting: true, list: newList));

    final image = await makeImage(
      maxIterations: setProps.maxIterations,
      constX: setProps.constX,
      constY: setProps.constY,
      escape: setProps.escape,
    );
    final newProps = setProps.copyWith(image: Nullable(image));
    await _synchChange(
      originalList: originalState.list,
      newList: newList,
      setProps: newProps,
    );
  }

  Future<void> _synchChange({
    required List<SetProperties> originalList,
    required List<SetProperties> newList,
    required SetProperties setProps,
  }) async {
    try {
      debugPrint('Started sync');
      final savedSet = (setProps.id == SetProperties.tempId
              ? await setService.createSet(setProps)
              : await setService.updateSet(setProps))
          .copyWith(image: Nullable(setProps.image));
      debugPrint('Finished sync');
      final savedList = state.list
          .map(
            (el) => el.id == setProps.id ? savedSet : el,
          )
          .toList();
      emit(ConnectedSetsState(list: savedList, err: null));
    } catch (err) {
      emit(ConnectedSetsState(list: originalList, err: err));
      debugPrint(err.toString());
    }
  }

  Future<void> removeSet(SetProperties setProps) async {
    final originalState = state;
    final newList = state.list.where((el) => el.id != setProps.id).toList();
    if (setProps.id == SetProperties.tempId) {
      emit(ConnectedSetsState(err: null, list: newList));
      return;
    }
    try {
      emit(LocalSetsState(isConnecting: true, list: newList));
      await setService.removeSet(setProps);
      emit(ConnectedSetsState(list: newList, err: null));
    } catch (err) {
      emit(ConnectedSetsState(list: originalState.list, err: err));
    }
  }
}

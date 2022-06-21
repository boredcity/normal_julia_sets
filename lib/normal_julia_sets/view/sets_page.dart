import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:normal_julia_sets/app/services/auth.dart';
import 'package:normal_julia_sets/app/view/restart.dart';
import 'package:normal_julia_sets/colors.dart';
import 'package:normal_julia_sets/l10n/l10n.dart';
import 'package:normal_julia_sets/normal_julia_sets/cubit/sets_cubit.dart';
import 'package:normal_julia_sets/normal_julia_sets/cubit/sets_state.dart';
import 'package:normal_julia_sets/normal_julia_sets/models/set_properties.dart';
import 'package:normal_julia_sets/normal_julia_sets/view/card_controls.dart';
import 'package:normal_julia_sets/normal_julia_sets/view/editing_overlay.dart';
import 'package:normal_julia_sets/normal_julia_sets/view/julia_set_image.dart';

class SetsPage extends StatefulWidget {
  const SetsPage({Key? key}) : super(key: key);

  @override
  SetsPageState createState() => SetsPageState();
}

class SetsPageState extends State<SetsPage> {
  final _scrollController = ScrollController();

  SetProperties? editingSet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.champagnePink,
      appBar: AppBar(
        title: Text(
          l10n.appBarTitle,
          style: const TextStyle(color: AppColors.champagnePink),
        ),
        actions: [
          BlocBuilder<SetsCubit, SetsState>(
            builder: (context, state) {
              return IconButton(
                key: const ValueKey('create'),
                iconSize: 32,
                onPressed: canEdit(state) ? onCreateSet : null,
                icon: Icon(
                  Icons.note_add_rounded,
                  color: AppColors.champagnePink.withOpacity(
                    canEdit(state) ? 1 : 0.5,
                  ),
                ),
              );
            },
          ),
          IconButton(
            key: const ValueKey('logout'),
            iconSize: 32,
            onPressed: () async {
              await AuthService.getInstance().signOut();
              if (mounted) RestartWidget.restartApp(context);
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.champagnePink,
            ),
          ),
        ],
      ),
      body: BlocConsumer<SetsCubit, SetsState>(
        listener: (context, state) {
          if (editingSet != null) {
            if (!state.list.contains(editingSet)) {
              setState(() => editingSet = null);
            }
          }
          if (state.err != null) {
            final snackBar = SnackBar(
              backgroundColor: AppColors.semiTransparentDark,
              content: Text('${state.err}!'),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        builder: (context, state) {
          final saved = state.list;
          final isConnecting = state.isConnecting;
          if (saved.isEmpty) {
            return Center(
              key: const ValueKey('no-saved'),
              child: isConnecting
                  ? const CircularProgressIndicator()
                  : TextButton(
                      onPressed: onCreateSet,
                      child: Text(
                        l10n.createFirstSet,
                        textAlign: ui.TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.blue,
                        ),
                      ),
                    ),
            );
          }

          /// NOTE: cannot use ListView.builder because of this bug:
          /// https://github.com/flutter/flutter/issues/58917
          return RefreshIndicator(
            key: const ValueKey('refresher'),
            onRefresh: () => BlocProvider.of<SetsCubit>(context).getSets(),
            child: ListView.custom(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              childrenDelegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  if (i >= saved.length) return null;

                  const cardMargin = 8.0;
                  var props = saved[i];
                  final isBeingEdited = editingSet?.id == props.id;
                  if (isBeingEdited) {
                    props = editingSet!;
                  }

                  return LayoutBuilder(
                    /// NOTE: SliverChildBuilderDelegate's 2nd arg depends
                    /// on this key value; change only in both places at once
                    key: ValueKey(props.id),
                    builder: (ctx, constraints) {
                      final maxSideLen = min(
                        min(
                          constraints.maxWidth,
                          MediaQuery.of(context).size.height,
                        ),
                        1024,
                      ).toDouble();
                      return Center(
                        child: SizedBox(
                          width: maxSideLen,
                          child: Card(
                            key: ValueKey('card-for-${props.id}'),
                            elevation: 2,
                            color: AppColors.barelyVisibleUmber,
                            margin: const EdgeInsets.all(cardMargin),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                ui.Radius.circular(8),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                FittedBox(
                                  child: JuliaSetImage(
                                    key: ValueKey(props.id),
                                    sideLen: maxSideLen,
                                    props: props,
                                  ),
                                ),
                                if (!isBeingEdited)
                                  CardControls(
                                    key: const ValueKey('controls'),
                                    props: props,
                                    disabled: !canEdit(state),
                                    onEdit: onStartEditingSet,
                                    onRemove: onRemoveSet,
                                    onCreateClone: onCreateSet,
                                  ),
                                if (isBeingEdited)
                                  EditingOverlay(
                                    key: const ValueKey('editing-overlay'),
                                    width: maxSideLen,
                                    height: maxSideLen - cardMargin * 2,
                                    currentProps: props,
                                    onCancelEditingSet: onCancelEditingSet,
                                    onChangeProps: onChangeProps,
                                    onSaveEditingSet: onSaveEditingSet,
                                  )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                findChildIndexCallback: (key) {
                  return saved.indexWhere(
                    (element) => element.id == (key as ValueKey).value,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void onChangeProps(SetProperties props) {
    setState(() => editingSet = props);
  }

  Future<void> onRemoveSet(SetProperties props) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return AlertDialog(
          title: Text(l10n.confirmRemovalTitle),
          content: Text(l10n.confirmRemovalContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.confirmRemovalNo),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.confirmRemovalYes),
            ),
          ],
        );
      },
    );
    if (mounted && (shouldRemove ?? false)) {
      unawaited(BlocProvider.of<SetsCubit>(context).removeSet(props));
    }
  }

  void onStartEditingSet(SetProperties props) {
    setState(() => editingSet = props);
  }

  void onCancelEditingSet() {
    if (editingSet?.id == SetProperties.tempId) {
      unawaited(BlocProvider.of<SetsCubit>(context).removeSet(editingSet!));
    }
    setState(() => editingSet = null);
  }

  void onCreateSet([SetProperties? cloneTarget]) {
    final newSetProps = cloneTarget == null
        ? SetProperties.random()
        : cloneTarget.copyWith(
            id: SetProperties.getTempId(),
            created: Timestamp.now(),
          );
    BlocProvider.of<SetsCubit>(context).addSet(newSetProps);
    setState(() => editingSet = newSetProps);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  bool canEdit(SetsState state) {
    return state is! LocalSetsState && editingSet == null;
  }

  void onSaveEditingSet() {
    if (editingSet == null) return;
    BlocProvider.of<SetsCubit>(context).updateSet(editingSet!);
    setState(() => editingSet = null);
  }
}

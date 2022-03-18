import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:normal_julia_sets/app/services/auth.dart';
import 'package:normal_julia_sets/app/view/restart.dart';
import 'package:normal_julia_sets/colors.dart';
import 'package:normal_julia_sets/firebase_options.dart';
import 'package:normal_julia_sets/l10n/l10n.dart';
import 'package:normal_julia_sets/normal_julia_sets/cubit/sets_cubit.dart';
import 'package:normal_julia_sets/normal_julia_sets/services/firestore.dart';
import 'package:normal_julia_sets/normal_julia_sets/view/sets_page.dart';

final colorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.blue,
);

ThemeData theme = ThemeData.from(
  colorScheme: colorScheme,
  textTheme: const TextTheme(
    bodyText2: TextStyle(
      color: Colors.white,
    ),
  ),
);

class JuliaSetsApp extends StatelessWidget {
  const JuliaSetsApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const RestartWidget(child: JuliaSetsAppInner());
  }
}

class JuliaSetsAppInner extends StatelessWidget {
  const JuliaSetsAppInner({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).then(
        (v) => AuthService.getInstance().loginWithGoogle(),
      ),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || AuthService.getInstance().user == null) {
          return MaterialApp(
            home: Center(
              child: TextButton(
                onPressed: () {
                  RestartWidget.restartApp(context);
                },
                child: const Text('Login with Google'),
              ),
            ),
          );
        }
        return MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: theme.copyWith(
            sliderTheme: theme.sliderTheme.copyWith(
              activeTrackColor: AppColors.champagnePink88,
              inactiveTrackColor: AppColors.champagnePink44,
              thumbColor: AppColors.champagnePink,
            ),
          ),
          home: BlocProvider(
            create: (ctx) => SetsCubit(
              setService: FirestoreService.getInstance(),
            ),
            child: const SetsPage(),
          ),
        );
      },
    );
  }
}

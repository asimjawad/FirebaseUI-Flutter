import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

const labels = DefaultLocalizations();

void main() {
  setUpAll(prepare);
  tearDown(authCleanup);

  group('EmailForm', () {
    testWidgets(
      'registers new user',
      (tester) async {
        await render(tester, const EmailForm(action: AuthAction.signUp));

        final inputs = find.byType(TextFormField);

        await tester.enterText(inputs.at(0), 'test@test.com');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        await tester.enterText(inputs.at(1), 'password');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        await tester.enterText(inputs.at(2), 'password');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);
        await tester.pumpAndSettle();

        expect(auth.currentUser, isNotNull);
      },
    );

    testWidgets('shows wrong password error', (tester) async {
      await auth.createUserWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password',
      );

      await auth.signOut();

      await render(tester, const EmailForm(action: AuthAction.signIn));

      final inputs = find.byType(TextFormField);

      await tester.enterText(inputs.at(0), 'test@test.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.enterText(inputs.at(1), 'wrongpassword');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();

      expect(find.text(labels.wrongOrNoPasswordErrorText), findsOneWidget);
    });

    testWidgets('signs in the user', (tester) async {
      await auth.createUserWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password',
      );

      await auth.signOut();

      await render(
        tester,
        const EmailForm(action: AuthAction.signIn),
      );

      final inputs = find.byType(TextFormField);

      await tester.enterText(inputs.at(0), 'test@test.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.enterText(inputs.at(1), 'password');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();

      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.email, 'test@test.com');
    });

    testWidgets(
      'links email and password when auth action is link',
      (tester) async {
        await render(
          tester,
          const EmailForm(action: AuthAction.link),
        );

        await auth.signInAnonymously();
        final initialUid = auth.currentUser!.uid;

        final inputs = find.byType(TextFormField);

        await tester.enterText(inputs.at(0), 'test@test.com');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.enterText(inputs.at(1), 'password');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.enterText(inputs.at(2), 'password');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.pumpAndSettle();

        await auth.signOut();
        await auth.signInWithEmailAndPassword(
          email: 'test@test.com',
          password: 'password',
        );

        expect(auth.currentUser!.uid, initialUid);
      },
    );
  });
}

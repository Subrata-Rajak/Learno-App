import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';

/// Adapter that bridges [AuthBloc] state updates into a [Listenable]
/// for GoRouter's `refreshListenable` hook.
class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(this._authBloc) {
    _subscription = _authBloc.stream.listen((state) {
      notifyListeners();
    });
  }

  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _subscription;

  AuthState get authState => _authBloc.state;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}


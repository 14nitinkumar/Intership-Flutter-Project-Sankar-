import 'package:flutter_bloc/flutter_bloc.dart';
import '../../main.dart';
import '../../utils/preference_keys/preference_keys.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashState());

  Future<void> checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final bool loggedIn = sharedPreferences.getBool(PreferenceKeys.isLoggedIn) ?? false;
    emit(state.copyWith(isLoaded: true, isLoggedIn: loggedIn));
  }
}

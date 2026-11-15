class SplashState {
  final bool isLoaded;
  final bool isLoggedIn;

  SplashState({
    this.isLoaded = false,
    this.isLoggedIn = false,
  });

  SplashState copyWith({
    bool? isLoaded,
    bool? isLoggedIn,
  }) {
    return SplashState(
      isLoaded: isLoaded ?? this.isLoaded,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

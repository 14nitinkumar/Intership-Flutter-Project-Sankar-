class DashboardState {
  final int currentTabIndex;

  DashboardState({
    this.currentTabIndex = 0,
  });

  DashboardState copyWith({
    int? currentTabIndex,
  }) {
    return DashboardState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}

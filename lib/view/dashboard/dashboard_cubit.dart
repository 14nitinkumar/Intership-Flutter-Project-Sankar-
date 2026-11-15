import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({int initialTab = 0}) : super(DashboardState(currentTabIndex: initialTab));

  void setTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTabProvider = NotifierProvider<SelectedTabController, int>(
  SelectedTabController.new,
);

class SelectedTabController extends Notifier<int> {
  static const home = 0;
  static const map = 1;
  static const alerts = 2;
  static const settings = 3;

  @override
  int build() => home;

  void select(int index) {
    state = index;
  }

  void showAlerts() {
    state = alerts;
  }
}

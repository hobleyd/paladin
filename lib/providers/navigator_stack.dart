import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigator_stack.g.dart';

@Riverpod(keepAlive: true)
class NavigatorStack extends _$NavigatorStack {
  static const String homeScreen = "home-screen";

  @override
  List<String> build() {
    return [homeScreen];
  }

  void _pop() {
    List<String> routes = List.from(state);
    List<String> poppedRoutes = routes.getRange(1, state.length).toList();

    state = poppedRoutes;
  }

  void popUntil(BuildContext context, String destination) {
    List<String> routes = List.from(state);
    List<String> newStack = List.from(state);

    for (String route in routes) {
      if (route != destination) {
        newStack.remove(route);
        Navigator.pop(context);
      }
    }
    state = newStack;
  }

  void push(BuildContext context, String source, MaterialPageRoute route) {
    List<String> routes = List.from(state);
    routes.insert(0, source);
    state = routes;

    // Push the route
    Navigator.push(context, route).then((onValue) => _pop());
  }
}
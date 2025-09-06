import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigator_stack.g.dart';

@Riverpod(keepAlive: true)
class NavigatorStack extends _$NavigatorStack {
  @override
  List<String> build() {
    return ["home_screen"];
  }

  void popUntil(BuildContext context, String destination) {
    List<String> routes = List.from(state);
    List<String> newStack = List.from(state);

    for (String route in routes) {
      if (route != destination) {
        newStack.remove(route);
        debugPrint('popping the context');
        Navigator.pop(context);
      }
    }
    state = newStack;
  }

  void push(BuildContext context, String source, MaterialPageRoute route) {
    List<String> routes = List.from(state);
    routes.insert(0, source);
    state = routes;

    Navigator.push(context, route);
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellNavigation extends StatelessWidget {
  final Widget child; // The screen content provided by GoRouter ShellRoute
  const ShellNavigation({super.key, required this.child});

  // Define the paths corresponding to the BottomNavigationBar items
  static const tabs = [
    '/home',
    '/exchange',
    '/tokens',
    '/Portfolio',
  ];

  // Calculate the selected index based on the current route location
  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final index = tabs.indexWhere((tabPath) => location.startsWith(tabPath));
    return index == -1 ? 0 : index; // Default to first tab if no match
  }

  // Navigate using GoRouter when a bottom tab is tapped
  void _onTap(BuildContext context, int index) {
    if (index >= 0 && index < tabs.length) {
      context.go(tabs[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.currency_exchange), label: 'Exchange'),
          BottomNavigationBarItem(icon: Icon(Icons.token), label: 'Tokens'),
          BottomNavigationBarItem(
              icon: Icon(Icons.comment_outlined), label: 'Portfolio'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'diary_list_screen.dart';
import 'home_screen.dart';
import 'place_alias_screen.dart';
import 'settings_screen.dart';

/// Bottom-nav shell hosting the four top-level screens from spec section 6
/// (日記詳細 is pushed on top from the home/list screens, not a tab).
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    DiaryListScreen(),
    PlaceAliasScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
          NavigationDestination(icon: Icon(Icons.book), label: '日記一覧'),
          NavigationDestination(icon: Icon(Icons.place), label: '場所'),
          NavigationDestination(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}

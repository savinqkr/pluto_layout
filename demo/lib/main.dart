import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_layout/pluto_layout.dart';

import 'screens/screens.dart';
import 'tabs/tabs.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage>
    with SingleTickerProviderStateMixin {
  final String httpProtocol = kReleaseMode ? 'https' : 'http';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
          scrollbars: true,
        ),
        child: PlutoLayout(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.escape):
                PlutoLayoutActions.hideAllTabView(),
            LogicalKeySet(LogicalKeyboardKey.enter):
                PlutoLayoutActions.toggleTabView(),
            LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit1):
                PlutoLayoutActions.rotateTabView(
              PlutoLayoutId.left,
            ),
            LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit2):
                PlutoLayoutActions.rotateTabView(
              PlutoLayoutId.right,
            ),
            LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowUp):
                PlutoLayoutActions.increaseTabView(),
            LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowDown):
                PlutoLayoutActions.decreaseTabView(),
            LogicalKeySet(
                    LogicalKeyboardKey.control, LogicalKeyboardKey.arrowUp):
                PlutoLayoutActions.increaseTabItemView(),
            LogicalKeySet(
                    LogicalKeyboardKey.control, LogicalKeyboardKey.arrowDown):
                PlutoLayoutActions.decreaseTabItemView(),
            LogicalKeySet(LogicalKeyboardKey.tab):
                PlutoLayoutActions.rotateFocusedTabItem(),
            LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
                PlutoLayoutActions.rotateFocusedTabItem(reverse: true),
            LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.control,
                    LogicalKeyboardKey.arrowRight):
                PlutoLayoutActions.rotateFocusedContainer(),
            LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.control,
                    LogicalKeyboardKey.arrowLeft):
                PlutoLayoutActions.rotateFocusedContainer(reverse: true),
            LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyN):
                PlutoLayoutActions.insertTabItem(
              layoutId: PlutoLayoutId.body,
              itemResolver: ({required items}) {
                final foundNew = items
                    .where((e) => e.title.startsWith('New '))
                    .map((e) => int.parse(e.title.replaceAll('New ', '')))
                    .toList()
                  ..sort();

                final int index = foundNew.isEmpty ? 1 : ++foundNew.last;

                return PlutoInsertTabItemResult(
                  item: PlutoLayoutTabItem(
                    id: '$index',
                    title: 'New $index',
                    enabled: true,
                    showRemoveButton: true,
                    tabViewBuilder: (e) => const ColoredBox(
                      color: Colors.white,
                      child: Text('new tab'),
                    ),
                  ),
                );
              },
            ),
          },
          body: const PlutoLayoutContainer(
            child: HomeScreen(),
          ),
          top: const PlutoLayoutContainer(
            child: TopTab(),
          ),
          left: const PlutoLayoutContainer(
            child: LeftTab(),
          ),
          right: const PlutoLayoutContainer(
            child: RightTab(),
          ),
          bottom: const PlutoLayoutContainer(
            child: BottomTab(),
          ),
        ),
      ),
    );
  }
}

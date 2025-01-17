import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_layout/pluto_layout.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlutoLayout(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.escape):
              PlutoLayoutActions.hideAllTabView(),
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
        },
        body: const PlutoLayoutContainer(
          child: Text('Body container'),
        ),
        top: PlutoLayoutContainer(
          child: PlutoLayoutTabs(
            items: [
              PlutoLayoutTabItem(
                id: 'top1',
                label: const Text('top1', style: TextStyle(fontSize: 40)),
                tabViewWidget: const Text('top1'),
                // enabledColor: Colors.white,
              ),
              PlutoLayoutTabItem(
                id: 'top2',
                label: const Text('top2'),
                tabViewWidget: const Text('top2'),
                // enabledColor: Colors.white,
              ),
            ],
          ),
        ),
        left: PlutoLayoutContainer(
          child: PlutoLayoutTabs(
            items: [
              PlutoLayoutTabItem(
                id: 'left1',
                label: const Text('left1', style: TextStyle(fontSize: 40)),
                tabViewWidget: const Text('left1'),
                enabledColor: Colors.blue,
              ),
              PlutoLayoutTabItem(
                id: 'left2',
                label: const Text('left2'),
                tabViewWidget: const Text('left2'),
                enabledColor: Colors.blue,
              ),
            ],
          ),
        ),
        right: PlutoLayoutContainer(
          child: PlutoLayoutTabs(
            items: [
              PlutoLayoutTabItem(
                id: 'right1',
                label: const Text('right1', style: TextStyle(fontSize: 40)),
                tabViewWidget: const Text('right1'),
                enabledColor: Colors.orange,
              ),
              PlutoLayoutTabItem(
                id: 'right2',
                label: const Text('right2'),
                tabViewWidget: const Text('right2'),
                enabledColor: Colors.orange,
              ),
            ],
          ),
        ),
        bottom: PlutoLayoutContainer(
          child: PlutoLayoutTabs(
            items: [
              PlutoLayoutTabItem(
                id: 'bottom1',
                label: const Text('bottom1'),
                tabViewWidget: const Text('bottom1'),
                enabledColor: Colors.teal,
              ),
              PlutoLayoutTabItem(
                id: 'bottom2',
                label: const Text('bottom2'),
                tabViewWidget: const Text('bottom2'),
                enabledColor: Colors.teal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

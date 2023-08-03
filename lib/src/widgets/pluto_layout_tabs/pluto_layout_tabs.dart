library pluto_layout_tabs;

import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pluto_layout/pluto_layout.dart';
import 'package:pluto_layout/src/helper/resize_helper.dart';

import '../../pluto_layout_data.dart';
import '../../pluto_layout_provider.dart';
import '../../ui/pluto_layout_container_provider.dart';
import '../resize_indicator.dart';
import '../toggle_button.dart';

export 'pluto_layout_tab_view_size_resolver.dart';

part '_items_provider.dart';
part '_menus.dart';
part '_tab_view.dart';
part 'pluto_layout_tab_item.dart';
part 'pluto_layout_tab_item_size_resolver.dart';
part 'pluto_layout_tabs_or_child.dart';

final _focusedItemIdViewProvider = StateProvider<Object?>((ref) => null);

/// [PlutoLayoutContainer]의 자식으로 전달하여 탭 보기를 구성할 수 있습니다.
///
/// {@macro pluto_layout_example}
class PlutoLayoutTabs extends ConsumerWidget {
  PlutoLayoutTabs({
    List<PlutoLayoutTabItem>? items,
    this.mode = PlutoLayoutTabMode.showOne,
    this.tabViewSizeResolver,
    bool? draggable,
    super.key,
  })  : items = _updateConstrains(items ?? [], mode),
        draggable = draggable ?? false,
        _givenItemsProvider = false,
        _expanded = false;

  PlutoLayoutTabs._givenItemsProvider({
    List<PlutoLayoutTabItem>? items,
    this.mode = PlutoLayoutTabMode.showOne,
    bool? draggable,
    required bool expanded,
  })  : items = _updateConstrains(items ?? [], mode),
        draggable = draggable ?? false,
        tabViewSizeResolver = null,
        _givenItemsProvider = true,
        _expanded = expanded;

  static List<PlutoLayoutTabItem> _updateConstrains(
    List<PlutoLayoutTabItem> items,
    PlutoLayoutTabMode mode,
  ) {
    if (items.isEmpty) return items;

    assert(
      !mode.isShowOneMode || items.where(_TabsHelper.isEnabled).length < 2,
      'If the mode is showOne or showOneMust, the enabled item must be absent or one.',
    );

    if (!mode.isShowOneMust || items.isEmpty) return items;

    if (items.where(_TabsHelper.isEnabled).length == 1) return items;

    return [
      items.first.copyWith(enabled: true),
      ...items.skip(1),
    ];
  }

  /// Pass a list of [PlutoLayoutTabItem].
  ///
  /// ```dart
  /// PlutoLayoutTabItem(
  ///   id: 'Unique ID',
  ///   title: 'Tab Menu Title',
  ///   tabViewBuilder: (c) {
  ///     return Padding(
  ///       padding: EdgeInsets.all(15),
  ///       child: ListView(
  ///         children: const [
  ///           Text('Tab Menu contents'),
  ///           SizedBox(height: 15),
  ///           Text('Tab Menu contents'),
  ///           SizedBox(height: 10),
  ///           Text('Tab Menu contents'),
  ///         ],
  ///       ),
  ///     );
  ///   },
  /// ),
  /// ```
  final List<PlutoLayoutTabItem> items;

  /// {@macro pluto_layout_tab_mode}
  final PlutoLayoutTabMode mode;

  /// Set the size of the tab view.
  ///
  /// The size of the tab view is the width in case of left or right tab,
  /// Means the height if it's a top or bottom tab.
  ///
  /// If not set (default behavior), the width of the tab view is as follows.
  /// For left or right tab: width / 4
  /// For top or bottom tabs: height / 6
  ///
  /// Implemented classes.
  /// [PlutoLayoutTabViewSizeFixed]
  /// {@macro pluto_layout_tab_view_size_fixed}
  ///
  /// [PlutoLayoutTabViewSizeConstrains]
  /// {@macro pluto_layout_tab_view_size_constrains}
  ///
  /// [PlutoLayoutTabViewSizeRatio]
  /// {@macro pluto_layout_tab_view_size_ratio}
  final PlutoLayoutTabViewSizeResolver? tabViewSizeResolver;

  /// If the value is true, drag the item button to move the tab position.
  final bool draggable;

  final bool _givenItemsProvider;

  final bool _expanded;

  int _getTabsRotate(PlutoLayoutContainerDirection id) {
    switch (id) {
      case PlutoLayoutContainerDirection.top:
      case PlutoLayoutContainerDirection.left:
        return 0;
      case PlutoLayoutContainerDirection.bottom:
      case PlutoLayoutContainerDirection.right:
        return 90;
    }
  }

  int _getTabsChildrenRotate(PlutoLayoutContainerDirection id) {
    switch (id) {
      case PlutoLayoutContainerDirection.top:
      case PlutoLayoutContainerDirection.left:
        return 0;
      case PlutoLayoutContainerDirection.bottom:
      case PlutoLayoutContainerDirection.right:
        return -90;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final border = BorderSide(color: theme.dividerColor);

    final containerDirection = ref.read(layoutContainerDirectionProvider);

    final tabsRotate = _getTabsRotate(containerDirection);

    final childrenRotate = _getTabsChildrenRotate(containerDirection);

    Widget rotateOrNot(int rotate, Widget child) {
      return rotate == 0
          ? child
          : RotatedBox(quarterTurns: rotate, child: child);
    }

    Widget expandedOrNot(bool expanded, Widget child) {
      if (!expanded) return child;

      return Expanded(child: child);
    }

    final List<Widget> children = [
      rotateOrNot(
        childrenRotate,
        _Menus(
          direction: containerDirection,
          mode: mode,
          draggable: draggable,
        ),
      ),
      expandedOrNot(
        _expanded,
        rotateOrNot(
          childrenRotate,
          _TabView(
            direction: containerDirection,
            mode: mode,
            disableResize: _expanded,
            tabViewSizeResolver: tabViewSizeResolver,
          ),
        ),
      ),
    ];

    final child = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        border: Border(
          top: containerDirection.isBottom ? border : BorderSide.none,
          left: containerDirection.isRight ? border : BorderSide.none,
          right: containerDirection.isLeft ? border : BorderSide.none,
          bottom: containerDirection.isTop ? border : BorderSide.none,
        ),
      ),
      child: rotateOrNot(
        tabsRotate,
        containerDirection.isHorizontal
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: children,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
      ),
    );

    return _givenItemsProvider
        ? child
        : ProviderScope(
            overrides: [
              _itemsProvider.overrideWith((ref) => _ItemsNotifier(items)),
            ],
            child: child,
          );
  }
}

class _TabsHelper {
  static bool isEnabledTabView(PlutoLayoutTabItem e) =>
      e.enabled && e.tabViewWidget != null;

  static bool isEnabled(PlutoLayoutTabItem e) => e.enabled;

  static bool hasTabViewWidget(PlutoLayoutTabItem e) => e.tabViewWidget != null;

  static PlutoLayoutId? getFocusedLayoutId(WidgetRef ref) {
    return ref.read(focusedLayoutIdProvider);
  }

  static Object? getFocusedItemId(WidgetRef ref) =>
      ref.read(_focusedItemIdViewProvider);

  static void setFocus({
    required WidgetRef ref,
    required PlutoLayoutId? layoutId,
    required PlutoLayoutTabItem? item,
    ScrollController? scrollController,
    bool requestItemFocus = false,
  }) {
    ref.read(focusedLayoutIdProvider.notifier).state =
        layoutId ?? PlutoLayoutId.body;

    ref.read(_focusedItemIdViewProvider.notifier).state = item?.id;

    if (requestItemFocus) item?.requestFocus();

    item?._scrollMenuToVisible(scrollController);
  }

  static bool watchIsFocused({
    required WidgetRef ref,
    required Object layoutId,
    required Object itemId,
  }) {
    final focusedLayoutId = ref.watch(focusedLayoutIdProvider);

    final focusedItemId = ref.watch(_focusedItemIdViewProvider);

    return layoutId == focusedLayoutId && focusedItemId == itemId;
  }
}

/// {@template pluto_layout_tab_mode}
/// [mode] determines the operation method of the tab menu.
///
/// [PlutoLayoutTabMode.showOne]
/// {@macro pluto_lay_out_tab_mode_showOne}
///
/// [PlutoLayoutTabMode.showOneMust]
/// {@macro pluto_lay_out_tab_mode_showOneMust}
///
/// [PlutoLayoutTabMode.showSelected]
/// {@macro pluto_lay_out_tab_mode_showSelected}
/// {@endtemplate}
enum PlutoLayoutTabMode {
  /// {@template pluto_lay_out_tab_mode_showOne}
  /// shows only one tab view of the menu selected from multiple menus.
  /// {@endtemplate}
  showOne,

  /// {@template pluto_lay_out_tab_mode_showOneMust}
  /// This is a mode in which one item must be activated.
  /// {@endtemplate}
  showOneMust,

  /// {@template pluto_lay_out_tab_mode_showSelected}
  /// shows the tab view of all selected menus in multiple menus.
  /// {@endtemplate}
  showSelected;

  /// In this mode, only one item should be activated.
  bool get isShowOneMode => isShowOne || isShowOneMust;

  bool get isShowOne => this == PlutoLayoutTabMode.showOne;
  bool get isShowOneMust => this == PlutoLayoutTabMode.showOneMust;
  bool get isShowSelected => this == PlutoLayoutTabMode.showSelected;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../core/localization/l10n.dart';

/// Main scaffold with the custom five-slot bottom navigation. The centre
/// slot opens the Add Transaction form instead of switching tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int branch) {
    HapticFeedback.selectionClick();
    shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: shell,
      extendBody: false,
      bottomNavigationBar: _BottomBar(
        index: shell.currentIndex,
        onSelect: _go,
        onAdd: () {
          HapticFeedback.mediumImpact();
          context.push(Routes.newTransaction);
        },
        items: [
          _NavItem(
            Icons.space_dashboard_outlined,
            Icons.space_dashboard_rounded,
            l.navHome,
          ),
          _NavItem(Icons.insights_outlined, Icons.insights_rounded, l.navStats),
          _NavItem(
            Icons.auto_awesome_outlined,
            Icons.auto_awesome,
            l.navAssistant,
          ),
          _NavItem(
            Icons.person_outline_rounded,
            Icons.person_rounded,
            l.navProfile,
          ),
        ],
        addLabel: l.navAdd,
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.onSelect,
    required this.onAdd,
    required this.items,
    required this.addLabel,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final List<_NavItem> items;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    Widget tab(int i) => Expanded(
      child: _TabButton(
        item: items[i],
        selected: index == i,
        onTap: () => onSelect(i),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(color: palette.outline.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              tab(0),
              tab(1),
              Expanded(
                child: Center(
                  child: Semantics(
                    button: true,
                    label: addLabel,
                    child: Tooltip(
                      message: addLabel,
                      child: InkWell(
                        onTap: onAdd,
                        customBorder: const CircleBorder(),
                        child: Ink(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.colors.primary,
                                Color.lerp(
                                  context.colors.primary,
                                  palette.accent,
                                  0.55,
                                )!,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: context.colors.primary.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              tab(2),
              tab(3),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colors.primary
        : context.palette.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? context.colors.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                color: color,
                size: 23,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

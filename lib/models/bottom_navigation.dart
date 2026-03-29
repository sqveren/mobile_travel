import 'package:flutter/material.dart';

enum TravelTab { generate, plan, map }

class BottomNavigation extends StatelessWidget {
  final TravelTab activeTab;
  final Function(TravelTab) onTabChange;

  const BottomNavigation({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            children: [
              _buildNavItem(
                context,
                tab: TravelTab.generate,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Generate',
              ),
              _buildNavItem(
                context,
                tab: TravelTab.plan,
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Plan',
              ),
              _buildNavItem(
                context,
                tab: TravelTab.map,
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Map',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required TravelTab tab,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isActive = activeTab == tab;
    final Color activeColor = Theme.of(
      context,
    ).colorScheme.primary; // твій Blue-500 або Primary
    final Color inactiveColor = Theme.of(context).hintColor;

    return Expanded(
      child: InkWell(
        onTap: () => onTabChange(tab),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

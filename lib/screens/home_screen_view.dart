import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class HomeScreenView extends StatelessWidget {
  const HomeScreenView({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.daysController,
    required this.pace,
    required this.travelType,
    required this.isFormValid,
    required this.isLoadingCities,
    required this.isGenerating,
    required this.loadError,
    required this.themeMode,
    required this.locale,
    required this.onCityChanged,
    required this.onDaysChanged,
    required this.onPaceChanged,
    required this.onTravelTypeChanged,
    required this.onGeneratePressed,
    required this.onRetryLoadCities,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
  });

  final List<String> cities;
  final String? selectedCity;
  final TextEditingController daysController;
  final String pace;
  final String travelType;
  final bool isFormValid;
  final bool isLoadingCities;
  final bool isGenerating;
  final String? loadError;
  final ThemeMode themeMode;
  final Locale locale;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String> onDaysChanged;
  final ValueChanged<String> onPaceChanged;
  final ValueChanged<String> onTravelTypeChanged;
  final Future<void> Function() onGeneratePressed;
  final Future<void> Function() onRetryLoadCities;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 60,
          bottom: 120,
        ),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => _showSettingsDialog(context, l10n),
                        icon: const Icon(Icons.tune),
                        label: Text(l10n.settings),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    l10n.appSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _HomeScreenCard(
              icon: Icons.location_on,
              iconColor: colorScheme.primary,
              label: l10n.destinationCity,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoadingCities
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.loadingCities),
                          ],
                        ),
                      )
                    : loadError != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loadError!,
                              style: TextStyle(color: colorScheme.error),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => onRetryLoadCities(),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedCity,
                          hint: Text(l10n.selectCity),
                          items: cities.map((city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: onCityChanged,
                        ),
                      ),
              ),
            ),
            _HomeScreenCard(
              icon: Icons.calendar_today,
              iconColor: Colors.green,
              label: l10n.numberOfDays,
              child: TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: l10n.enterNumberOfDays,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: onDaysChanged,
              ),
            ),
            _HomeScreenCard(
              icon: Icons.bolt,
              iconColor: Colors.amber,
              label: l10n.travelPace,
              child: Column(
                children: [
                  _SelectableOptionButton(
                    value: 'calm',
                    title: l10n.paceCalm,
                    subtitle: l10n.paceCalmSubtitle,
                    currentValue: pace,
                    onTap: onPaceChanged,
                  ),
                  const SizedBox(height: 8),
                  _SelectableOptionButton(
                    value: 'standard',
                    title: l10n.paceStandard,
                    subtitle: l10n.paceStandardSubtitle,
                    currentValue: pace,
                    onTap: onPaceChanged,
                  ),
                  const SizedBox(height: 8),
                  _SelectableOptionButton(
                    value: 'active',
                    title: l10n.paceActive,
                    subtitle: l10n.paceActiveSubtitle,
                    currentValue: pace,
                    onTap: onPaceChanged,
                  ),
                ],
              ),
            ),
            _HomeScreenCard(
              icon: Icons.favorite,
              iconColor: Colors.red,
              label: l10n.travelType,
              child: Column(
                children: [
                  _SelectableOptionButton(
                    value: 'cultural',
                    title: l10n.travelTypeCultural,
                    currentValue: travelType,
                    onTap: onTravelTypeChanged,
                  ),
                  const SizedBox(height: 8),
                  _SelectableOptionButton(
                    value: 'entertainment',
                    title: l10n.travelTypeEntertainment,
                    currentValue: travelType,
                    onTap: onTravelTypeChanged,
                  ),
                  const SizedBox(height: 8),
                  _SelectableOptionButton(
                    value: 'mixed',
                    title: l10n.travelTypeMixed,
                    currentValue: travelType,
                    onTap: onTravelTypeChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: ElevatedButton(
          onPressed: isFormValid ? () => onGeneratePressed() : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isGenerating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  l10n.generatePlan,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _showSettingsDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    ThemeMode selectedThemeMode = themeMode;
    Locale selectedLocale = locale;

    return showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.settings),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.language,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<Locale>(
                    segments: [
                      ButtonSegment(
                        value: const Locale('uk'),
                        label: Text(l10n.languageUkrainian),
                      ),
                      ButtonSegment(
                        value: const Locale('en'),
                        label: Text(l10n.languageEnglish),
                      ),
                    ],
                    selected: {selectedLocale},
                    onSelectionChanged: (selection) {
                      setState(() {
                        selectedLocale = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.theme,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l10n.themeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l10n.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l10n.themeDark),
                      ),
                    ],
                    selected: {selectedThemeMode},
                    onSelectionChanged: (selection) {
                      setState(() {
                        selectedThemeMode = selection.first;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.close),
                ),
                FilledButton(
                  onPressed: () {
                    onLocaleChanged(selectedLocale);
                    onThemeModeChanged(selectedThemeMode);
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HomeScreenCard extends StatelessWidget {
  const _HomeScreenCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SelectableOptionButton extends StatelessWidget {
  const _SelectableOptionButton({
    required this.value,
    required this.title,
    required this.currentValue,
    required this.onTap,
    this.subtitle,
  });

  final String value;
  final String title;
  final String? subtitle;
  final String currentValue;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == currentValue;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onTap(value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

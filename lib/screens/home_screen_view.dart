import 'package:flutter/material.dart';

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
    required this.onCityChanged,
    required this.onDaysChanged,
    required this.onPaceChanged,
    required this.onTravelTypeChanged,
    required this.onGeneratePressed,
    required this.onRetryLoadCities,
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
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String> onDaysChanged;
  final ValueChanged<String> onPaceChanged;
  final ValueChanged<String> onTravelTypeChanged;
  final Future<void> Function() onGeneratePressed;
  final Future<void> Function() onRetryLoadCities;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Smart Travel Planner',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Create your perfect travel itinerary',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _HomeScreenCard(
              icon: Icons.location_on,
              iconColor: Colors.blue,
              label: 'Destination City',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoadingCities
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Loading cities from database...'),
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
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: onRetryLoadCities,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedCity,
                          hint: const Text('Select a city'),
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
              label: 'Number of Days',
              child: TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter number of days',
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
              label: 'Travel Pace',
              child: Column(
                children: [
                  _SelectableOptionButton(
                    value: 'calm',
                    title: 'Calm',
                    subtitle: '2 places per day',
                    currentValue: pace,
                    onTap: onPaceChanged,
                  ),
                  const SizedBox(height: 8),
                  _SelectableOptionButton(
                    value: 'standard',
                    title: 'Standard',
                    subtitle: '3 places per day',
                    currentValue: pace,
                    onTap: onPaceChanged,
                  ),
                  const SizedBox(height: 8),
                  _SelectableOptionButton(
                    value: 'active',
                    title: 'Active',
                    subtitle: '4 places per day',
                    currentValue: pace,
                    onTap: onPaceChanged,
                  ),
                ],
              ),
            ),
            _HomeScreenCard(
              icon: Icons.favorite,
              iconColor: Colors.red,
              label: 'Travel Type',
              child: Column(
                children: [
                  _SelectableOptionButton(
                    value: 'cultural',
                    title: 'Cultural',
                    currentValue: travelType,
                    onTap: onTravelTypeChanged,
                  ),
                  const SizedBox(height: 8),
                  _SelectableOptionButton(
                    value: 'entertainment',
                    title: 'Entertainment',
                    currentValue: travelType,
                    onTap: onTravelTypeChanged,
                  ),
                  const SizedBox(height: 8),
                  _SelectableOptionButton(
                    value: 'mixed',
                    title: 'Mixed',
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
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: ElevatedButton(
          onPressed: isFormValid ? onGeneratePressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
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
              : const Text(
                  'Generate Plan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
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
                style: const TextStyle(
                  fontSize: 16,
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

    return InkWell(
      onTap: () => onTap(value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
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
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

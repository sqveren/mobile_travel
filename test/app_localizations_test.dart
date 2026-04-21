import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/l10n/app_localizations.dart';
import 'package:my_app/models/travel_models.dart';

void main() {
  group('AppLocalizations', () {
    test('returns English app title for en locale', () {
      // Простий smoke-тест на базовий текст.
      final l10n = AppLocalizations(const Locale('en'));

      expect(l10n.appTitle, 'Smart Travel Planner');
    });

    test('returns localized navigation labels for English locale', () {
      // Простий набір перевірок для нижньої навігації.
      final l10n = AppLocalizations(const Locale('en'));

      expect(l10n.navGenerate(), 'Generate');
      expect(l10n.navPlan(), 'Plan');
      expect(l10n.navMap(), 'Map');
    });

    test('formats visited summary in English', () {
      // Перевіряємо динамічний рядок із числами.
      final l10n = AppLocalizations(const Locale('en'));

      expect(l10n.visitedPlacesSummary(2, 5), 'Visited 2 of 5 places');
    });

    test('formats distance strings in English', () {
      // Ще один простий динамічний текст для карти.
      final l10n = AppLocalizations(const Locale('en'));

      expect(l10n.metersAway(120), '120 m away');
      expect(l10n.kilometersAway('2.3'), '2.3 km away');
    });

    test('maps priority labels for each importance level', () {
      // Середній тест на enum -> UI label.
      final l10n = AppLocalizations(const Locale('en'));

      expect(l10n.importanceLabel(Importance.high), 'High');
      expect(l10n.importanceLabel(Importance.medium), 'Medium');
      expect(l10n.importanceLabel(Importance.low), 'Low');
    });

    test('returns translated compass direction for Ukrainian locale', () {
      // Невеликий edge case для допоміжного словника напрямків.
      final l10n = AppLocalizations(const Locale('uk'));

      expect(l10n.direction('north'), isNot('north'));
      expect(l10n.direction('unknown-direction'), 'unknown-direction');
    });
  });

  group('Travel models', () {
    test('ImportanceX exposes stable labels', () {
      // Простий unit-тест на extension, щоб не зламати відображення важливості.
      expect(Importance.high.label, 'High');
      expect(Importance.medium.label, 'Medium');
      expect(Importance.low.label, 'Low');
    });

    test('Place stores all constructor values', () {
      // Базова перевірка моделі без логіки.
      const place = Place(
        id: 'opera',
        name: 'Opera House',
        importance: Importance.high,
        category: 'Culture',
        description: 'Historic city landmark.',
        lat: 50.45,
        lng: 30.52,
      );

      expect(place.id, 'opera');
      expect(place.name, 'Opera House');
      expect(place.importance, Importance.high);
      expect(place.category, 'Culture');
      expect(place.description, 'Historic city landmark.');
      expect(place.lat, 50.45);
      expect(place.lng, 30.52);
    });

    test('DayPlan stores day number and places list', () {
      // Ще один легкий тест, але він фіксує структуру базової моделі.
      const place = Place(
        id: 'museum',
        name: 'Museum',
        importance: Importance.medium,
        category: 'Art',
        description: 'City museum',
        lat: 49.0,
        lng: 31.0,
      );
      const dayPlan = DayPlan(day: 2, places: <Place>[place]);

      expect(dayPlan.day, 2);
      expect(dayPlan.places, hasLength(1));
      expect(dayPlan.places.single.name, 'Museum');
    });
  });
}

import 'package:flutter/material.dart';

import '../models/travel_models.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context.');
    return localizations!;
  }

  bool get isUk => locale.languageCode == 'uk';

  String get appTitle =>
      isUk ? 'Розумний Планувальник Подорожей' : 'Smart Travel Planner';
  String get appSubtitle => isUk
      ? 'Створюй ідеальний маршрут для подорожі'
      : 'Create your perfect travel itinerary';
  String get settings => isUk ? 'Налаштування' : 'Settings';
  String get language => isUk ? 'Мова' : 'Language';
  String get languageEnglish => isUk ? 'Англійська' : 'English';
  String get languageUkrainian => isUk ? 'Українська' : 'Ukrainian';
  String get theme => isUk ? 'Тема' : 'Theme';
  String get themeSystem => isUk ? 'Системна' : 'System';
  String get themeLight => isUk ? 'Світла' : 'Light';
  String get themeDark => isUk ? 'Темна' : 'Dark';
  String get close => isUk ? 'Закрити' : 'Close';
  String get save => isUk ? 'Зберегти' : 'Save';
  String get destinationCity =>
      isUk ? 'Місто призначення' : 'Destination City';
  String get loadingCities => isUk
      ? 'Завантаження міст із бази даних...'
      : 'Loading cities from database...';
  String get retry => isUk ? 'Спробувати ще раз' : 'Retry';
  String get selectCity => isUk ? 'Оберіть місто' : 'Select a city';
  String get numberOfDays => isUk ? 'Кількість днів' : 'Number of Days';
  String get enterNumberOfDays =>
      isUk ? 'Введіть кількість днів' : 'Enter number of days';
  String get travelPace => isUk ? 'Темп подорожі' : 'Travel Pace';
  String get paceCalm => isUk ? 'Спокійний' : 'Calm';
  String get paceStandard => isUk ? 'Стандартний' : 'Standard';
  String get paceActive => isUk ? 'Активний' : 'Active';
  String get paceCalmSubtitle =>
      isUk ? '2 місця на день' : '2 places per day';
  String get paceStandardSubtitle =>
      isUk ? '3 місця на день' : '3 places per day';
  String get paceActiveSubtitle =>
      isUk ? '4 місця на день' : '4 places per day';
  String get travelType => isUk ? 'Тип подорожі' : 'Travel Type';
  String get travelTypeCultural => isUk ? 'Культурна' : 'Cultural';
  String get travelTypeEntertainment =>
      isUk ? 'Розважальна' : 'Entertainment';
  String get travelTypeMixed => isUk ? 'Змішана' : 'Mixed';
  String get generatePlan => isUk ? 'Створити план' : 'Generate Plan';
  String get databaseLoadError => isUk
      ? 'Не вдалося завантажити міста з PostgreSQL. Перевір host, port, database, username і password.'
      : 'Could not load cities from PostgreSQL. Check host, port, database, username, and password.';
  String get databaseGenerateError => isUk
      ? 'Не вдалося згенерувати план із PostgreSQL. Перевір типи даних і підключення до бази.'
      : 'Could not generate the plan from PostgreSQL. Check the data types and database connection.';
  String get yourTravelPlan =>
      isUk ? 'Твій план подорожі' : 'Your Travel Plan';
  String get progress => isUk ? 'Прогрес' : 'Progress';
  String visitedPlacesSummary(int visited, int total) => isUk
      ? 'Відвідано $visited із $total місць'
      : 'Visited $visited of $total places';
  String get noPlanYet => isUk
      ? 'Плану ще немає. Перейди на Generate і створи подорож.'
      : 'No plan yet. Go to Generate and create your trip.';
  String get viewOnMap => isUk ? 'Відкрити на мапі' : 'View on Map';
  String dayTitle(int day) => isUk ? 'День $day' : 'Day $day';
  String visitedShort(int visited, int total) =>
      isUk ? '$visited/$total відвідано' : '$visited/$total visited';
  String get back => isUk ? 'Назад' : 'Back';
  String get description => isUk ? 'Опис' : 'Description';
  String get location => isUk ? 'Локація' : 'Location';
  String get latitude => isUk ? 'Широта' : 'Latitude';
  String get longitude => isUk ? 'Довгота' : 'Longitude';
  String get visitStatus => isUk ? 'Статус відвідування' : 'Visit Status';
  String get placeVisited => isUk
      ? 'Ти вже відвідав це місце'
      : 'You have visited this place';
  String get placeNotVisited => isUk ? 'Ще не відвідано' : 'Not visited yet';
  String get backToPlan => isUk ? 'Повернутись до плану' : 'Back to Plan';
  String get visited => isUk ? 'Відвідано' : 'Visited';
  String get markAsVisited =>
      isUk ? 'Позначити як відвідане' : 'Mark as Visited';
  String get mapTitle => isUk ? 'Жива мапа' : 'Live Map';
  String routePointsCount(int count) => isUk
      ? '$count туристичних точок на маршруті'
      : '$count real tourist points on the route';
  String get findingLocation => isUk
      ? 'Визначаємо твоє місцезнаходження...'
      : 'Finding your current location...';
  String get retryLocation =>
      isUk ? 'Спробувати геолокацію ще раз' : 'Try location again';
  String get enableLocationServices => isUk
      ? 'Увімкни служби геолокації, щоб бачити маршрут від свого місця.'
      : 'Enable location services to see where to go from your position.';
  String get locationPermissionDenied => isUk
      ? 'Доступ до геолокації відхилено.'
      : 'Location permission was denied.';
  String get locationPermissionDeniedForever => isUk
      ? 'Доступ до геолокації назавжди вимкнений. Дозволь його в налаштуваннях системи.'
      : 'Location permission is permanently denied. Allow it in system settings.';
  String get locationLoadError => isUk
      ? 'Не вдалося отримати поточне місцезнаходження.'
      : 'Could not load your current location.';
  String get mapEmptyState => isUk
      ? 'Спочатку створи план, щоб побачити туристичні точки на мапі.'
      : 'Generate a plan first to see real tourist points on the map.';
  String get highPriority => isUk ? 'Високий пріоритет' : 'High priority';
  String get mediumPriority => isUk ? 'Середній пріоритет' : 'Medium priority';
  String get lowPriority => isUk ? 'Низький пріоритет' : 'Low priority';
  String get visitedLegend => isUk ? 'Відвідано' : 'Visited';
  String get lineFromYou => isUk ? 'Лінія від тебе' : 'Line from you';
  String get viewDetails => isUk ? 'Детальніше' : 'View Details';
  String metersAway(int meters) =>
      isUk ? '$meters м від тебе' : '$meters m away';
  String kilometersAway(String km) =>
      isUk ? '$km км від тебе' : '$km km away';
  String navGenerate() => isUk ? 'Створити' : 'Generate';
  String navPlan() => isUk ? 'План' : 'Plan';
  String navMap() => isUk ? 'Мапа' : 'Map';

  String importanceLabel(Importance importance) {
    switch (importance) {
      case Importance.high:
        return isUk ? 'Високий' : 'High';
      case Importance.medium:
        return isUk ? 'Середній' : 'Medium';
      case Importance.low:
        return isUk ? 'Низький' : 'Low';
    }
  }

  String priorityLabel(Importance importance) =>
      '${importanceLabel(importance)} ${isUk ? 'пріоритет' : 'Priority'}';

  String direction(String key) {
    if (!isUk) {
      return key;
    }

    switch (key) {
      case 'north':
        return 'північ';
      case 'north-east':
        return 'північний схід';
      case 'east':
        return 'схід';
      case 'south-east':
        return 'південний схід';
      case 'south':
        return 'південь';
      case 'south-west':
        return 'південний захід';
      case 'west':
        return 'захід';
      case 'north-west':
        return 'північний захід';
      default:
        return key;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

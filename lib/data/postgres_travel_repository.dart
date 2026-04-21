import 'package:postgres/postgres.dart';

import '../models/travel_models.dart';
import 'postgres_config.dart';
import 'travel_repository.dart';

class PostgresTravelRepository implements TravelRepository {
  Future<Connection> _openConnection() {
    return Connection.open(
      Endpoint(
        host: PostgresConfig.host,
        port: PostgresConfig.port,
        database: PostgresConfig.database,
        username: PostgresConfig.username,
        password: PostgresConfig.password,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  @override
  Future<List<String>> fetchCities() async {
    final connection = await _openConnection();
    try {
      final result = await connection.execute(
        Sql.named('SELECT full_name FROM cities ORDER BY full_name'),
      );

      return result.map((row) => row[0] as String).toList(growable: false);
    } finally {
      await connection.close();
    }
  }

  @override
  Future<List<Place>> fetchPlacesForCity(String city) async {
    final connection = await _openConnection();
    try {
      final escapedCity = _escapeSqlLiteral(city);
      final result = await connection.execute(
        Sql.named('''
          SELECT tp.id, tp.name, tp.importance, tp.category, tp.description, tp.lat, tp.lng
          FROM tourist_places tp
          JOIN cities c ON c.id = tp.city_id
          WHERE c.full_name = '$escapedCity'
          ORDER BY
            CASE tp.importance
              WHEN 'high' THEN 1
              WHEN 'medium' THEN 2
              ELSE 3
            END,
            tp.name
        '''),
      );

      return result.map(_mapPlace).toList(growable: false);
    } finally {
      await connection.close();
    }
  }

  Place _mapPlace(ResultRow row) {
    return Place(
      id: row[0] as String,
      name: row[1] as String,
      importance: _parseImportance(row[2] as String),
      category: row[3] as String,
      description: row[4] as String,
      lat: _toDouble(row[5]),
      lng: _toDouble(row[6]),
    );
  }

  Importance _parseImportance(String value) {
    switch (value) {
      case 'high':
        return Importance.high;
      case 'medium':
        return Importance.medium;
      case 'low':
        return Importance.low;
      default:
        throw StateError('Unsupported importance value: $value');
    }
  }

  String _escapeSqlLiteral(String value) => value.replaceAll("'", "''");

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.parse(value);
    }
    throw StateError('Unsupported coordinate value: $value');
  }
}

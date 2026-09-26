import 'dart:convert';
import 'dart:io';

/// A complete, usable nutrition record from Open Food Facts.
class OpenFoodFactsProduct {
  const OpenFoodFactsProduct({
    required this.code,
    required this.name,
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    this.brand,
    this.category = 'other',
  });

  final String code;
  final String name;
  final String? brand;
  final String category;
  // Search-a-licious _100g values describe 100 grams, never 100 milliliters.
  final double energyKcal;
  final double proteinG;
  final double fatG;
  final double carbsG;

  String get id => 'off:$code';

  static OpenFoodFactsProduct? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final code = raw['code'];
    final name = raw['product_name'];
    final facts = raw['nutriments'];
    if (code is! String ||
        !RegExp(r'^\d{3,30}$').hasMatch(code) ||
        name is! String ||
        name.trim().isEmpty ||
        facts is! Map<String, dynamic> ||
        raw['no_nutrition_data'] == 'on') {
      return null;
    }
    final kcal = _nonNegative(facts['energy-kcal_100g']);
    final protein = _nonNegative(facts['proteins_100g']);
    final fat = _nonNegative(facts['fat_100g']);
    final carbs = _nonNegative(facts['carbohydrates_100g']);
    if (kcal == null || protein == null || fat == null || carbs == null) {
      return null;
    }
    // OFF may infer _100g from a serving in ml without a known density.
    // For per-serving labels, require an explicitly mass-based serving.
    if (raw['nutrition_data_per'] == 'serving' &&
        raw['serving_quantity_unit'] != 'g') {
      return null;
    }
    if (raw['nutrition_data_per'] is String &&
        raw['nutrition_data_per'] != 'serving' &&
        raw['nutrition_data_per'] != '100g') {
      return null;
    }
    final brand = switch (raw['brands']) {
      String value => value.trim(),
      List<dynamic> values => values.whereType<String>().join(', ').trim(),
      _ => '',
    };
    final tags = raw['categories_tags'];
    final category = tags is List
        ? _categoryFor(tags.whereType<String>().toSet())
        : 'other';
    return OpenFoodFactsProduct(
      code: code,
      name: name.trim(),
      brand: brand.isEmpty ? null : brand,
      category: category,
      energyKcal: kcal,
      proteinG: protein,
      fatG: fat,
      carbsG: carbs,
    );
  }
}

double? _nonNegative(Object? value) {
  if (value is! num) return null;
  final number = value.toDouble();
  return number.isFinite && number >= 0 ? number : null;
}

String _categoryFor(Set<String> tags) {
  if (tags.contains('en:beverages')) return 'drinks';
  if (tags.contains('en:dairies')) return 'dairy';
  if (tags.contains('en:fruits')) return 'fruit';
  if (tags.contains('en:cereals-and-their-products')) return 'grains';
  if (tags.contains('en:breads')) return 'bread';
  if (tags.contains('en:eggs')) return 'eggs';
  return 'other';
}

List<OpenFoodFactsProduct> parseOpenFoodFactsSearch(Object? body) {
  if (body is! Map<String, dynamic> || body['hits'] is! List) {
    throw const FormatException('Invalid Open Food Facts search response');
  }
  if (body['errors'] != null || body['timed_out'] == true) {
    throw const FormatException('Open Food Facts search failed');
  }
  final found = <String, OpenFoodFactsProduct>{};
  for (final hit in body['hits'] as List<dynamic>) {
    final food = OpenFoodFactsProduct.fromJson(hit);
    if (food != null) found.putIfAbsent(food.code, () => food);
  }
  return List.unmodifiable(found.values);
}

abstract interface class OpenFoodFactsSearchClient {
  Future<List<OpenFoodFactsProduct>> search(String query, String language);
}

class OpenFoodFactsHttpClient implements OpenFoodFactsSearchClient {
  OpenFoodFactsHttpClient({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;
  Future<void> _previousRequest = Future.value();
  DateTime? _lastSent;

  static const _interval = Duration(seconds: 6);
  static const _timeout = Duration(seconds: 10);
  static const _fields =
      'code,product_name,brands,categories_tags,nutriments,'
      'nutrition_data_per,no_nutrition_data,serving_quantity_unit';

  @override
  Future<List<OpenFoodFactsProduct>> search(
    String query,
    String language,
  ) async {
    // Queue requests on this client to stay within the OFF search limit.
    final turn = _previousRequest.then((_) async {
      final elapsed = DateTime.now().difference(_lastSent ?? DateTime(1970));
      if (elapsed < _interval) await Future<void>.delayed(_interval - elapsed);
      _lastSent = DateTime.now();
    });
    _previousRequest = turn;
    await turn;
    final uri = Uri.https('search.openfoodfacts.org', '/search', {
      'q': query,
      'langs': language == 'en' ? 'en' : '$language,en',
      'page_size': '15',
      'page': '1',
      'fields': _fields,
    });
    final request = await _httpClient.getUrl(uri).timeout(_timeout);
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'YAM/0.1.0 (https://github.com/0x0FACED/yam)',
    );
    final response = await request.close().timeout(_timeout);
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw HttpException('Open Food Facts: ${response.statusCode}', uri: uri);
    }
    final text = await utf8.decoder.bind(response).join().timeout(_timeout);
    return parseOpenFoodFactsSearch(jsonDecode(text));
  }

  void close() => _httpClient.close(force: true);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/properties_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchState {
  final bool isLoading;
  final List<PropertyEntity> results;
  final String? error;
  final List<String> recentSearches;

  const SearchState({
    this.isLoading = false,
    this.results = const [],
    this.error,
    this.recentSearches = const [],
  });

  SearchState copyWith({
    bool? isLoading,
    List<PropertyEntity>? results,
    String? error,
    List<String>? recentSearches,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error ?? this.error,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  static const String _recentSearchesKey = 'recent_searches';

  @override
  SearchState build() {
    _loadRecentSearches();
    return const SearchState();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(_recentSearchesKey) ?? [];
    state = state.copyWith(recentSearches: recent);
  }

  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final current = List<String>.from(state.recentSearches);

    // Remove if exists to move to top
    current.remove(query);
    // Add to top
    current.insert(0, query);
    // Limit to 10
    if (current.length > 10) {
      current.removeLast();
    }

    await prefs.setStringList(_recentSearchesKey, current);
    state = state.copyWith(recentSearches: current);
  }

  Future<void> removeRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final current = List<String>.from(state.recentSearches);
    current.remove(query);
    await prefs.setStringList(_recentSearchesKey, current);
    state = state.copyWith(recentSearches: current);
  }

  Future<void> search({String? query, PropertyType? type}) async {
    if ((query == null || query.isEmpty) && type == null) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final repository = ref.read(propertyRepositoryProvider);
    final result = await repository.searchProperties(query: query, type: type);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (properties) =>
          state = state.copyWith(isLoading: false, results: properties),
    );
  }

  void clearResults() {
    state = state.copyWith(results: []);
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});

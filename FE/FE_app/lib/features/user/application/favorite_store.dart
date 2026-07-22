import 'package:flutter/foundation.dart';

import '../../recipe/data/recipe_repository.dart';
import '../data/user_repository.dart';

class FavoriteStore extends ChangeNotifier {
  FavoriteStore({
    required UserRepository userRepository,
    required RecipeRepository recipeRepository,
  }) : _userRepository = userRepository,
       _recipeRepository = recipeRepository;

  final UserRepository _userRepository;
  final RecipeRepository _recipeRepository;

  final Map<int, int> _favoriteIdsByRecipe = {};
  final Set<int> _pendingRecipeIds = {};
  Future<void>? _loadOperation;
  bool _loaded = false;
  String? _errorMessage;

  RecipeRepository get recipeRepository => _recipeRepository;
  Set<int> get recipeIds => _favoriteIdsByRecipe.keys.toSet();
  bool get isLoading => _loadOperation != null;
  String? get errorMessage => _errorMessage;

  bool isFavorite(int recipeId) => _favoriteIdsByRecipe.containsKey(recipeId);
  bool isPending(int recipeId) => _pendingRecipeIds.contains(recipeId);

  Future<void> load({bool force = false}) {
    if (_loadOperation != null) return _loadOperation!;
    if (_loaded && !force) return Future.value();

    final operation = _loadFavorites();
    _loadOperation = operation;
    notifyListeners();
    return operation.whenComplete(() {
      _loadOperation = null;
      notifyListeners();
    });
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _userRepository.getFavorites();
      _favoriteIdsByRecipe
        ..clear()
        ..addEntries(
          favorites.map((item) {
            final recipeId = (item['recipeId'] as num).toInt();
            final favoriteId = (item['favoriteId'] as num).toInt();
            return MapEntry(recipeId, favoriteId);
          }),
        );
      _loaded = true;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    }
  }

  Future<void> toggle(int recipeId) async {
    if (_pendingRecipeIds.contains(recipeId)) return;
    await load();

    _pendingRecipeIds.add(recipeId);
    _errorMessage = null;
    notifyListeners();
    try {
      final favoriteId = _favoriteIdsByRecipe[recipeId];
      if (favoriteId == null) {
        final favorite = await _userRepository.addFavorite(
          recipeId: recipeId,
        );
        _favoriteIdsByRecipe[recipeId] = (favorite['favoriteId'] as num)
            .toInt();
      } else {
        await _userRepository.deleteFavorite(
          favoriteId: favoriteId,
        );
        _favoriteIdsByRecipe.remove(recipeId);
      }
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _pendingRecipeIds.remove(recipeId);
      notifyListeners();
    }
  }

  void clear() {
    _loaded = false;
    _errorMessage = null;
    _favoriteIdsByRecipe.clear();
    _pendingRecipeIds.clear();
    notifyListeners();
  }
}

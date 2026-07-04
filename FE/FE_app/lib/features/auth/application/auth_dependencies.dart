import '../../../core/network/auth_api_client.dart';
import '../../../core/storage/auth_session_storage.dart';
import '../../recipe/data/recipe_repository.dart';
import '../../user/data/user_repository.dart';
import '../data/auth_repository.dart';

class AuthDependencies {
  AuthDependencies._();

  static final AuthDependencies instance = AuthDependencies._();

  late final AuthSessionStorage sessionStorage = AuthSessionStorage();
  late final AuthApiClient apiClient = AuthApiClient(
    sessionStorage: sessionStorage,
  );
  late final AuthRepository repository = AuthRepository(
    apiClient: apiClient,
    sessionStorage: sessionStorage,
  );
  late final UserRepository userRepository = UserRepository(
    apiClient: apiClient,
  );
  late final RecipeRepository recipeRepository = RecipeRepository(
    apiClient: apiClient,
  );
}

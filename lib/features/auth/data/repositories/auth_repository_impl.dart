
import '../../data/datasource/auth_remote_datasource.dart';
import '../../domain/entities/user.dart' as app;
import '../../domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  // Mengubah Supabase User menjadi User Entity kita
  app.User? _convertSupabaseUser(supabase.User? user) {
    if (user == null) return null;
    return app.User(id: user.id, email: user.email ?? '');
  }

  @override
  app.User? get currentUser => _convertSupabaseUser(_dataSource.currentUser);

  @override
  Stream<app.User?> get onAuthStateChange {
    return _dataSource.onAuthStateChange.map((authState) {
      return _convertSupabaseUser(authState.session?.user);
    });
  }

  @override
  Future<void> signInWithEmailPassword(String email, String password) {
    return _dataSource.signInWithEmailPassword(email, password);
  }

  @override
  Future<void> signUpWithEmailPassword(String email, String password) {
    return _dataSource.signUpWithEmailPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }
}
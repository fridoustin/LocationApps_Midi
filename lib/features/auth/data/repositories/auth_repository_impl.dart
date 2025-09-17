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
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      await _dataSource.signInWithEmailPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signUpWithEmailPassword(String email, String password) {
    return _dataSource.signUpWithEmailPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<bool> isUserAuthorized(String userId) async {
    try {
      const allowedPositionId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
      final response = await _dataSource.client
          .from('users')
          .select('position_id')
          .eq('id', userId)
          .single();
      
      final userPositionId = response['position_id'];
      final isAllowed = userPositionId == allowedPositionId;
      return isAllowed;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _dataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> updateUserPassword(String newPassword) {
    return _dataSource.updateUserPassword(newPassword);
  }
}
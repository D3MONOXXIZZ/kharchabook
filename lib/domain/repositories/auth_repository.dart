import '../models/user_profile.dart';

/// Abstract contract for authentication and student profile operations.
abstract class AuthRepository {
  Future<UserProfile?> getCurrentUser();
  Future<UserProfile> signIn({required String email, required String password});
  Future<UserProfile> signUp({required String name, required String email, required String password});
  Future<void> signOut();
  Future<UserProfile> updateMonthlyBudget(double newBudget);
  Future<UserProfile> updateProfile({required String name});
  Stream<UserProfile?> get authStateChanges;
}

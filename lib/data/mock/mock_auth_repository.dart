import 'dart:async';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

/// In-memory mock authentication repository for instant local development and UI testing.
class MockAuthRepository implements AuthRepository {
  UserProfile? _currentUser;

  final StreamController<UserProfile?> _authStreamController =
      StreamController<UserProfile?>.broadcast();

  @override
  Stream<UserProfile?> get authStateChanges => _authStreamController.stream;

  @override
  Future<UserProfile?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentUser;
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid student email address.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    _currentUser = UserProfile(
      id: 'user_bahria_001',
      name: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
      email: email.trim(),
      monthlyBudget: 15000.0,
      updatedAt: DateTime.now(),
    );
    _authStreamController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (name.trim().isEmpty) {
      throw Exception('Please enter your full name.');
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }

    _currentUser = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      monthlyBudget: 15000.0,
      updatedAt: DateTime.now(),
    );
    _authStreamController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentUser = null;
    _authStreamController.add(null);
  }

  @override
  Future<UserProfile> updateMonthlyBudget(double newBudget) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (_currentUser == null) throw Exception('No authenticated user');
    if (newBudget <= 0) throw Exception('Budget must be greater than zero.');

    _currentUser = _currentUser!.copyWith(
      monthlyBudget: newBudget,
      updatedAt: DateTime.now(),
    );
    _authStreamController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserProfile> updateProfile({required String name}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (_currentUser == null) throw Exception('No authenticated user');
    _currentUser = _currentUser!.copyWith(
      name: name.trim(),
      updatedAt: DateTime.now(),
    );
    _authStreamController.add(_currentUser);
    return _currentUser!;
  }
}

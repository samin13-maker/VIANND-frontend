import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userId = prefs.getInt('userId');
    final userName = prefs.getString('userName');
    final userEmail = prefs.getString('userEmail');
    if (_token != null && userId != null) {
      _user = UserModel(id: userId, name: userName ?? '', email: userEmail ?? '');
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _authService.login(email, password);
      if (data['token'] != null) {
        _token = data['token'];
        _user = UserModel.fromJson(data['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setInt('userId', _user!.id);
        await prefs.setString('userName', _user!.name);
        await prefs.setString('userEmail', _user!.email);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = data['message'] ?? 'Error al iniciar sesión';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, int age, String gender) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _authService.register(name, email, password, age, gender);
      if (data['token'] != null) {
        _token = data['token'];
        _user = UserModel.fromJson(data['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setInt('userId', _user!.id);
        await prefs.setString('userName', _user!.name);
        await prefs.setString('userEmail', _user!.email);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = data['message'] ?? 'Error al registrarse';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
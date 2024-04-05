import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class IdentityManager {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;
  String? _username;
  String? _userId;
  String? _email;

  static final IdentityManager _instance = IdentityManager._();

  factory IdentityManager() {
    return _instance;
  }

  IdentityManager._();

  Future<void> initFromStorage() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
    _username = await _storage.read(key: 'username');
    _userId = await _storage.read(key: 'id');
    _email = await _storage.read(key: 'email');
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get username => _username;
  String? get userId => _userId;
  String? get email => _email;

  set accessToken(String? accessToken) {
    _accessToken = accessToken;
    _storage.write(key: 'access_token', value: accessToken);
  }
  set refreshToken(String? refreshToken) {
    _refreshToken = refreshToken;
    _storage.write(key: 'refresh_token', value: refreshToken);
  }
  set username(String? username) {
    _username = username;
    _storage.write(key: 'username', value: username);
  }
  set userId(String? userId) {
    _userId = userId;
    _storage.write(key: 'id', value: userId);
  }
  set email(String? email) {
    _email = email;
    _storage.write(key: 'email', value: email);
  }

  Future<void> clearUserData() async {
    _accessToken = null;
    _refreshToken = null;
    _username = null;
    _userId = null;
    _email = null;
    await _storage.deleteAll();
  }
}

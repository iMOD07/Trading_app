import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../main.dart';
import '../features/login/ui/login_screen.dart';
import 'auth_service.dart';

class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  ApiService._() {
    _setupInterceptors();
  }

  static void resetInstance() {
    _instance = null;
  }

  // live server
  static const String _base = 'http://157.241.33.98:8080';
  // Test
  //static const String _base = 'http://192.168.1.100:8080';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _base,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService.getToken();
        print('Token: $token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await AuthService.clear();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
          handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: 'UNAUTHORIZED',
            response: error.response,
          ));
          return;
        }
        handler.next(error);
      },
    ));
  }

  // ── Auth ──────────────────────────────────────────────
  Future<Map<String, dynamic>> login(LoginRequest req) async {
    final res = await _dio.post('/api/auth/login', data: req.toJson());
    print('Login response: ${res.data}');
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> register(RegisterRequest req) async {
    await _dio.post('/api/auth/register', data: req.toJson());
  }

  Future<void> updateProfile(RegisterRequest req) async {
    await _dio.post('/api/auth/update', data: req.toJson());
  }

  // ── Trade ─────────────────────────────────────────────
  Future<Map<String, dynamic>> sendOrder(OrderRequest req) async {
    final res = await _dio.post('/api/trade/order', data: req.toJson());
    if (kDebugMode) {
      print('Order response: ${res.data}');
    }
    return res.data is Map
        ? Map<String, dynamic>.from(res.data)
        : {'response': res.data.toString()};
  }

  Future<Account> getAccount() async {
    final res = await _dio.get('/api/trade/account');
    print('Account response: ${res.data}');
    return Account.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<List<TradeOrder>> getOrders() async {
    final res = await _dio.get('/api/trade/orders');
    return (res.data as List)
        .map((e) => TradeOrder.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> cancelOrder(String alpacaOrderId) async {
    await _dio.delete('/api/trade/orders/$alpacaOrderId');
  }

  Future<List<TradeOrder>> getLastOrders() async {
    final res = await _dio.get('/api/trade/orders/last');
    final data = res.data;
    if (data is List) {
      return data
          .map((e) => TradeOrder.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [TradeOrder.fromJson(Map<String, dynamic>.from(data))];
  }

  // ── Settings ──────────────────────────────────────────
  Future<AppSettings> getSettings() async {
    final res = await _dio.get('/api/settings');
    return AppSettings.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _dio.post('/api/settings', data: settings.toJson());
  }

  // ── Admin ─────────────────────────────────────────────
  Future<List<AppUser>> getUsers() async {
    final res = await _dio.get('/api/admin/users');
    return (res.data as List)
        .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> activateUser(int id) async {
    await _dio.post('/api/admin/users/$id/activate');
  }

  Future<void> deactivateUser(int id) async {
    await _dio.post('/api/admin/users/$id/deactivate');
  }

  Future<void> changeRole(int id, String role) async {
    await _dio.post('/api/admin/users/$id/role', data: {'role': role});
  }
}

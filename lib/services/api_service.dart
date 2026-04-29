import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../main.dart';
import '../features/login/ui/login_screen.dart';
import 'auth_service.dart';

class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    _setupInterceptors();
  }

  static void resetInstance() => _instance = null;

  // Default — can be overridden via setServerHost()
  static String _baseUrl = 'http://98.85.235.215:8080';

  late final Dio _dio;

  /// Call once in main() before runApp — loads saved host from SharedPreferences
  static Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString('server_host');
    if (saved != null && saved.isNotEmpty) _baseUrl = saved;
  }

  /// Persist new server host and force singleton rebuild
  static Future<void> setServerHost(String host) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('server_host', host);
    _baseUrl = host;
    resetInstance();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          debugPrint('➡️ ${options.method} ${options.uri}');
          if (options.data != null) debugPrint('📦 ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('✅ ${response.statusCode} ${response.requestOptions.uri}');
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          debugPrint(
              '❌ ${error.response?.statusCode} ${error.requestOptions.uri}');
          if (error.response?.data != null)
            debugPrint('📦 ${error.response?.data}');
        }
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

  // ═══════════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════════
  Future<Map<String, dynamic>> login(LoginRequest req) async {
    final res = await _dio.post('/api/auth/login', data: req.toJson());
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> register(RegisterRequest req) async {
    final res = await _dio.post('/api/auth/register', data: req.toJson());
    return Map<String, dynamic>.from(res.data);
  }

  // ═══════════════════════════════════════════════
  // TRADE
  // ═══════════════════════════════════════════════
  Future<Map<String, dynamic>> sendOrder(OrderRequest req) async {
    final res = await _dio.post('/api/trade/order', data: req.toJson());
    return res.data is Map
        ? Map<String, dynamic>.from(res.data)
        : {'response': res.data.toString()};
  }

  /// IMPORTANT: backend expects DB id (Long), NOT ibkrOrderId.
  /// Endpoint: DELETE /api/trade/order/{id}  (singular "order")
  Future<void> cancelOrder(int dbOrderId) async {
    await _dio.delete('/api/trade/order/$dbOrderId');
  }

  Future<List<TradeOrder>> getOrders() async {
    final res = await _dio.get('/api/trade/orders');
    return (res.data as List)
        .map((e) => TradeOrder.fromJson(Map<String, dynamic>.from(e)))
        .toList();
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

  Future<List<TradeOrder>> getOrdersBySymbol(String symbol) async {
    final res = await _dio.get('/api/trade/orders/symbol/$symbol');
    return (res.data as List)
        .map((e) => TradeOrder.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Diagnostic — checks if user's IB Gateway is reachable
  Future<Map<String, dynamic>> testConnection() async {
    final res = await _dio.get('/api/trade/connection');
    return Map<String, dynamic>.from(res.data);
  }

  // ═══════════════════════════════════════════════
  // SETTINGS
  // ═══════════════════════════════════════════════
  Future<AppSettings> getSettings() async {
    final res = await _dio.get('/api/settings');
    return AppSettings.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _dio.post('/api/settings', data: settings.toJson());
  }

  // ═══════════════════════════════════════════════
  // ADMIN
  // ═══════════════════════════════════════════════
  Future<List<AppUser>> getUsers() async {
    final res = await _dio.get('/api/admin/users');
    return (res.data as List)
        .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<AppUser> getUser(int id) async {
    final res = await _dio.get('/api/admin/users/$id');
    return AppUser.fromJson(Map<String, dynamic>.from(res.data));
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

  Future<void> configureIbkr(int id, IbkrConfigRequest config) async {
    await _dio.post('/api/admin/users/$id/ibkr-config', data: config.toJson());
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete('/api/admin/users/$id');
  }

  Future<int> getActiveConnectionCount() async {
    final res = await _dio.get('/api/admin/connections/active');
    final data = Map<String, dynamic>.from(res.data);
    final v = data['activeConnections'];
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

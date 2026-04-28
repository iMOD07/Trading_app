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
    _setupInterceptors();
  }

  static void resetInstance() => _instance = null;

  // Production
  static String _baseUrl = 'http://172.20.10.2:8080';
  // Test
  //static String _baseUrl = 'http://localhost:8080';

  /// Call once in main() before runApp — loads saved host from SharedPreferences
  static Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString('server_host');
    if (saved != null && saved.isNotEmpty) _baseUrl = saved;
  }

  /// Called after admin registers/updates a server — persists and reloads
  static Future<void> setServerHost(String host) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('server_host', host);
    _baseUrl = host;
    resetInstance();
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode) {
          print('═══════════════ REQUEST ═══════════════');
          print('➡️ ${options.method} ${options.uri}');
          print('📋 Headers: ${options.headers}');
          if (options.data != null) {
            print('📦 Body: ${options.data}');
          }
          if (options.queryParameters.isNotEmpty) {
            print('🔍 Query: ${options.queryParameters}');
          }
          print('═══════════════════════════════════════');
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('═══════════════ RESPONSE ══════════════');
          print(
              '✅ ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
          print('📦 Data: ${response.data}');
          print('═══════════════════════════════════════');
        }

        handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          print('═══════════════ ERROR ═════════════════');
          print(
              '❌ ${error.response?.statusCode} ${error.requestOptions.method} ${error.requestOptions.uri}');
          print('💬 Message: ${error.message}');
          if (error.response?.data != null) {
            print('📦 Error Data: ${error.response?.data}');
          }
          print('═══════════════════════════════════════');
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

  // ── Auth ──────────────────────────────────────────────
  Future<Map<String, dynamic>> login(LoginRequest req) async {
    final res = await _dio.post('/api/auth/login', data: req.toJson());
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
    return res.data is Map
        ? Map<String, dynamic>.from(res.data)
        : {'response': res.data.toString()};
  }

  Future<Account> getAccount() async {
    final res = await _dio.get('/api/trade/account');
    return Account.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<List<TradeOrder>> getOrders() async {
    final res = await _dio.get('/api/trade/orders');
    return (res.data as List)
        .map((e) => TradeOrder.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> cancelOrder(String ibkrOrderId) async {
    await _dio.delete('/api/trade/orders/$ibkrOrderId');
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

  // ── Server Information ────────────────────────────────────────
  Future<List<ServerInformation>> getServers() async {
    final res = await _dio.get('/api/server');
    return (res.data as List)
        .map((e) => ServerInformation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ServerInformation> getServer(String serverName) async {
    final res = await _dio.get('/api/server/$serverName');
    return ServerInformation.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> registerServer(ServerInformation server) async {
    await _dio.post('/api/server/register', data: server.toJson());
  }

  Future<void> updateServer(ServerInformation server) async {
    await _dio.put('/api/server/update', data: server.toJson());
  }

  Future<void> deleteServer(ServerInformation server) async {
    await _dio.delete('/api/server/delete', data: server.toJson());
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

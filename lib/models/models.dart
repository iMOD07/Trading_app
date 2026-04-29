// ═══════════════════════════════════════════════
// AUTH
// ═══════════════════════════════════════════════
class LoginRequest {
  final String username;
  final String password;
  LoginRequest({required this.username, required this.password});
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class RegisterRequest {
  final String username;
  final String password;
  RegisterRequest({required this.username, required this.password});
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

// ═══════════════════════════════════════════════
// TRADE
// Matches backend TradeRequest.java (3 fields)
// ═══════════════════════════════════════════════
class OrderRequest {
  final String symbol;
  final double entryPrice;
  final double stopLoss;
  OrderRequest({
    required this.symbol,
    required this.entryPrice,
    required this.stopLoss,
  });
  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'entryPrice': entryPrice,
        'stopLoss': stopLoss,
      };
}

// ═══════════════════════════════════════════════
// SETTINGS
// Matches backend SettingsRequest.java
// ═══════════════════════════════════════════════
class AppSettings {
  final double tradeAmount;
  final double rangeValue;
  final double profitPercent;

  AppSettings({
    required this.tradeAmount,
    required this.rangeValue,
    required this.profitPercent,
  });

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        tradeAmount: _d(j['tradeAmount']),
        rangeValue: _d(j['rangeValue']),
        profitPercent: _d(j['profitPercent']),
      );

  Map<String, dynamic> toJson() => {
        'tradeAmount': tradeAmount,
        'rangeValue': rangeValue,
        'profitPercent': profitPercent,
      };

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

// ═══════════════════════════════════════════════
// TRADE ORDER (history)
// Matches backend TradeOrder entity exactly
// ═══════════════════════════════════════════════
class TradeOrder {
  final int? id; // DB id - used for cancel
  final String symbol;
  final int? qty;
  final double? entryPrice;
  final double? tradeAmount;
  final double? profitPercent;
  final double? stopPrice;
  final double? limitPrice;
  final double? takeProfit;
  final double? stopLoss;
  final int? ibkrParentOrderId;
  final int? ibkrTakeProfitOrderId;
  final int? ibkrStopLossOrderId;
  final int? ibkrPermId;
  final String? orderStatus;
  final String? clientOrderId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TradeOrder({
    this.id,
    required this.symbol,
    this.qty,
    this.entryPrice,
    this.tradeAmount,
    this.profitPercent,
    this.stopPrice,
    this.limitPrice,
    this.takeProfit,
    this.stopLoss,
    this.ibkrParentOrderId,
    this.ibkrTakeProfitOrderId,
    this.ibkrStopLossOrderId,
    this.ibkrPermId,
    this.orderStatus,
    this.clientOrderId,
    this.createdAt,
    this.updatedAt,
  });

  /// Backend statuses: PENDING, SUBMITTED, FILLED, CANCELLED, REJECTED
  bool get isCancellable {
    final s = orderStatus?.toUpperCase();
    return s == 'PENDING' || s == 'SUBMITTED' || s == 'PRESUBMITTED';
  }

  factory TradeOrder.fromJson(Map<String, dynamic> j) => TradeOrder(
        id: _i(j['id']),
        symbol: (j['symbol'] ?? '').toString(),
        qty: _i(j['qty']),
        entryPrice: _d(j['entryPrice']),
        tradeAmount: _d(j['tradeAmount']),
        profitPercent: _d(j['profitPercent']),
        stopPrice: _d(j['stopPrice']),
        limitPrice: _d(j['limitPrice']),
        takeProfit: _d(j['takeProfit']),
        stopLoss: _d(j['stopLoss']),
        ibkrParentOrderId: _i(j['ibkrParentOrderId']),
        ibkrTakeProfitOrderId: _i(j['ibkrTakeProfitOrderId']),
        ibkrStopLossOrderId: _i(j['ibkrStopLossOrderId']),
        ibkrPermId: _i(j['ibkrPermId']),
        orderStatus: j['orderStatus']?.toString(),
        clientOrderId: j['clientOrderId']?.toString(),
        createdAt: _date(j['createdAt']),
        updatedAt: _date(j['updatedAt']),
      );

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _i(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

// ═══════════════════════════════════════════════
// USER (admin views)
// Matches backend User entity (with IBKR fields)
// ═══════════════════════════════════════════════
class AppUser {
  final int id;
  final String username;
  final String role;
  final bool active;
  final String? ibkrHost;
  final int? ibkrPort;
  final int? ibkrClientId;
  final String? ibkrAccountId;
  final bool ibkrPaperTrading;
  final double? tradeAmount;
  final double? rangeValue;
  final double? profitPercent;

  AppUser({
    required this.id,
    required this.username,
    required this.role,
    required this.active,
    this.ibkrHost,
    this.ibkrPort,
    this.ibkrClientId,
    this.ibkrAccountId,
    this.ibkrPaperTrading = true,
    this.tradeAmount,
    this.rangeValue,
    this.profitPercent,
  });

  bool get isIbkrConfigured =>
      ibkrHost != null &&
      ibkrHost!.isNotEmpty &&
      ibkrPort != null &&
      ibkrAccountId != null &&
      ibkrAccountId!.isNotEmpty;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: _i(j['id']) ?? 0,
        username: (j['username'] ?? '').toString(),
        role: (j['role'] ?? 'USER').toString(),
        active: j['active'] == true || j['active'] == 1,
        ibkrHost: j['ibkrHost']?.toString(),
        ibkrPort: _i(j['ibkrPort']),
        ibkrClientId: _i(j['ibkrClientId']),
        ibkrAccountId: j['ibkrAccountId']?.toString(),
        ibkrPaperTrading:
            j['ibkrPaperTrading'] == true || j['ibkrPaperTrading'] == 1,
        tradeAmount: _d(j['tradeAmount']),
        rangeValue: _d(j['rangeValue']),
        profitPercent: _d(j['profitPercent']),
      );

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _i(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}

// ═══════════════════════════════════════════════
// IBKR CONFIG (admin)
// Matches backend IbkrConfigRequest.java
// ═══════════════════════════════════════════════
class IbkrConfigRequest {
  final String ibkrHost;
  final int ibkrPort;
  final int ibkrClientId;
  final String ibkrAccountId;
  final bool ibkrPaperTrading;

  IbkrConfigRequest({
    required this.ibkrHost,
    required this.ibkrPort,
    required this.ibkrClientId,
    required this.ibkrAccountId,
    required this.ibkrPaperTrading,
  });

  Map<String, dynamic> toJson() => {
        'ibkrHost': ibkrHost,
        'ibkrPort': ibkrPort,
        'ibkrClientId': ibkrClientId,
        'ibkrAccountId': ibkrAccountId,
        'ibkrPaperTrading': ibkrPaperTrading,
      };
}

// ═══════════════════════════════════════════════
// CONNECTION DIAGNOSTIC
// Matches backend testConnection() return value
// ═══════════════════════════════════════════════
class ConnectionStatus {
  final bool connected;
  final String? host;
  final int? port;
  final String? accountId;
  final bool paperTrading;
  final String? error;

  ConnectionStatus({
    required this.connected,
    this.host,
    this.port,
    this.accountId,
    this.paperTrading = true,
    this.error,
  });

  factory ConnectionStatus.fromJson(Map<String, dynamic> j) => ConnectionStatus(
        connected: j['connected'] == true,
        host: j['host']?.toString(),
        port: j['port'] is int
            ? j['port']
            : int.tryParse(j['port']?.toString() ?? ''),
        accountId: j['accountId']?.toString(),
        paperTrading: j['paperTrading'] == true || j['paperTrading'] == 1,
        error: j['error']?.toString(),
      );
}

// ── Server Information ─────────────────────────────────────
class ServerInformation {
  final String serverName;
  final String serverHost;
  final String mode; // 'LIVE' or 'TEST'

  ServerInformation({
    required this.serverName,
    required this.serverHost,
    required this.mode,
  });

  factory ServerInformation.fromJson(Map<String, dynamic> j) => ServerInformation(
        serverName: j['serverName'] ?? '',
        serverHost: j['serverHost'] ?? '',
        mode: j['mode'] ?? 'TEST',
      );

  Map<String, dynamic> toJson() => {
        'serverName': serverName,
        'serverHost': serverHost,
        'mode': mode,
      };
}

// ── LoginRequest ──────────────────────────────────────────
class LoginRequest {
  final String username;
  final String password;
  LoginRequest({required this.username, required this.password});
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

// ── RegisterRequest  ──────────────────
class RegisterRequest {
  final String username;
  final String password;
  // final String account;
  // final int clientid;
  // final String host;
  // final String port;
  RegisterRequest({
    required this.username,
    required this.password,
    // required this.account,
    // required this.clientid,
    // required this.host,
    // required this.port
  });
  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        // 'account': account,
        // 'clientid': clientid,
        // 'host': host,
        // 'port': port,
      };
}

// ── OrderRequest (3 fields only) ──────────────────────────
class OrderRequest {
  final String symbol;
  final double entryPrice;
  final double stopLoss;
  OrderRequest(
      {required this.symbol, required this.entryPrice, required this.stopLoss});
  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'entryPrice': entryPrice,
        'stopLoss': stopLoss,
      };
}

// ── AppSettings ───────────────────────────────────────────
class AppSettings {
  final double tradeAmount;
  final double rangeValue;
  final double profitPercent;
  AppSettings(
      {required this.tradeAmount,
      required this.rangeValue,
      required this.profitPercent});
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

// ── TradeOrder - IBKR ─────────────────────────────────────
class TradeOrder {
  final String? id;
  final String? ibkrOrderId; // ← تغيّر من alpacaOrderId
  final String symbol;
  final double? qty;
  final String? status;
  final double? entryPrice;
  final double? takeProfit;
  final double? stopLoss;
  final double? stopPrice;
  final double? limitPrice;
  final double? tradeAmount;
  final DateTime? createdAt;

  TradeOrder({
    this.id,
    this.ibkrOrderId,
    required this.symbol,
    this.qty,
    this.status,
    this.entryPrice,
    this.takeProfit,
    this.stopLoss,
    this.stopPrice,
    this.limitPrice,
    this.tradeAmount,
    this.createdAt,
  });

  // IBKR statuses: PreSubmitted, Submitted, Filled, Cancelled
  bool get isCancellable {
    final s = status?.toLowerCase();
    return s == 'presubmitted' || s == 'submitted';
  }

  factory TradeOrder.fromJson(Map<String, dynamic> j) => TradeOrder(
        id: j['id']?.toString(),
        ibkrOrderId: j['ibkrOrderId']?.toString(),
        symbol: j['symbol'] ?? '',
        qty: _d(j['qty']),
        status: j['orderStatus'] ?? j['status'],
        entryPrice: _d(j['entryPrice']),
        takeProfit: _d(j['takeProfit']),
        stopLoss: _d(j['stopLoss']),
        stopPrice: _d(j['stopPrice']),
        limitPrice: _d(j['limitPrice']),
        tradeAmount: _d(j['tradeAmount']),
        createdAt: _date(j['createdAt']),
      );

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

// ── Account - IBKR fields ─────────────────────────────────
class Account {
  final double netLiquidation; // NetLiquidation
  final double totalCash; // TotalCashValue
  final double grossPositionValue; // GrossPositionValue
  final double availableFunds; // AvailableFunds
  final double buyingPower; // BuyingPower

  Account({
    required this.netLiquidation,
    required this.totalCash,
    required this.grossPositionValue,
    required this.availableFunds,
    required this.buyingPower,
  });

  factory Account.fromJson(Map<String, dynamic> j) => Account(
        netLiquidation: _d(j['NetLiquidation']),
        totalCash: _d(j['TotalCashValue']),
        grossPositionValue: _d(j['GrossPositionValue']),
        availableFunds: _d(j['AvailableFunds']),
        buyingPower: _d(j['BuyingPower']),
      );

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

// ── AppUser (Admin) ───────────────────────────────────────
class AppUser {
  final int id;
  final String username;
  final String role;
  final bool active;

  AppUser(
      {required this.id,
      required this.username,
      required this.role,
      required this.active});

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] is int ? j['id'] : int.tryParse(j['id'].toString()) ?? 0,
        username: j['username'] ?? '',
        role: j['role'] ?? 'USER',
        active: j['active'] == true || j['active'] == 1,
      );
}

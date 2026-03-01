// ── LoginRequest ──────────────────────────────────────────
class LoginRequest {
  final String username;
  final String password;
  LoginRequest({required this.username, required this.password});
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

// ── RegisterRequest ───────────────────────────────────────
class RegisterRequest {
  final String username;
  final String password;
  final String alpacaApiKey;
  final String alpacaApiSecret;
  final String alpacaBaseUrl;
  RegisterRequest({
    required this.username,
    required this.password,
    required this.alpacaApiKey,
    required this.alpacaApiSecret,
    this.alpacaBaseUrl = 'https://paper-api.alpaca.markets',
  });
  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'alpacaApiKey': alpacaApiKey,
        'alpacaApiSecret': alpacaApiSecret,
        'alpacaBaseUrl': alpacaBaseUrl,
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

// ── TradeOrder ────────────────────────────────────────────
class TradeOrder {
  final String? id;
  final String? alpacaOrderId;
  final String symbol;
  final double? qty;
  final String? status;
  final double? takeProfit;
  final double? stopLoss;
  final DateTime? createdAt;
  final String? side;
  final double? filledAvgPrice;

  TradeOrder({
    this.id,
    this.alpacaOrderId,
    required this.symbol,
    this.qty,
    this.status,
    this.takeProfit,
    this.stopLoss,
    this.createdAt,
    this.side,
    this.filledAvgPrice,
  });

  bool get isCancellable {
    final s = status?.toLowerCase();
    return s == 'accepted' ||
        s == 'pending_new' ||
        s == 'new' ||
        s == 'partially_filled';
  }

  factory TradeOrder.fromJson(Map<String, dynamic> j) => TradeOrder(
        id: j['id']?.toString(),
        alpacaOrderId: j['alpacaOrderId']?.toString(),
        symbol: j['symbol'] ?? '',
        qty: _d(j['qty'] ?? j['filledQty'] ?? j['quantity']),
        status: j['status'] ?? j['orderStatus'],
        takeProfit: _d(j['takeProfit'] ?? j['take_profit']),
        stopLoss: _d(j['stopLoss'] ?? j['stop_loss']),
        createdAt: _date(j['createdAt'] ?? j['created_at']),
        side: j['side'],
        filledAvgPrice: _d(j['filledAvgPrice'] ?? j['filled_avg_price']),
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

// ── Account ───────────────────────────────────────────────
class Account {
  final double equity;
  final double cash;
  final double portfolioValue;
  final double buyingPower;
  final double daytradeCount;
  final String status;

  Account({
    required this.equity,
    required this.cash,
    required this.portfolioValue,
    required this.buyingPower,
    required this.daytradeCount,
    required this.status,
  });

  factory Account.fromJson(Map<String, dynamic> j) => Account(
        equity: _d(j['equity']),
        cash: _d(j['cash']),
        portfolioValue: _d(j['portfolio_value'] ?? j['portfolioValue']),
        buyingPower: _d(j['buying_power'] ?? j['buyingPower']),
        daytradeCount: _d(j['daytrade_count'] ?? j['daytradeCount']),
        status: j['status'] ?? '',
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

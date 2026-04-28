# Trading Bot - Flutter + Spring Boot

## 📁 Flutter Project Structure

```
lib/
├── main.dart                    ← Entry point + Navigation
├── app_theme.dart               ← Dark theme colors
├── models/
│   └── models.dart              ← TradeRequest, Trade, AccountInfo
├── services/
│   ├── api_service.dart         ← HTTP (dio) + WebSocket
│   └── trading_provider.dart    ← State management (Provider)
└── screens/
    ├── dashboard_screen.dart    ← P&L dashboard + positions
    ├── order_screen.dart        ← Send order with auto-calc
    ├── trades_screen.dart       ← Open + history tabs
    └── settings_screen.dart     ← Server URL + API keys
```

## 🚀 Quick Start

### 1. Flutter App
```bash
cd trading_bot_flutter
flutter pub get
flutter run
```

### 2. Settings Screen
- Enter your Spring Boot server IP (e.g. `http://192.168.1.10:8080`)
- Keep Paper Trading ON for testing

## 🔌 Communication

| Method | Used For |
|--------|----------|
| REST (dio) | Send orders, fetch account, close positions |
| WebSocket | Real-time P&L updates, order fills |

## 📡 Spring Boot Endpoints Needed

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/trade/execute` | Send order |
| GET | `/api/account` | Account info |
| GET | `/api/positions` | Open positions |
| GET | `/api/orders/history` | Trade history |
| DELETE | `/api/positions/{symbol}` | Close position |
| WS | `/ws/trades` | Real-time updates |

## 📦 Dependencies
- `dio` - HTTP client
- `web_socket_channel` - WebSocket
- `provider` - State management
- `fl_chart` - P&L chart
- `shared_preferences` - Save settings locally

## ⚠️ Android Network (important!)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
For HTTP (not HTTPS) on Android, add to `<application>`:
```xml
android:usesCleartextTraffic="true"
```
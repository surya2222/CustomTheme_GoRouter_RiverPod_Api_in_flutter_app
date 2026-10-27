# Candleboard

A responsive Flutter dashboard that requests and displays one authenticated OHLC
candle from the FastAPI endpoint `GET /api1`. The server generates a new dummy
candle for each request; this app does **not** present a historical series.

For the full step-by-step build explanation and complete source listings, see
[the application build guide](./docs/APP_BUILD_GUIDE.md).

## Requirements

- Flutter (Dart 3.13+)
- Python with the dependencies used by `a4_7api_server_stock.py`
- Android emulator, iOS simulator/device, desktop, or a modern web browser

## Run the API

From the directory containing `a4_7api_server_stock.py`:

```powershell
python -m uvicorn a4_7api_server_stock:app --host 0.0.0.0 --port 8081 --reload
```

The API uses `Authorization: Bearer suryaji` for the demo. The server enables
CORS for GET requests so a local Flutter web build can call it. This permissive
setting is for the dummy development server only; restrict `allow_origins` before
deploying an API that contains real data.

## Run the Flutter app

In the `learn_flutter_api` directory:

```powershell
flutter pub get
flutter run
```

For an explicit target, use `flutter run -d android`, `flutter run -d chrome`,
or `flutter run -d windows`. iOS requires macOS and Xcode; Windows desktop
requires Visual Studio with the Desktop development with C++ workload.

The dashboard polls the API every 5 seconds by default so it can show new
server data automatically. Use Settings to change the polling interval (or turn
it off), choose a theme, or configure a different full API URL. Since the API
does not send change notifications, polling is required to discover updates.
Settings are kept in memory and reset when the app restarts.

### Platform API addresses

- **Android emulator:** defaults to `http://10.0.2.2:8081/api1`, which routes to
  the host computer. The app includes Android internet permission and cleartext
  HTTP support for the local demo server.
- **iOS simulator:** defaults to `http://127.0.0.1:8081/api1`. For a physical
  iPhone/iPad, use the computer's LAN address (for example
  `http://192.168.1.10:8081/api1`) in Settings. Allow local network access when
  iOS prompts.
- **Windows, macOS, Linux, and web:** default to
  `http://127.0.0.1:8081/api1`. Use a reachable LAN address when the server is
  on another computer. Web access requires the API's CORS middleware, which is
  enabled for the supplied local dummy backend.

The server must listen on an interface reachable by the device, and the machine
firewall must allow TCP port 8081 for LAN testing. `127.0.0.1` on a physical
device refers to that device itself, not the development computer.
Binding the demo server to `0.0.0.0` exposes it on available network interfaces;
use it only on a trusted development network.

## Configure credentials

The demo token defaults to `suryaji`. To override it for a local run:

```powershell
flutter run --dart-define=STOCK_API_TOKEN=your-demo-token
```

Values passed using `--dart-define` are compiled into the client and are not
secret. Do not put production credentials in a Flutter app; use a backend
service or a short-lived user authentication flow.

## Tests and analysis

```powershell
flutter test
flutter analyze
```

The tests cover candle parsing, Bearer authentication, HTTP and invalid-JSON
responses, dashboard loading/data/error states, theme selection, and responsive
breakpoint behavior.

## Limitations

- The supplied server returns exactly one random candle per request. The chart
  intentionally renders one candle and does not fabricate demo history.
- The API's bearer token is a demo client-side credential. Production use
  requires an authenticated backend design and HTTPS.
- The app currently keeps theme, refresh interval, and endpoint preferences in
  memory; changing one of these resets on app restart.

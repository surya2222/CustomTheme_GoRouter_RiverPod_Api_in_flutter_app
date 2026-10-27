# Core Concepts

Short descriptions of the main authored files in this Flutter app. Generated
build output and platform boilerplate are not listed.

## Application (`lib/`)

- `lib/main.dart` — Starts Flutter and provides Riverpod state management.
- `lib/app/app.dart` — Configures the app, theme, and router.
- `lib/app/router.dart` — Maps dashboard, candle, and settings paths to screens.
- `lib/app/theme/app_theme.dart` — Defines the shared light and dark themes.
- `lib/app/theme/design_tokens.dart` — Centralizes layout sizes, spacing, and colors.
- `lib/core/responsive/responsive_layout.dart` — Selects mobile, tablet, or desktop layouts.
- `lib/core/widgets/app_button.dart` — Reusable button with optional loading state.
- `lib/core/widgets/app_card.dart` — Reusable padded card container.
- `lib/core/widgets/app_error_view.dart` — Displays an error and retry action.
- `lib/core/widgets/app_icon_button.dart` — Reusable accessible icon button.
- `lib/core/widgets/app_loading.dart` — Shows the loading state.
- `lib/core/widgets/app_scaffold.dart` — Provides shared page layout and navigation.
- `lib/core/widgets/app_status_indicator.dart` — Shows API online or offline status.
- `lib/core/widgets/candle_chart.dart` — Draws the candle chart.
- `lib/core/widgets/ohlc_summary.dart` — Displays a candle's open, high, low, and close.
- `lib/data/models/candle.dart` — Defines and validates candle data from JSON.
- `lib/data/repositories/candle_repository.dart` — Exposes candle data to the app layer.
- `lib/data/services/candle_api_service.dart` — Requests and parses candle data from the API.
- `lib/providers/candle_provider.dart` — Manages candle loading, errors, and refreshes.
- `lib/providers/settings_provider.dart` — Holds theme, refresh interval, and API URL settings.
- `lib/features/dashboard/dashboard_screen.dart` — Shows the latest candle and refresh controls.
- `lib/features/candle_details/candle_details_screen.dart` — Shows detailed candle values.
- `lib/features/settings/settings_screen.dart` — Lets users change app and API settings.

## Tests (`test/`)

- `test/widget_test.dart` — Tests dashboard behavior, settings, and responsive layouts.
- `test/data/models/candle_test.dart` — Tests candle JSON parsing and validation.
- `test/data/services/candle_api_service_test.dart` — Tests API requests and error handling.

## Project files

- `pubspec.yaml` — Declares Dart constraints, dependencies, and Flutter settings.
- `analysis_options.yaml` — Configures Dart analyzer and lint rules.
- `README.md` — Explains setup, running the app, and its limitations.
- `docs/App_Build_Guide_for_api.md` — Provides the step-by-step app build guide.

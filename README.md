# 🌤 Flutter Weather App

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) 
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white) 

A beautiful, modern, dark-themed, glassmorphic weather application built for iOS and Android using Flutter. It provides real-time forecasts, an interactive weather map, and location-based alerts.

## ✨ Features

- 🌤 **Comprehensive Dashboard:** Detailed current weather conditions, an interactive hourly forecast, and an extended 7-day outlook.
- 🗺 **Interactive Map:** A real-time, interactive weather map built with `flutter_map` and OpenStreetMap, centered automatically on your GPS coordinates.
- 🚨 **Weather Alerts:** Timely location-based weather warnings and updates.
- ⚙️ **Settings & Customization:** Configure measurement units, default locations, and app behaviors.
- 🎨 **Premium UI/UX:** A stunning dark-themed, glassmorphic interface inspired by modern mobile app design trends.

## 🛠 Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
- **API & Networking:** The `http` package, integrated with the [OpenWeather One Call API 3.0](https://openweathermap.org/api/one-call-3)
- **Maps:** `flutter_map` & `latlong2`
- **Location:** `geolocator` & `geocoding` for device GPS management
- **Assets & Styling:** `google_fonts` (Inter, Roboto, or Outfit) and `lucide_icons`

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.11.4 or higher recommended)
- A valid [OpenWeatherMap API Key](https://openweathermap.org/api) (Ensure the One Call API 3.0 is enabled)

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd flutter_weather
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Create a `.env` file in the root directory and add your OpenWeather API Key:
   ```env
   OPENWEATHER_API_KEY=your_api_key_here
   ```

4. **Run the Application:**
   ```bash
   flutter run --dart-define-from-file=.env
   ```

## 🏗 Architecture

This project strictly adheres to a feature-based architecture pattern for better scalability and separation of concerns:

```text
lib/
├── alerts/     # Weather alert models, providers, and UI
├── core/       # Global services (API, location), themes, and utilities
├── dashboard/  # Main weather screen, hourly & daily forecast widgets
├── map/        # Interactive OpenStreetMap implementation
└── settings/   # User preference screens and toggles
```

## 🤝 Contributing

Feel free to suggest improvements or report bugs! Pull requests are welcomed for review.

## 📄 Attributions

- Weather data provided by [OpenWeatherMap](https://openweathermap.org/)
- Maps powered by [OpenStreetMap](https://www.openstreetmap.org/)

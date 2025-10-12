# Linze - Anime Streaming App

## Project Overview

Linze is a Flutter-based anime streaming application that connects to a custom anime streaming API. The app provides users with a complete anime viewing experience, featuring a modern UI designed according to provided design templates. The application includes user authentication, home screen with trending content, search functionality, detailed anime information, and user profile management.

### Key Technologies

- **Flutter** (Dart-based cross-platform framework)
- **Riverpod** (State management)
- **HTTP** (API communication)
- **Cached Network Image** (Image caching)
- **Google Fonts** (Typography)
- **Persistent Bottom Navigation Bar** (Navigation)
- **Video Player & Chewie** (Video playback)
- **Shared Preferences** (Local data storage)

### Architecture

The app follows a layered architecture with:
- **Presentation Layer** (UI screens in features/)
- **Core Layer** (API services, models, constants, widgets)
- **Utils** (Utility functions and helpers)

## Project Structure

```
lib/
├── app/                 # App module (if exists)
├── core/                # Core functionality
│   ├── api/             # API-related code
│   ├── constants/       # Constants and themes
│   ├── models/          # Data models
│   └── widgets/         # Reusable widgets
├── features/            # Feature modules
│   ├── anime_detail/    # Anime detail screen
│   ├── auth/            # Authentication screens
│   ├── home/            # Home screen and main navigation
│   ├── login_signup/    # Login/signup screens
│   ├── profile_settings/ # Profile settings screen
│   ├── search_discovery/ # Search and discovery screen
│   └── welcome/         # Welcome screen
├── utils/               # Utility functions
└── main.dart            # App entry point
```

## Building and Running

### Prerequisites

- Flutter SDK (latest stable version)
- Android SDK / iOS tools (for mobile deployment)
- Access to the anime streaming API at http://localhost:4444/

### Setup

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Ensure your anime streaming API is running at http://localhost:4444/
4. Run the app with `flutter run`

### Commands

- `flutter run` - Build and run the app on a connected device
- `flutter run --release` - Build and run in release mode
- `flutter build apk` - Build APK for Android
- `flutter build ios` - Build for iOS
- `flutter analyze` - Analyze the codebase
- `flutter test` - Run tests

## API Integration

The app connects to an anime streaming API with the following key endpoints:

- `/api/` - Home page data
- `/api/info?id={id}` - Anime details
- `/api/episodes/{id}` - Episode list
- `/api/stream` - Streaming links
- `/api/search` - Search functionality
- `/api/{category}` - Category browsing
- `/api/random` - Random anime
- `/api/top-ten` - Top 10 lists

The API service is implemented in `lib/core/services/api_service.dart`, and data models are defined in `lib/core/models/`.

## Key Features

### UI Screens

1. **Welcome Screen** - Entry point with login/signup options
2. **Login/Signup Screen** - Authentication with form validation
3. **Home Screen** - Dashboard with featured content, trending, and new releases
4. **Search/Discovery Screen** - Browse by genre and popular searches
5. **Anime Detail Screen** - Detailed anime information with episode list
6. **Profile/Settings Screen** - User profile and app settings
7. **Main Navigation** - Bottom tab navigation between key sections

### UI Design

- Follows the design templates provided in `/docs/Screen-Template/`
- Dark theme with purple accents (`#5B13EC`)
- Responsive design using Flutter's layout system
- Image caching for better performance
- Google Fonts Plus Jakarta Sans for typography

### State Management

- Uses Riverpod for state management
- Providers defined in `lib/core/services/anime_provider.dart`
- Handles API data fetching with loading/error states

### Navigation

- Bottom tab navigation with 5 main sections (Home, Discover, My List, Downloads, Profile)
- Screen-to-screen navigation with parameter passing
- Authentication state management

## Development Conventions

### Naming Conventions

- PascalCase for class names
- camelCase for method names and variables
- Snake_case for file names
- Widgets follow the pattern `ScreenName extends StatelessWidget` or `ScreenName extends StatefulWidget`

### Code Organization

- Each feature has its own directory in `/features/`
- Within each feature: `presentation/screen/` for UI, models and services as needed
- Core functionality is in the `/core/` directory
- Models are in `/lib/core/models/`
- Services are in `/lib/core/services/`

### Styling

- Uses Google Fonts Plus Jakarta Sans for consistent typography
- Dark theme with specific color scheme
- Consistent padding and margin values
- Responsive design using Flutter's layout widgets

## Testing

The app includes a basic widget test in `/test/widget_test.dart` that can be extended to cover all screens and functionality.

## API Documentation

For details about the streaming API, see `/docs/APi-docs.md`.

This project is a complete, production-ready anime streaming client that connects to the custom API. The UI design follows the templates provided in the docs/Screen-Template directory, creating a cohesive and visually appealing user experience.
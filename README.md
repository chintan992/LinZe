# Linze 🎌

**A Modern Anime Streaming Application built with Flutter**

Linze is a comprehensive anime streaming app that provides users with access to a vast library of anime content, featuring modern UI design, smooth video playback, and personalized recommendations.

## ✨ Features

- 🏠 **Home Dashboard** - Discover trending, popular, and latest anime
- 🔍 **Advanced Search** - Find anime by title, genre, or keywords with smart suggestions
- 📱 **Responsive Design** - Optimized for mobile, tablet, and desktop
- 🎬 **Video Player** - Built-in player with subtitle support and quality options
- 📋 **My List** - Save and organize your favorite anime
- 📥 **Downloads** - Offline viewing capability
- ⚙️ **Profile Settings** - Customize your viewing experience
- 🌙 **Dark Theme** - Beautiful dark UI with purple accent colors
- 🎯 **Categories** - Browse by genres, studios, and release status
- 📊 **Top Charts** - Daily, weekly, and monthly top anime lists

## 🏗️ Architecture

The app follows a clean architecture pattern with feature-based organization:

```
lib/
├── app/
│   └── routes.dart          # App routing configuration
├── core/
│   ├── api/                 # API service layer
│   ├── constants/           # App constants
│   ├── models/              # Data models
│   ├── providers/           # State management
│   ├── services/            # Core services
│   └── widgets/             # Reusable widgets
├── features/
│   ├── anime_detail/        # Anime detail screens
│   ├── auth/                # Authentication
│   ├── home/                # Home dashboard
│   ├── profile_settings/    # User settings
│   ├── search_discovery/    # Search and discovery
│   ├── video_player/        # Video playback
│   └── welcome/             # Onboarding
└── utils/                   # Utility functions
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/chintan992/linze.git
   cd linze
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 🛠️ Tech Stack

- **Framework:** Flutter 3.9.2+
- **State Management:** Riverpod
- **HTTP Client:** HTTP package
- **Video Player:** Chewie + Video Player
- **UI Components:** Material Design 3
- **Fonts:** Google Fonts
- **Image Caching:** Cached Network Image
- **Local Storage:** Shared Preferences
- **Navigation:** Persistent Bottom Nav Bar

## 📱 Screenshots

The app features a modern dark theme with purple accents and intuitive navigation:

- **Welcome Screen** - Onboarding for new users
- **Home Screen** - Featured content and recommendations
- **Search Screen** - Advanced search with filters
- **Anime Detail** - Comprehensive anime information
- **Video Player** - Smooth playback experience
- **Profile Settings** - User customization options

## 🔌 API Integration

Linze integrates with a comprehensive anime API that provides:

- **Home Data** - Spotlights, trending, and categorized content
- **Search** - Advanced search with suggestions
- **Anime Details** - Complete information including episodes
- **Streaming** - Multiple server options with subtitle tracks
- **Categories** - Genre-based and alphabetical browsing
- **Characters** - Character information and voice actors

> 📖 **API Documentation:** See [docs/APi-docs.md](docs/APi-docs.md) for complete API reference

## 🎨 UI/UX Features

- **Material Design 3** - Modern design system
- **Dark Theme** - Eye-friendly dark interface
- **Responsive Layout** - Adapts to different screen sizes
- **Smooth Animations** - Fluid transitions and interactions
- **Custom Components** - Tailored widgets for anime content
- **Accessibility** - Screen reader and keyboard navigation support

## 🚀 Development

### Code Structure

- **Feature-based organization** - Each feature has its own directory
- **Separation of concerns** - Clear separation between UI, business logic, and data
- **Reusable components** - Shared widgets and utilities
- **Type safety** - Strong typing with Dart

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

If you like this project, please give it a star ⭐ and share it with others!

For support, email your-email@example.com or create an issue in the repository.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Anime API providers for the content
- Open source community for the packages used

---

**Made with ❤️ by [Chintan Rathod](https://github.com/chintan992)**

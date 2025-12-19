# Food Recipes App 🍳

A professional Flutter mobile application for browsing and managing food recipes with advanced pagination, smooth animations, responsive design, and local database storage.

## ✨ Features

- 🎯 **Infinite Scroll Pagination** - Efficiently loads recipes as you scroll
- 🎨 **Smooth Animations** - Professional UI with fade, slide, and hero animations
- 📱 **Responsive Design** - Adapts beautifully to all Android device sizes
- 💾 **Local Storage** - Save your own recipes locally using SQLite
- 🌐 **API Integration** - Fetches recipes from FakeStore API
- 🔄 **Pull-to-Refresh** - Refresh recipe list with a simple swipe
- ⚡ **Performance Optimized** - Image caching and lazy loading
- 🎭 **Professional UI/UX** - Modern design with gradient overlays and cards

## 📸 Screenshots

The app features:
- Beautiful recipe cards with images
- Smooth page transitions
- Professional detail screens
- Easy-to-use add recipe form

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.1 or higher
- Dart SDK
- Android Studio / VS Code
- Android device or emulator (Android 5.0+)

### Installation

1. Clone the repository:
```bash
git clone git@github.com:cbabi2023/recipieapi.git
cd recipieapi
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📁 Project Structure

See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for detailed documentation of all folders and files.

## 🏗️ Architecture

- **Repository Pattern** - Abstracts data sources
- **Provider Pattern** - State management
- **Service Layer** - API and database services
- **Clean Architecture** - Separation of concerns

## 📚 Documentation

- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Detailed project structure
- [WORK_DESCRIPTION.md](WORK_DESCRIPTION.md) - Comprehensive work description

## 🔌 API Used

**FakeStore API** - https://fakestoreapi.com
- Free, open-source REST API
- Used for demonstration purposes
- Products are mapped to recipe format

## 🛠️ Tech Stack

- **Framework**: Flutter 3.10.1+
- **Language**: Dart
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **HTTP Client**: http
- **Image Caching**: cached_network_image

## 📱 Platform Support

- ✅ Android (Primary - Android 5.0+)
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS

## 🎯 Key Features Explained

### Pagination
- Loads 10 recipes per page
- Automatically loads more at 80% scroll
- Efficient memory usage

### Animations
- Staggered card animations
- Hero image transitions
- Smooth page transitions
- FAB scale animations

### Responsive Design
- Dynamic font sizes
- Adaptive spacing
- Screen size detection
- Clamp constraints for readability

## 📝 License

This project is open source and available for educational purposes.

## 👨‍💻 Author

Developed with Flutter and ❤️

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

---

**Note**: This app uses the FakeStore API for demonstration purposes. Product data is mapped to recipe format.

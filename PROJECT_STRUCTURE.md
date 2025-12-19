# Food Recipes App - Project Structure Documentation

## Overview
This document provides a comprehensive guide to the project structure, explaining each folder and file's purpose and functionality.

## Project Root Structure

```
foodapp/
├── android/                 # Android platform-specific code
├── ios/                     # iOS platform-specific code
├── lib/                     # Main application source code
├── test/                    # Unit and widget tests
├── web/                     # Web platform-specific code
├── windows/                 # Windows platform-specific code
├── linux/                   # Linux platform-specific code
├── macos/                   # macOS platform-specific code
├── pubspec.yaml            # Flutter project dependencies and configuration
├── pubspec.lock            # Locked dependency versions
├── analysis_options.yaml   # Dart analyzer configuration
├── README.md               # Project readme
├── WORK_DESCRIPTION.md      # Detailed work description document
└── PROJECT_STRUCTURE.md    # This file - project structure documentation
```

---

## 📁 lib/ - Main Application Source Code

The `lib/` directory contains all the Dart source code for the Flutter application.

### 📄 lib/main.dart
**Purpose**: Application entry point  
**Description**: 
- Initializes the Flutter app
- Sets up Provider for state management
- Configures MaterialApp with theme
- Sets RecipeListScreen as the home screen

**Key Components**:
- `MyApp` widget - Root widget
- `ChangeNotifierProvider` - Provides RecipeProvider to entire app
- Theme configuration with deep orange color scheme

---

### 📁 lib/models/ - Data Models

#### 📄 lib/models/recipe.dart
**Purpose**: Recipe data model class  
**Description**: Defines the Recipe data structure used throughout the app

**Key Features**:
- Recipe properties: `id`, `title`, `image`, `rating`, `time`, `description`, `source`
- `toMap()` - Converts Recipe to Map for database storage
- `fromMap()` - Creates Recipe from database Map
- `fromApi()` - Creates Recipe from FakeStore API response
- `copyWith()` - Creates a copy with modified fields

**Data Fields**:
- `id`: Unique identifier (nullable int)
- `title`: Recipe name (String)
- `image`: Image URL (String)
- `rating`: Rating 0.0-5.0 (double)
- `time`: Preparation time (String, e.g., "20 min")
- `description`: Recipe description (nullable String)
- `source`: "API" or "LOCAL" (String)

---

### 📁 lib/services/ - Service Layer

#### 📄 lib/services/api_service.dart
**Purpose**: Handles API communication  
**Description**: Manages all HTTP requests to the FakeStore API

**Key Methods**:
- `fetchRecipes({limit, offset})` - Fetches recipes with pagination support
- `fetchAllRecipes()` - Fetches all recipes (for refresh)

**Features**:
- Pagination support with limit and offset
- Error handling with try-catch
- JSON parsing and mapping to Recipe model
- Base URL: `https://fakestoreapi.com`

**API Endpoints Used**:
- `GET /products/` - Get all products
- `GET /products?limit={limit}` - Get paginated products

---

#### 📄 lib/services/database_service.dart
**Purpose**: SQLite database operations  
**Description**: Manages local database for storing user-created recipes

**Key Methods**:
- `_initDB()` - Initializes database
- `_createDB()` - Creates recipes table
- `insertRecipe()` - Add new recipe
- `getRecipes({limit, offset})` - Get paginated recipes
- `getAllRecipes()` - Get all recipes
- `getRecipe(id)` - Get single recipe
- `updateRecipe()` - Update existing recipe
- `deleteRecipe(id)` - Delete recipe
- `getLocalRecipeCount()` - Get total count

**Database Schema**:
```sql
CREATE TABLE recipes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  image TEXT NOT NULL,
  rating REAL NOT NULL DEFAULT 3.0,
  time TEXT NOT NULL,
  description TEXT,
  source TEXT NOT NULL DEFAULT 'LOCAL'
)
```

**Features**:
- Singleton pattern for database instance
- Pagination support
- Automatic database initialization
- Proper error handling

---

### 📁 lib/repositories/ - Repository Layer

#### 📄 lib/repositories/recipe_repository.dart
**Purpose**: Data abstraction layer  
**Description**: Combines API and database services, providing unified data access

**Key Methods**:
- `getRecipes({page, loadMore})` - Get recipes with pagination (combines API + local)
- `loadMoreRecipes(currentPage)` - Load next page of recipes
- `addRecipe()` - Add recipe to local database
- `updateRecipe()` - Update local recipe
- `deleteRecipe()` - Delete local recipe
- `getLocalRecipes()` - Get only local recipes

**Features**:
- Combines API recipes with local recipes
- Handles pagination logic
- Error handling with fallback to local recipes
- Page size: 10 items per page

**Architecture Pattern**: Repository Pattern
- Abstracts data sources
- Single source of truth
- Easy to test and maintain

---

### 📁 lib/providers/ - State Management

#### 📄 lib/providers/recipe_provider.dart
**Purpose**: State management using Provider pattern  
**Description**: Manages application state and notifies UI of changes

**State Variables**:
- `_recipes` - List of all recipes
- `_isLoading` - Initial loading state
- `_isLoadingMore` - Loading more recipes state
- `_hasMore` - Whether more recipes are available
- `_currentPage` - Current page number
- `_error` - Error message if any

**Key Methods**:
- `loadRecipes({refresh})` - Load recipes (initial or refresh)
- `loadMoreRecipes()` - Load next page (infinite scroll)
- `addRecipe()` - Add new recipe
- `updateRecipe()` - Update recipe
- `deleteRecipe()` - Delete recipe
- `refreshRecipes()` - Refresh all recipes

**Features**:
- Reactive state management
- Pagination state tracking
- Loading states management
- Error handling
- Automatic UI updates via `notifyListeners()`

---

### 📁 lib/screens/ - Application Screens

#### 📄 lib/screens/recipe_list_screen.dart
**Purpose**: Main screen displaying list of recipes  
**Description**: Home screen with recipe cards, infinite scroll, and animations

**Key Features**:
- **Infinite Scroll**: Automatically loads more recipes at 80% scroll
- **Pull-to-Refresh**: Swipe down to refresh recipes
- **Animations**: 
  - FAB scale animation
  - FAB hide/show on scroll
  - Page transitions
- **Responsive Design**: Adapts to all screen sizes
- **Loading States**: Shows loading indicators
- **Error Handling**: Displays error with retry button
- **Empty State**: Shows message when no recipes

**UI Components**:
- `SliverAppBar` - Collapsible app bar with gradient
- `SliverList` - Efficient list rendering
- `FloatingActionButton` - Add recipe button
- `NotificationListener` - Detects scroll for pagination

**Navigation**:
- Navigates to `RecipeDetailScreen` on card tap
- Navigates to `AddRecipeScreen` on FAB tap

---

#### 📄 lib/screens/recipe_detail_screen.dart
**Purpose**: Recipe detail view  
**Description**: Displays full recipe information with professional UI

**Key Features**:
- **Hero Animation**: Smooth image transition from list
- **Professional Layout**: Card-based design with info cards
- **Animations**: 
  - Fade and slide animations
  - Smooth page transitions
- **Info Cards**: Rating and time displayed in styled cards
- **Description Section**: Formatted description display
- **Delete Functionality**: Delete button for local recipes
- **Bottom Sheet Menu**: Options menu for local recipes
- **Delete Dialog**: Confirmation dialog with professional design

**UI Components**:
- `SliverAppBar` - Hero image with collapsible header
- `Info Cards` - Rating and time in styled containers
- `Description Card` - Formatted description
- `Delete Button` - Styled delete action
- `Bottom Sheet` - Options menu
- `Dialog` - Delete confirmation

**Responsive Design**: Adapts font sizes and spacing based on screen size

---

#### 📄 lib/screens/add_recipe_screen.dart
**Purpose**: Add new recipe form  
**Description**: Form to create and save new recipes locally

**Key Features**:
- **Form Validation**: Validates all required fields
- **Professional Design**: Modern form with gradient header
- **Animations**: Fade-in animation on load
- **Input Fields**:
  - Recipe Title (required)
  - Image URL (required)
  - Rating 0.0-5.0 (required, validated)
  - Preparation Time (required)
  - Description (optional)
- **Save Functionality**: Saves to local database
- **Success/Error Feedback**: SnackBar notifications

**UI Components**:
- `AppBar` - Back button and title
- `Form` - Validated form
- `TextFormField` - Styled input fields
- `ElevatedButton` - Save button with loading state
- `Gradient Header` - Decorative header section

**Validation Rules**:
- Title: Required, non-empty
- Image URL: Required, non-empty
- Rating: Required, must be 0.0-5.0
- Time: Required, non-empty
- Description: Optional

---

### 📁 lib/widgets/ - Reusable Widgets

#### 📄 lib/widgets/recipe_card.dart
**Purpose**: Reusable recipe card widget  
**Description**: Displays recipe information in a card format

**Key Features**:
- **Hero Animation**: Image transitions between screens
- **Staggered Animations**: Cards animate in sequence
- **Responsive Design**: Adapts to screen size
- **Image Caching**: Uses cached_network_image
- **Gradient Overlay**: Text overlay on image
- **Badges**: Rating and time badges
- **Local Indicator**: Shows "Local" badge for user recipes

**Animation Details**:
- Fade animation: 0.0 to 1.0 opacity
- Slide animation: From bottom (0.3 offset)
- Stagger delay: 50ms per card
- Duration: 600ms

**Responsive Calculations**:
- Card height: 25% of screen height (clamped 180-250px)
- Font sizes: Based on screen width percentage
- Margins: 4% of screen width (clamped 12-20px)

**UI Components**:
- `Hero` - Image hero animation
- `CachedNetworkImage` - Cached image loading
- `Container` - Card container with shadow
- `Stack` - Image and content overlay
- `Badges` - Rating and time indicators

---

## 📁 android/ - Android Platform Code

**Purpose**: Android-specific configuration and code

### Key Files:
- `android/app/build.gradle.kts` - Android app build configuration
- `android/app/src/main/AndroidManifest.xml` - Android manifest
- `android/local.properties` - Local SDK paths
- `android/build.gradle.kts` - Project-level build configuration

**Configuration**:
- Min SDK: 21 (Android 5.0)
- Target SDK: Latest
- Package: `com.example.foodapp`
- Kotlin version: 2.2.20

---

## 📁 ios/ - iOS Platform Code

**Purpose**: iOS-specific configuration and code

### Key Files:
- `ios/Runner/Info.plist` - iOS app configuration
- `ios/Runner/AppDelegate.swift` - iOS app delegate

---

## 📁 test/ - Test Files

**Purpose**: Unit and widget tests

### Key Files:
- `test/widget_test.dart` - Example widget test

---

## 📁 web/ - Web Platform Code

**Purpose**: Web-specific configuration

### Key Files:
- `web/index.html` - Web entry point
- `web/manifest.json` - Web app manifest

---

## Configuration Files

### 📄 pubspec.yaml
**Purpose**: Flutter project configuration and dependencies

**Key Sections**:
- Project metadata (name, description, version)
- Dependencies:
  - `http` - HTTP requests
  - `sqflite` - SQLite database
  - `provider` - State management
  - `cached_network_image` - Image caching
  - `intl` - Internationalization
- Flutter configuration

---

### 📄 analysis_options.yaml
**Purpose**: Dart analyzer configuration

**Description**: Defines linting rules and code analysis settings

---

### 📄 .gitignore
**Purpose**: Git ignore patterns

**Ignored Items**:
- Build artifacts
- IDE files
- Dependencies
- OS-specific files
- Generated files

---

## Documentation Files

### 📄 README.md
**Purpose**: Project overview and getting started guide

### 📄 WORK_DESCRIPTION.md
**Purpose**: Comprehensive work description with:
- API details
- Architecture patterns
- Implementation methods
- Animation specifications
- Performance optimizations

### 📄 PROJECT_STRUCTURE.md
**Purpose**: This file - detailed project structure documentation

---

## Data Flow Architecture

```
User Action
    ↓
UI (Screens/Widgets)
    ↓
Provider (State Management)
    ↓
Repository (Data Abstraction)
    ↓
Services (API/Database)
    ↓
Data Source (API/Database)
```

## Key Design Patterns

1. **Repository Pattern**: Abstracts data sources
2. **Provider Pattern**: State management
3. **Service Layer Pattern**: Separates business logic
4. **Singleton Pattern**: Database service instance
5. **Factory Pattern**: Recipe model constructors

## File Organization Principles

1. **Separation of Concerns**: Each layer has specific responsibility
2. **Single Responsibility**: Each file has one clear purpose
3. **Reusability**: Widgets and services are reusable
4. **Maintainability**: Clear structure for easy maintenance
5. **Scalability**: Easy to add new features

## Dependencies Overview

- **http**: API communication
- **sqflite**: Local database
- **provider**: State management
- **cached_network_image**: Image optimization
- **intl**: Internationalization support

## Platform Support

- ✅ Android (Primary)
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS

---

## Summary

This project follows Flutter best practices with:
- Clean architecture
- Separation of concerns
- Reusable components
- Professional UI/UX
- Efficient state management
- Proper error handling
- Responsive design
- Smooth animations

The structure is organized, maintainable, and scalable for future enhancements.


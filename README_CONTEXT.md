# Civic Reporter Project Context Summary

## Project Overview
**Civic Reporter** is a Flutter-based mobile application that enables citizens to report and track civic issues in their communities. The app uses a clean architecture pattern with Supabase as the backend and implements modern Flutter development practices.

## Current Architecture Status
The project is currently undergoing a **major architectural redesign** to move from a map-centric interface to a more intuitive dashboard-style navigation system with structured bottom navigation and drawer menu.

## Tech Stack
- **Frontend**: Flutter 3.x with Dart
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **State Management**: Riverpod
- **Maps**: Flutter Map with MapTiler
- **Architecture**: Clean Architecture with Repository Pattern
- **Navigation**: Go Router
- **Local Storage**: SharedPreferences

## Key Features Implemented

### 🔐 Authentication System
- Email/password authentication via Supabase Auth
- Landing screen for unauthenticated users
- Profile management with theme settings
- Forgot password functionality
- Secure user session management

### 🗺️ Location & Mapping
- MapTiler integration for high-quality map tiles
- GPS-based location services
- Geocoding for address resolution
- Auto-centering on user location
- Interactive map markers for issues

### 📋 Issue Reporting System
- Comprehensive issue creation with categories (Pothole, Street Light, Garbage, etc.)
- **Importance levels**: Low, Medium, High, Critical (with visual indicators)
- Photo upload via Supabase Storage
- Location attachment with GPS coordinates
- Status tracking (Submitted, In Progress, Resolved, Rejected)

### 👍 Social Features
- **Upvote system** with user tracking
- Community-driven issue prioritization
- Detailed report views with full information
- User engagement metrics

### 🎨 User Experience
- **Theme system**: Light/Dark/System modes with persistence
- Responsive design for various screen sizes
- Clean, intuitive interface
- Consistent visual design language

## Current Architectural Redesign (In Progress)

### New Navigation Structure
- **Bottom Navigation Bar**: Primary navigation with 3 tabs
  - Home (Dashboard)
  - Issues (Map & List view)
  - Profile
- **Drawer Menu**: Secondary navigation with additional options
- **PageView Controller**: Smooth navigation between screens

### New Screen Structure
1. **Dashboard Screen** (`dashboard_screen.dart`)
   - Welcome card with personalized greeting
   - Quick action buttons (Report Issue, View All Issues)
   - Recent issues feed with importance indicators
   - Empty state and error handling

2. **Issues Screen** (`issues_screen.dart`) - *Planned*
   - City-based filtering using device location
   - Map view with importance-tagged markers
   - List view with filtering options
   - Importance chips with color coding

3. **Enhanced Profile** - *Planned*
   - Edit profile functionality
   - Profile picture upload
   - User settings management

## Database Schema (Supabase)

### Reports Table
```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key to auth.users)
- title (TEXT)
- description (TEXT)
- category (ENUM: pothole, streetLight, garbage, graffiti, brokenSidewalk, other)
- importance (ENUM: low, medium, high, critical)
- status (ENUM: submitted, inProgress, resolved, rejected)
- location (JSONB: latitude, longitude, address)
- image_urls (TEXT[])
- upvotes (INTEGER)
- upvoted_by (TEXT[])
- admin_notes (TEXT)
- created_at, updated_at (TIMESTAMP)
```

### Storage Buckets
- **images**: Public bucket for report photos with RLS policies

## File Structure
```
lib/
├── core/
│   ├── config/          # App configuration (Supabase, MapTiler keys)
│   ├── models/          # Core data models (LocationModel)
│   ├── providers/       # Global providers (ThemeProvider)
│   ├── router/          # App routing with Go Router
│   ├── services/        # Core services (LocationService)
│   └── theme/           # App theming configuration
├── features/
│   ├── auth/            # Authentication (login, signup, providers)
│   ├── home/            # Home screens (dashboard, original home)
│   ├── navigation/      # New navigation wrapper (MainNavigationScreen)
│   ├── profile/         # Profile management & editing
│   └── reports/         # Issue reporting system
│       ├── data/        # Repositories & models
│       ├── domain/      # Entities & business logic
│       └── presentation/ # Screens, widgets, providers
└── main.dart
```

## Key Dependencies
```yaml
flutter_riverpod: ^2.4.9      # State management
supabase_flutter: ^2.3.4      # Backend services
flutter_map: ^6.1.0           # Interactive maps
geolocator: ^10.1.0           # Location services
geocoding: ^2.1.1             # Address resolution
image_picker: ^1.0.4          # Photo selection
go_router: ^12.1.3            # Navigation
shared_preferences: ^2.2.2    # Local storage
```

## Recent Implementations
1. ✅ **Theme System**: Persistent theme switching with SharedPreferences
2. ✅ **Landing Screen**: Welcome screen for unauthenticated users
3. ✅ **Upvote System**: Community engagement with user tracking
4. ✅ **Importance Levels**: Mandatory importance selection for reports
5. ✅ **Auto-centering Map**: GPS-based map positioning
6. ✅ **Navigation Wrapper**: MainNavigationScreen with bottom nav and drawer
7. ✅ **Dashboard Screen**: New home screen with quick actions and recent issues
8. 🔄 **Issues Screen**: City-filtered map and list view (in progress)
9. 🔄 **Edit Profile**: Profile editing with photo upload (in progress)

## Pending Tasks
1. Complete Issues Screen implementation with city filtering
2. Create Edit Profile Screen with photo upload
3. Update routing to use new navigation structure
4. Add geocoding for city-based filtering
5. Implement importance-based visual indicators on map markers
6. Update existing screens to work with new navigation
7. Test and refine user experience flows

## Configuration Requirements
- Supabase project with URL and anon key
- MapTiler API key for map tiles
- Proper RLS policies for database security
- Storage bucket configuration for image uploads
- Platform-specific permissions (location, camera, storage)

## Development Status
The project is in active development with a focus on improving user experience through better navigation and more intuitive interface design. The core functionality is stable, and the architectural redesign aims to make the app more accessible and user-friendly while maintaining all existing features.

## Files Created/Modified in Current Session

### New Files Created
1. `lib/features/navigation/presentation/screens/main_navigation_screen.dart`
   - Main navigation wrapper with bottom navigation bar and drawer
   - PageView controller for smooth screen transitions
   - Integrated theme toggle and logout functionality

2. `lib/features/home/presentation/screens/dashboard_screen.dart`
   - New dashboard-style home screen
   - Welcome card with personalized greeting
   - Quick action buttons for primary user flows
   - Recent issues feed with importance indicators
   - Empty state and error handling

### Files In Progress
1. `lib/features/reports/presentation/screens/issues_screen.dart` - *Needs completion*
2. `lib/features/profile/presentation/screens/edit_profile_screen.dart` - *Needs creation*

### Files Requiring Updates
1. `lib/core/router/app_router.dart` - Update to use new navigation structure
2. `lib/features/profile/presentation/screens/profile_screen.dart` - Add edit profile navigation
3. Various existing screens - Integration with new navigation system

## Next Steps for Development
1. Complete the Issues Screen with city-based filtering
2. Implement Edit Profile Screen with photo upload capability
3. Update routing system to integrate new navigation
4. Add geocoding service for city detection
5. Enhance map markers with importance indicators
6. Test complete user flows and navigation
7. Update documentation and README

## Technical Notes
- The new navigation system uses PageView for performance optimization
- Theme system is integrated throughout all new screens
- Error handling and loading states are implemented consistently
- Clean architecture principles are maintained in new implementations
- All new screens follow the established design patterns and state management approach
# Civic Reporter

A Flutter app for reporting civic issues with photo, GPS location, and status tracking. Built with clean architecture and Riverpod state management.

## Features

- **User Authentication**: Supabase Auth with email/password signup and login
- **Issue Reporting**: Report civic issues with photos, descriptions, and auto-captured GPS location
- **MapTiler Integration**: View all reports on an interactive map with street tiles
- **My Reports**: Track the status of your submitted reports (Submitted, In Progress, Resolved, Rejected)
- **Clean Architecture**: Well-organized code structure with separation of concerns
- **State Management**: Riverpod for reactive state management
- **Responsive UI**: Material Design 3 with custom theming

## Architecture

The app follows clean architecture principles:

```
lib/
├── core/
│   ├── models/
│   ├── router/
│   ├── services/
│   └── theme/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/
│   ├── profile/
│   └── reports/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart
```

## Setup Instructions

### Prerequisites

1. Flutter SDK (>=3.10.0)
2. Supabase project setup
3. MapTiler API key

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd civic_reporter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Supabase Setup**
   - Create a new Supabase project at [Supabase Console](https://supabase.com/dashboard)
   - Enable Authentication with Email/Password provider
   - Create the following table in your database:
   
   ```sql
   CREATE TABLE reports (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     user_id UUID REFERENCES auth.users(id),
     title TEXT NOT NULL,
     description TEXT NOT NULL,
     category TEXT NOT NULL,
     status TEXT NOT NULL DEFAULT 'submitted',
     location JSONB NOT NULL,
     image_urls TEXT[] DEFAULT '{}',
     admin_notes TEXT,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     updated_at TIMESTAMP WITH TIME ZONE
   );
   ```
   
   - Create a storage bucket named 'images' for photo uploads
   - Update `lib/core/config/app_config.dart` with your Supabase URL and anon key

4. **MapTiler Setup**
   - Get a MapTiler API key from [MapTiler Cloud](https://cloud.maptiler.com/)
   - Update `lib/core/config/app_config.dart` with your MapTiler API key

5. **Run the app**
   ```bash
   flutter run
   ```

### Configuration Files

#### Android Permissions
The app requires these permissions (already configured in `AndroidManifest.xml`):
- `ACCESS_FINE_LOCATION` - For GPS location
- `ACCESS_COARSE_LOCATION` - For GPS location
- `CAMERA` - For taking photos
- `READ_EXTERNAL_STORAGE` - For selecting images
- `INTERNET` - For Firebase and Maps

#### iOS Permissions
The app requires these permissions (already configured in `Info.plist`):
- `NSLocationWhenInUseUsageDescription` - For GPS location
- `NSCameraUsageDescription` - For taking photos
- `NSPhotoLibraryUsageDescription` - For selecting images

## Key Dependencies

- **flutter_riverpod**: State management
- **supabase_flutter**: Authentication and database
- **flutter_map**: Map integration with MapTiler
- **latlong2**: Latitude/longitude calculations
- **geolocator**: GPS location services
- **image_picker**: Camera and gallery access
- **go_router**: Navigation
- **cached_network_image**: Image caching

## Usage

1. **Sign Up/Login**: Create an account or sign in with existing credentials
2. **View Reports**: See all community reports on the interactive map
3. **Create Report**: 
   - Tap the floating action button
   - Fill in title, category, and description
   - Take photos or select from gallery
   - Location is automatically captured
   - Submit the report
4. **Track Reports**: View your submitted reports and their status in "My Reports"
5. **Profile**: Manage your account and view app information

## Report Categories

- Pothole
- Street Light
- Garbage
- Graffiti
- Broken Sidewalk
- Other

## Report Statuses

- **Submitted**: Newly created report
- **In Progress**: Report is being addressed
- **Resolved**: Issue has been fixed
- **Rejected**: Report was declined

## Data Storage

Uses Supabase as the backend service for:
- User authentication and management
- Report data storage in PostgreSQL database
- Image storage in Supabase Storage
- Real-time updates and synchronization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For technical support or questions, please open an issue in the repository or contact your local government office for civic reporting assistance.
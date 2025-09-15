# 🏛️ Civic Reporter

**Empowering communities through intelligent civic engagement**

A comprehensive Flutter application that transforms how citizens report and track civic issues in their communities. Built with modern technology, offline-first architecture, and multilingual support to ensure every voice is heard.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🌟 **Why Civic Reporter?**

Traditional civic reporting systems fail communities through:
- **Language barriers** excluding diverse populations
- **Connectivity requirements** limiting rural access  
- **Complex interfaces** deterring citizen participation
- **Lack of transparency** in issue resolution

**Civic Reporter solves these problems with modern, inclusive technology.**

---

## ✨ **Key Features**

### 🔍 **Intelligent Discovery System**
- **Real-time Search**: Multi-field search across title, description, location, category, and importance
- **Advanced Filtering**: Category, importance, date range, and custom filters
- **Search History**: Smart suggestions from previous searches
- **Visual Results**: Results counter and active filter indicators

### 🌐 **Offline-First Architecture**
- **Report Anywhere**: Create reports without internet connection
- **Smart Sync**: Automatic synchronization when connectivity returns
- **Local Storage**: Secure offline data with Hive database
- **Connectivity Awareness**: Visual network status indicators

### 🗺️ **Location Intelligence**
- **GPS Integration**: Automatic location detection
- **Interactive Maps**: Visual representation of community issues
- **Address Autocomplete**: Smart location selection
- **Nearby Issues**: Discover reports in your area

### 🌍 **Multilingual Support**
- **4 Languages**: English, Hindi, Tamil, Telugu
- **Cultural Adaptation**: Localized content and terminology
- **Inclusive Design**: Accessible to diverse communities
- **Dynamic Switching**: Change language anytime

### 📱 **Modern User Experience**
- **Clean Interface**: Intuitive, professional design
- **Responsive Layout**: Works on all screen sizes
- **Dark/Light Themes**: Comfortable viewing in any condition
- **Accessibility**: Compliant with accessibility standards

### 🤝 **Community Engagement**
- **Transparent Tracking**: Follow your report from submission to resolution
- **Community Voting**: Upvote important issues for prioritization
- **Collaborative Discovery**: See what others are reporting
- **Personal Dashboard**: Manage your civic engagement

---

## 🏗️ **Technical Architecture**

### **Frontend**
- **Framework**: Flutter 3.0+ with Dart 3.0+
- **State Management**: Riverpod for reactive UI
- **Navigation**: Go Router for type-safe routing
- **UI Components**: Material Design 3 with custom theming

### **Backend & Data**
- **Backend**: Supabase for real-time data and authentication
- **Local Storage**: Hive for offline-first architecture
- **Image Handling**: Optimized photo compression and storage
- **Sync Engine**: Intelligent background synchronization

### **Core Services**
- **Location Services**: GPS integration with fallback options
- **Connectivity Monitoring**: Real-time network status tracking
- **Offline Storage**: Comprehensive local data management
- **Search Engine**: Advanced filtering and discovery system

---

## 🚀 **Quick Start**

### **Prerequisites**
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Git for version control

### **Installation**

1. **Clone the Repository**
   ```bash
   git clone https://github.com/hetemitkratos/Civic-care.git
   cd Civic-care
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Required Files**
   ```bash
   # Generate Hive adapters for offline storage
   flutter packages pub run build_runner build
   
   # Generate localization files
   flutter gen-l10n
   ```

4. **Configure Supabase**
   ```bash
   # Copy the configuration template
   cp lib/core/config/app_config.dart.example lib/core/config/app_config.dart
   
   # Edit app_config.dart with your Supabase credentials
   ```

5. **Set Up Database**
   ```bash
   # Run the SQL setup script in your Supabase dashboard
   # File: supabase_setup.sql
   ```

6. **Run the Application**
   ```bash
   # For development
   flutter run
   
   # For release build
   flutter build apk --release
   ```

---

## ⚙️ **Configuration**

### **Supabase Setup**

1. **Create a Supabase Project**
   - Visit [supabase.com](https://supabase.com)
   - Create a new project
   - Note your project URL and anon key

2. **Configure Database**
   ```sql
   -- Run the provided SQL script
   -- File: supabase_setup.sql
   ```

3. **Update Configuration**
   ```dart
   // lib/core/config/app_config.dart
   class AppConfig {
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   }
   ```

### **Environment Variables**
Create a `.env` file in the project root:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

---

## 📱 **Platform Support**

| Platform | Status | Notes |
|----------|--------|-------|
| **Android** | ✅ Fully Supported | API 21+ (Android 5.0+) |
| **iOS** | ✅ Fully Supported | iOS 12.0+ |
| **Web** | 🚧 In Development | Progressive Web App |
| **Desktop** | 🔄 Planned | Windows, macOS, Linux |

---

## 🧪 **Testing**

### **Run Tests**
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test/

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### **Code Quality**
```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Check for unused dependencies
flutter pub deps
```

---

## 📊 **Project Structure**

```
lib/
├── core/                          # Core functionality
│   ├── config/                    # App configuration
│   ├── models/                    # Data models
│   ├── services/                  # Core services
│   ├── theme/                     # App theming
│   └── widgets/                   # Reusable widgets
├── features/                      # Feature modules
│   ├── auth/                      # Authentication
│   ├── home/                      # Home dashboard
│   ├── navigation/                # App navigation
│   ├── profile/                   # User profile
│   └── reports/                   # Issue reporting
├── l10n/                          # Localization files
└── main.dart                      # App entry point
```

---

## 🤝 **Contributing**

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### **Development Workflow**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Code Standards**
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Write comprehensive tests for new features
- Update documentation for API changes
- Ensure all tests pass before submitting PR

---

## 📄 **Documentation**

- **[API Documentation](docs/api.md)** - Backend API reference
- **[Architecture Guide](docs/architecture.md)** - Technical architecture details
- **[Deployment Guide](docs/deployment.md)** - Production deployment instructions
- **[Contributing Guide](CONTRIBUTING.md)** - How to contribute to the project

---

## 🔒 **Security**

- **Data Encryption**: All sensitive data encrypted at rest and in transit
- **Authentication**: Secure user authentication with Supabase Auth
- **Privacy**: No personal data stored without explicit consent
- **Offline Security**: Local data protected with device security

For security concerns, please email: [security@civicreporter.com]

---

## 📈 **Roadmap**

### **Phase 1: Core Enhancement** (Q1 2024)
- [ ] Push notifications for status updates
- [ ] Advanced analytics dashboard
- [ ] AI-powered issue categorization
- [ ] Enhanced search capabilities

### **Phase 2: Integration** (Q2 2024)
- [ ] Government API integrations
- [ ] Third-party service connections
- [ ] Advanced reporting tools
- [ ] Community voting system

### **Phase 3: Scale** (Q3 2024)
- [ ] Multi-city platform
- [ ] Open data initiatives
- [ ] Predictive analytics
- [ ] Civic education modules

---

## 📞 **Support**

- **Documentation**: Check our comprehensive docs
- **Issues**: Report bugs on [GitHub Issues](https://github.com/hetemitkratos/Civic-care/issues)
- **Discussions**: Join our [GitHub Discussions](https://github.com/hetemitkratos/Civic-care/discussions)
- **Email**: Contact us at [support@civicreporter.com]

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 **Acknowledgments**

- **Flutter Team** for the amazing framework
- **Supabase** for the backend infrastructure
- **Community Contributors** for their valuable input
- **Beta Testers** for helping improve the app

---

## 🌟 **Star History**

[![Star History Chart](https://api.star-history.com/svg?repos=hetemitkratos/Civic-care&type=Date)](https://star-history.com/#hetemitkratos/Civic-care&Date)

---

**Built with ❤️ for stronger communities**

*Civic Reporter - Where every voice matters, every issue counts, and every community thrives.*
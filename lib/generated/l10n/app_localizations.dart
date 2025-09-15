import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ta'),
    Locale('te')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Civic Reporter'**
  String get appName;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Issues screen title
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get issues;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// All Issues screen title
  ///
  /// In en, this message translates to:
  /// **'All Issues'**
  String get allIssues;

  /// My Reports screen title
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// Report Issue button text
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// Default citizen name
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizen;

  /// Community help message
  ///
  /// In en, this message translates to:
  /// **'Ready to make your community better? Report issues, track progress, and engage with your neighbors.'**
  String get helpMakeCommunityBetter;

  /// Quick Actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Report new problem subtitle
  ///
  /// In en, this message translates to:
  /// **'Report a new civic problem'**
  String get reportNewProblem;

  /// View All Issues button text
  ///
  /// In en, this message translates to:
  /// **'View All Issues'**
  String get viewAllIssues;

  /// Browse community issues subtitle
  ///
  /// In en, this message translates to:
  /// **'Browse community issues'**
  String get browseCommunityIssues;

  /// Track submissions subtitle
  ///
  /// In en, this message translates to:
  /// **'Track your submissions'**
  String get trackSubmissions;

  /// Manage account subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your account'**
  String get manageAccount;

  /// Recent Activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// View All button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Community Highlights section title
  ///
  /// In en, this message translates to:
  /// **'Community Highlights'**
  String get communityHighlights;

  /// Total Issues stat title
  ///
  /// In en, this message translates to:
  /// **'Total Issues'**
  String get totalIssues;

  /// Resolved issues stat title
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// Critical issues stat title
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error text
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success text
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Importance field label
  ///
  /// In en, this message translates to:
  /// **'Importance'**
  String get importance;

  /// Location text
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Photos text
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// Submit Report button text
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// Did you know fact title
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get didYouKnow;

  /// Pothole category
  ///
  /// In en, this message translates to:
  /// **'Pothole'**
  String get pothole;

  /// Street Light category
  ///
  /// In en, this message translates to:
  /// **'Street Light'**
  String get streetLight;

  /// Garbage category
  ///
  /// In en, this message translates to:
  /// **'Garbage'**
  String get garbage;

  /// Graffiti category
  ///
  /// In en, this message translates to:
  /// **'Graffiti'**
  String get graffiti;

  /// Broken Sidewalk category
  ///
  /// In en, this message translates to:
  /// **'Broken Sidewalk'**
  String get brokenSidewalk;

  /// Other category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Low importance level
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// Medium importance level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// High importance level
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// Submitted status
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// In Progress status
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Rejected status
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// Sign In button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign Up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Language text
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Select language text
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Hindi language name in Hindi
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// Tamil language name in Tamil
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;

  /// Telugu language name in Telugu
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get telugu;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

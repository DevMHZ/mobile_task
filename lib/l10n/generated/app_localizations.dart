import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile Task'**
  String get appTitle;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get discover;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settings;

  /// No description provided for @eyebrow.
  ///
  /// In en, this message translates to:
  /// **'A SPACE FOR SOMETHING NEW'**
  String get eyebrow;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thoughtfully presented. Yours to explore.'**
  String get homeSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search something'**
  String get searchHint;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Our Recommendation'**
  String get collection;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get viewAll;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matching items'**
  String get noResults;

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another search or clear your filters.'**
  String get noResultsBody;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @offlineError.
  ///
  /// In en, this message translates to:
  /// **'You appear to be offline. Check your connection and try again.'**
  String get offlineError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get timeoutError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'The service is unavailable right now. Please try again.'**
  String get serverError;

  /// No description provided for @responseError.
  ///
  /// In en, this message translates to:
  /// **'We could not read the response. Please try again.'**
  String get responseError;

  /// No description provided for @storageError.
  ///
  /// In en, this message translates to:
  /// **'We could not access your saved preferences. Please try again.'**
  String get storageError;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading the collection'**
  String get loading;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @aboutItem.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get aboutItem;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @noRating.
  ///
  /// In en, this message translates to:
  /// **'Not rated yet'**
  String get noRating;

  /// No description provided for @saveItem.
  ///
  /// In en, this message translates to:
  /// **'Save item'**
  String get saveItem;

  /// No description provided for @removeSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeSaved;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved items'**
  String get savedTitle;

  /// No description provided for @savedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your favourites, together in one place.'**
  String get savedSubtitle;

  /// No description provided for @emptySaved.
  ///
  /// In en, this message translates to:
  /// **'Make room for your favourites'**
  String get emptySaved;

  /// No description provided for @emptySavedBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any item to find it here.'**
  String get emptySavedBody;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore the collection'**
  String get explore;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'ABOUT THIS DEMO'**
  String get aboutApp;

  /// No description provided for @demoTitle.
  ///
  /// In en, this message translates to:
  /// **'Real interface. Sample data.'**
  String get demoTitle;

  /// No description provided for @demoBody.
  ///
  /// In en, this message translates to:
  /// **'This assessment uses DummyJSON products in a blue, real-estate-inspired layout. Product names and descriptions are supplied in English.'**
  String get demoBody;

  /// No description provided for @simulationTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes last for this session'**
  String get simulationTitle;

  /// No description provided for @simulationBody.
  ///
  /// In en, this message translates to:
  /// **'Add, edit and delete are simulated. Changes are kept in memory and reset when the app restarts. Saved items and language are stored on this device.'**
  String get simulationBody;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage collection'**
  String get manage;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sort;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @priceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get priceLow;

  /// No description provided for @priceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get priceHigh;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get topRated;

  /// No description provided for @minPrice.
  ///
  /// In en, this message translates to:
  /// **'Minimum price (optional)'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In en, this message translates to:
  /// **'Maximum price (optional)'**
  String get maxPrice;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFilters;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative price.'**
  String get invalidPrice;

  /// No description provided for @invalidRange.
  ///
  /// In en, this message translates to:
  /// **'Maximum price must be at least the minimum.'**
  String get invalidRange;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get deleteItem;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL (https://...)'**
  String get imageUrl;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid HTTPS image URL.'**
  String get invalidUrl;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete item?'**
  String get deleteConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @demoNotice.
  ///
  /// In en, this message translates to:
  /// **'Simulated changes reset when you restart the app.'**
  String get demoNotice;

  /// No description provided for @changeSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved for this session'**
  String get changeSaved;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted for this session'**
  String get itemDeleted;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get loadMore;

  /// No description provided for @operationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Saving changes'**
  String get operationInProgress;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories are unavailable'**
  String get noCategories;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String resultCount(int count);

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @exploreTab.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTab;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your next favourite'**
  String get searchTitle;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @filterMin.
  ///
  /// In en, this message translates to:
  /// **'Min (optional)'**
  String get filterMin;

  /// No description provided for @filterMax.
  ///
  /// In en, this message translates to:
  /// **'Max (optional)'**
  String get filterMax;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @retryImage.
  ///
  /// In en, this message translates to:
  /// **'Retry image'**
  String get retryImage;

  /// No description provided for @imageRetryError.
  ///
  /// In en, this message translates to:
  /// **'We could not reload this image. Please try again.'**
  String get imageRetryError;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesBody.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved changes will be lost.'**
  String get discardChangesBody;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get discardChanges;

  /// No description provided for @imagePosition.
  ///
  /// In en, this message translates to:
  /// **'Image {index} of {total}'**
  String imagePosition(int index, int total);

  /// No description provided for @itemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Item no longer available'**
  String get itemUnavailable;

  /// No description provided for @itemRemovedBody.
  ///
  /// In en, this message translates to:
  /// **'This item was removed from this session. Return to the collection to continue browsing.'**
  String get itemRemovedBody;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Remove this item from your collection for this session.'**
  String get deleteConfirmBody;

  /// No description provided for @itemActions.
  ///
  /// In en, this message translates to:
  /// **'Item options'**
  String get itemActions;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get deleting;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @setFilter.
  ///
  /// In en, this message translates to:
  /// **'Set Filter'**
  String get setFilter;

  /// No description provided for @propertyType.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get propertyType;

  /// No description provided for @homeDetails.
  ///
  /// In en, this message translates to:
  /// **'Home Details'**
  String get homeDetails;

  /// No description provided for @bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get bedrooms;

  /// No description provided for @bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathrooms;

  /// No description provided for @buildingSize.
  ///
  /// In en, this message translates to:
  /// **'Building Size'**
  String get buildingSize;

  /// No description provided for @apartments.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get apartments;

  /// No description provided for @townhomes.
  ///
  /// In en, this message translates to:
  /// **'Townhomes'**
  String get townhomes;

  /// No description provided for @homes.
  ///
  /// In en, this message translates to:
  /// **'Homes'**
  String get homes;

  /// No description provided for @condos.
  ///
  /// In en, this message translates to:
  /// **'Condos'**
  String get condos;

  /// No description provided for @duplexes.
  ///
  /// In en, this message translates to:
  /// **'Duplexes'**
  String get duplexes;

  /// No description provided for @studios.
  ///
  /// In en, this message translates to:
  /// **'Studios'**
  String get studios;

  /// No description provided for @shareItem.
  ///
  /// In en, this message translates to:
  /// **'Share property'**
  String get shareItem;

  /// No description provided for @itemShared.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get itemShared;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

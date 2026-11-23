// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mobile Task';

  @override
  String get discover => 'Home';

  @override
  String get saved => 'Saved';

  @override
  String get settings => 'Profile';

  @override
  String get eyebrow => 'A SPACE FOR SOMETHING NEW';

  @override
  String get homeTitle => 'Welcome';

  @override
  String get homeSubtitle => 'Thoughtfully presented. Yours to explore.';

  @override
  String get searchHint => 'Search something';

  @override
  String get filters => 'Filters';

  @override
  String get all => 'All';

  @override
  String get collection => 'Our Recommendation';

  @override
  String get viewAll => 'See All';

  @override
  String get noResults => 'No matching items';

  @override
  String get noResultsBody => 'Try another search or clear your filters.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get retry => 'Try again';

  @override
  String get offlineError =>
      'You appear to be offline. Check your connection and try again.';

  @override
  String get timeoutError => 'The request took too long. Please try again.';

  @override
  String get serverError =>
      'The service is unavailable right now. Please try again.';

  @override
  String get responseError =>
      'We could not read the response. Please try again.';

  @override
  String get storageError =>
      'We could not access your saved preferences. Please try again.';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get loading => 'Loading the collection';

  @override
  String get refresh => 'Refresh';

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String get back => 'Back';

  @override
  String get details => 'Details';

  @override
  String get aboutItem => 'Overview';

  @override
  String get category => 'Category';

  @override
  String get price => 'Price';

  @override
  String get noRating => 'Not rated yet';

  @override
  String get saveItem => 'Save item';

  @override
  String get removeSaved => 'Remove from saved';

  @override
  String get savedTitle => 'Saved items';

  @override
  String get savedSubtitle => 'Your favourites, together in one place.';

  @override
  String get emptySaved => 'Make room for your favourites';

  @override
  String get emptySavedBody => 'Tap the heart on any item to find it here.';

  @override
  String get explore => 'Explore the collection';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get aboutApp => 'ABOUT THIS DEMO';

  @override
  String get demoTitle => 'Real interface. Sample data.';

  @override
  String get demoBody =>
      'This assessment uses DummyJSON products in a blue, real-estate-inspired layout. Product names and descriptions are supplied in English.';

  @override
  String get simulationTitle => 'Changes last for this session';

  @override
  String get simulationBody =>
      'Add, edit and delete are simulated. Changes are kept in memory and reset when the app restarts. Saved items and language are stored on this device.';

  @override
  String get manage => 'Manage collection';

  @override
  String get sort => 'Sort by';

  @override
  String get recommended => 'Recommended';

  @override
  String get priceLow => 'Price: low to high';

  @override
  String get priceHigh => 'Price: high to low';

  @override
  String get topRated => 'Top rated';

  @override
  String get minPrice => 'Minimum price (optional)';

  @override
  String get maxPrice => 'Maximum price (optional)';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get invalidPrice => 'Enter a valid non-negative price.';

  @override
  String get invalidRange => 'Maximum price must be at least the minimum.';

  @override
  String get addItem => 'Add item';

  @override
  String get editItem => 'Edit item';

  @override
  String get deleteItem => 'Delete item';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get imageUrl => 'Image URL (https://...)';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get cancel => 'Cancel';

  @override
  String get requiredField => 'This field is required.';

  @override
  String get invalidUrl => 'Enter a valid HTTPS image URL.';

  @override
  String get deleteConfirm => 'Delete item?';

  @override
  String get delete => 'Delete';

  @override
  String get demoNotice => 'Simulated changes reset when you restart the app.';

  @override
  String get changeSaved => 'Saved for this session';

  @override
  String get itemDeleted => 'Deleted for this session';

  @override
  String get browse => 'Browse';

  @override
  String get loadMore => 'Show more';

  @override
  String get operationInProgress => 'Saving changes';

  @override
  String get noCategories => 'Categories are unavailable';

  @override
  String get reset => 'Reset';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get featured => 'Featured';

  @override
  String get exploreTab => 'Explore';

  @override
  String get searchTitle => 'Find your next favourite';

  @override
  String get gallery => 'Gallery';

  @override
  String get priceRange => 'Price Range';

  @override
  String get filterMin => 'Min (optional)';

  @override
  String get filterMax => 'Max (optional)';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get retryImage => 'Retry image';

  @override
  String get imageRetryError =>
      'We could not reload this image. Please try again.';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesBody => 'Your unsaved changes will be lost.';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String imagePosition(int index, int total) {
    return 'Image $index of $total';
  }

  @override
  String get itemUnavailable => 'Item no longer available';

  @override
  String get itemRemovedBody =>
      'This item was removed from this session. Return to the collection to continue browsing.';

  @override
  String get deleteConfirmBody =>
      'Remove this item from your collection for this session.';

  @override
  String get itemActions => 'Item options';

  @override
  String get deleting => 'Deleting…';

  @override
  String get filter => 'Filter';

  @override
  String get setFilter => 'Set Filter';

  @override
  String get propertyType => 'Property Type';

  @override
  String get homeDetails => 'Home Details';

  @override
  String get bedrooms => 'Bedrooms';

  @override
  String get bathrooms => 'Bathrooms';

  @override
  String get buildingSize => 'Building Size';

  @override
  String get apartments => 'Apartments';

  @override
  String get townhomes => 'Townhomes';

  @override
  String get homes => 'Homes';

  @override
  String get condos => 'Condos';

  @override
  String get duplexes => 'Duplexes';

  @override
  String get studios => 'Studios';

  @override
  String get shareItem => 'Share property';

  @override
  String get itemShared => 'Item details copied to clipboard';

  @override
  String get simulatedPropertyNote =>
      'Property attributes are simulated deterministically from the product ID because DummyJSON has no real-estate fields.';

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get switchToArabic => 'Switch to Arabic';

  @override
  String get ltrDirection => 'LTR direction';

  @override
  String get rtlDirection => 'Right-to-left (RTL)';
}

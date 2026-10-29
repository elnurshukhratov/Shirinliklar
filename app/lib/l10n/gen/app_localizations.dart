import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
    Locale('ru'),
    Locale('uz')
  ];

  /// No description provided for @appTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shirinliklar'**
  String get appTitle;

  /// No description provided for @commonOk.
  ///
  /// In uz, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get commonEdit;

  /// No description provided for @commonRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get commonConfirm;

  /// No description provided for @commonBack.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get commonBack;

  /// No description provided for @commonSearch.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish'**
  String get commonSearch;

  /// No description provided for @commonLoading.
  ///
  /// In uz, this message translates to:
  /// **'Yuklanmoqda…'**
  String get commonLoading;

  /// No description provided for @fieldRequired.
  ///
  /// In uz, this message translates to:
  /// **'Bu maydonni to\'ldiring'**
  String get fieldRequired;

  /// No description provided for @emptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha bo\'sh'**
  String get emptyTitle;

  /// No description provided for @emptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Bu yerda hali hech narsa yo\'q.'**
  String get emptyMessage;

  /// No description provided for @noResultsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hech narsa topilmadi'**
  String get noResultsTitle;

  /// No description provided for @noResultsMessage.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa so\'z bilan qidirib ko\'ring.'**
  String get noResultsMessage;

  /// No description provided for @errorGenericTitle.
  ///
  /// In uz, this message translates to:
  /// **'Nimadir xato ketdi'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericMessage.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, birozdan keyin qayta urinib ko\'ring.'**
  String get errorGenericMessage;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo\'q'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkMessage.
  ///
  /// In uz, this message translates to:
  /// **'Ulanishni tekshirib, qayta urinib ko\'ring.'**
  String get errorNetworkMessage;

  /// No description provided for @errorServerTitle.
  ///
  /// In uz, this message translates to:
  /// **'Server javob bermayapti'**
  String get errorServerTitle;

  /// No description provided for @errorServerMessage.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik bizning tomonda. Birozdan keyin qayta urinib ko\'ring.'**
  String get errorServerMessage;

  /// No description provided for @errorUnauthorizedMessage.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish uchun qaytadan kiring.'**
  String get errorUnauthorizedMessage;

  /// No description provided for @errorForbiddenMessage.
  ///
  /// In uz, this message translates to:
  /// **'Sizda bu amal uchun ruxsat yo\'q.'**
  String get errorForbiddenMessage;

  /// No description provided for @errorNotFoundMessage.
  ///
  /// In uz, this message translates to:
  /// **'So\'ralgan ma\'lumot topilmadi.'**
  String get errorNotFoundMessage;

  /// No description provided for @errorLastAdminMessage.
  ///
  /// In uz, this message translates to:
  /// **'Siz oxirgi adminsiz, hisobni o\'chirib bo\'lmaydi.'**
  String get errorLastAdminMessage;

  /// No description provided for @errorActiveOrdersMessage.
  ///
  /// In uz, this message translates to:
  /// **'Faol buyurtmalaringiz bor. Ular yakunlangach hisobni o\'chirishingiz mumkin.'**
  String get errorActiveOrdersMessage;

  /// No description provided for @errorImageTypeMessage.
  ///
  /// In uz, this message translates to:
  /// **'Faqat JPG, PNG yoki WebP rasm yuklash mumkin.'**
  String get errorImageTypeMessage;

  /// No description provided for @errorImageSizeMessage.
  ///
  /// In uz, this message translates to:
  /// **'Rasm hajmi 5 MB dan oshmasligi kerak.'**
  String get errorImageSizeMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In uz, this message translates to:
  /// **'Mavzu'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In uz, this message translates to:
  /// **'Tizim'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In uz, this message translates to:
  /// **'Kun'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In uz, this message translates to:
  /// **'Tun'**
  String get themeDark;

  /// No description provided for @languageUz.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekcha'**
  String get languageUz;

  /// No description provided for @languageEn.
  ///
  /// In uz, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageRu.
  ///
  /// In uz, this message translates to:
  /// **'Русский'**
  String get languageRu;

  /// No description provided for @priceSum.
  ///
  /// In uz, this message translates to:
  /// **'{amount} so\'m'**
  String priceSum(String amount);

  /// No description provided for @piecesCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} dona'**
  String piecesCount(int count);

  /// No description provided for @authLoginTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz!'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Shirinliklarni tanlang, buyurtma bering va tayyor bo\'lganda olib keting.'**
  String get authLoginSubtitle;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In uz, this message translates to:
  /// **'Google orqali kirish'**
  String get authContinueWithGoogle;

  /// No description provided for @authSignInFailed.
  ///
  /// In uz, this message translates to:
  /// **'Kirib bo\'lmadi. Qayta urinib ko\'ring.'**
  String get authSignInFailed;

  /// No description provided for @authSignOut.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get authSignOut;

  /// No description provided for @onboardingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Keling, tanishamiz'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani tez rasmiylashtirish uchun ma\'lumotlaringizni bir marta kiriting.'**
  String get onboardingSubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profilni tahrirlash'**
  String get profileEditTitle;

  /// No description provided for @profileFirstName.
  ///
  /// In uz, this message translates to:
  /// **'Ism'**
  String get profileFirstName;

  /// No description provided for @profileLastName.
  ///
  /// In uz, this message translates to:
  /// **'Familiya'**
  String get profileLastName;

  /// No description provided for @profilePhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami'**
  String get profilePhone;

  /// No description provided for @profilePhoneHint.
  ///
  /// In uz, this message translates to:
  /// **'+998 90 123 45 67'**
  String get profilePhoneHint;

  /// No description provided for @profileAddress.
  ///
  /// In uz, this message translates to:
  /// **'Manzil'**
  String get profileAddress;

  /// No description provided for @profileAddressHint.
  ///
  /// In uz, this message translates to:
  /// **'Shahar, ko\'cha, uy'**
  String get profileAddressHint;

  /// No description provided for @profileLandmark.
  ///
  /// In uz, this message translates to:
  /// **'Mo\'ljal'**
  String get profileLandmark;

  /// No description provided for @profileLandmarkHint.
  ///
  /// In uz, this message translates to:
  /// **'Masalan, supermarket yonida'**
  String get profileLandmarkHint;

  /// No description provided for @profileNotSet.
  ///
  /// In uz, this message translates to:
  /// **'Kiritilmagan'**
  String get profileNotSet;

  /// No description provided for @profileSaved.
  ///
  /// In uz, this message translates to:
  /// **'Profil saqlandi'**
  String get profileSaved;

  /// No description provided for @profileRoleAdmin.
  ///
  /// In uz, this message translates to:
  /// **'Admin'**
  String get profileRoleAdmin;

  /// No description provided for @profileAdminPanel.
  ///
  /// In uz, this message translates to:
  /// **'Admin panel'**
  String get profileAdminPanel;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni o\'chirish'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni o\'chirasizmi?'**
  String get profileDeleteTitle;

  /// No description provided for @profileDeleteMessage.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy ma\'lumotlaringiz, sevimlilar va sharhlaringiz o\'chiriladi. Bu amalni qaytarib bo\'lmaydi.'**
  String get profileDeleteMessage;

  /// No description provided for @phoneInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqamini to\'g\'ri kiriting'**
  String get phoneInvalid;

  /// No description provided for @adminPanelTitle.
  ///
  /// In uz, this message translates to:
  /// **'Admin panel'**
  String get adminPanelTitle;

  /// No description provided for @adminPanelPlaceholder.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar va buyurtmalarni boshqarish bo\'limlari keyingi bosqichlarda qo\'shiladi.'**
  String get adminPanelPlaceholder;

  /// No description provided for @adminTabProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get adminTabProducts;

  /// No description provided for @adminTabCategories.
  ///
  /// In uz, this message translates to:
  /// **'Toifalar'**
  String get adminTabCategories;

  /// No description provided for @adminShowHidden.
  ///
  /// In uz, this message translates to:
  /// **'Yashirinlarni ko\'rsatish'**
  String get adminShowHidden;

  /// No description provided for @adminProductsEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar yo\'q'**
  String get adminProductsEmptyTitle;

  /// No description provided for @adminProductsEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi shirinlikni qo\'shing.'**
  String get adminProductsEmptyMessage;

  /// No description provided for @adminAddProduct.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot qo\'shish'**
  String get adminAddProduct;

  /// No description provided for @adminProductNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi mahsulot'**
  String get adminProductNew;

  /// No description provided for @adminProductEdit.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotni tahrirlash'**
  String get adminProductEdit;

  /// No description provided for @adminBadgeHidden.
  ///
  /// In uz, this message translates to:
  /// **'Yashirin'**
  String get adminBadgeHidden;

  /// No description provided for @adminBadgeOutOfStock.
  ///
  /// In uz, this message translates to:
  /// **'Tugagan'**
  String get adminBadgeOutOfStock;

  /// No description provided for @adminHide.
  ///
  /// In uz, this message translates to:
  /// **'Yashirish'**
  String get adminHide;

  /// No description provided for @adminShow.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rsatish'**
  String get adminShow;

  /// No description provided for @adminStockCount.
  ///
  /// In uz, this message translates to:
  /// **'Omborda: {count}'**
  String adminStockCount(int count);

  /// No description provided for @adminDeleteProductTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotni o\'chirasizmi?'**
  String get adminDeleteProductTitle;

  /// No description provided for @adminDeleteProductMessage.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot va uning rasmlari butunlay o\'chiriladi. Oldingi buyurtmalarda nomi saqlanib qoladi.'**
  String get adminDeleteProductMessage;

  /// No description provided for @adminProductSaved.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot saqlandi'**
  String get adminProductSaved;

  /// No description provided for @adminProductDeleted.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot o\'chirildi'**
  String get adminProductDeleted;

  /// No description provided for @adminFieldName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi'**
  String get adminFieldName;

  /// No description provided for @adminFieldDescription.
  ///
  /// In uz, this message translates to:
  /// **'Izoh'**
  String get adminFieldDescription;

  /// No description provided for @adminFieldIngredients.
  ///
  /// In uz, this message translates to:
  /// **'Tarkibi'**
  String get adminFieldIngredients;

  /// No description provided for @adminFieldAllergens.
  ///
  /// In uz, this message translates to:
  /// **'Allergenlar'**
  String get adminFieldAllergens;

  /// No description provided for @adminFieldPrice.
  ///
  /// In uz, this message translates to:
  /// **'Narxi (so\'m)'**
  String get adminFieldPrice;

  /// No description provided for @adminFieldStock.
  ///
  /// In uz, this message translates to:
  /// **'Omborda (dona)'**
  String get adminFieldStock;

  /// No description provided for @adminFieldCategory.
  ///
  /// In uz, this message translates to:
  /// **'Toifa'**
  String get adminFieldCategory;

  /// No description provided for @adminNoCategory.
  ///
  /// In uz, this message translates to:
  /// **'Toifasiz'**
  String get adminNoCategory;

  /// No description provided for @adminFieldVisible.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlarga ko\'rsatish'**
  String get adminFieldVisible;

  /// No description provided for @adminFillAllLanguages.
  ///
  /// In uz, this message translates to:
  /// **'Nomlarni uchala tilda to\'ldiring'**
  String get adminFillAllLanguages;

  /// No description provided for @adminNumberInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Raqamni to\'g\'ri kiriting'**
  String get adminNumberInvalid;

  /// No description provided for @adminImages.
  ///
  /// In uz, this message translates to:
  /// **'Rasmlar'**
  String get adminImages;

  /// No description provided for @adminImagesHint.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'pi bilan {count} ta rasm. Birinchisi asosiy bo\'ladi, tartibni o\'zgartirish uchun rasmni ushlab suring.'**
  String adminImagesHint(int count);

  /// No description provided for @adminMainImage.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy'**
  String get adminMainImage;

  /// No description provided for @adminVariants.
  ///
  /// In uz, this message translates to:
  /// **'Variantlar'**
  String get adminVariants;

  /// No description provided for @adminAddVariant.
  ///
  /// In uz, this message translates to:
  /// **'Variant qo\'shish'**
  String get adminAddVariant;

  /// No description provided for @adminVariantGroup.
  ///
  /// In uz, this message translates to:
  /// **'Turi'**
  String get adminVariantGroup;

  /// No description provided for @adminVariantSize.
  ///
  /// In uz, this message translates to:
  /// **'O\'lcham'**
  String get adminVariantSize;

  /// No description provided for @adminVariantCream.
  ///
  /// In uz, this message translates to:
  /// **'Krem turi'**
  String get adminVariantCream;

  /// No description provided for @adminVariantInscription.
  ///
  /// In uz, this message translates to:
  /// **'Yozuv'**
  String get adminVariantInscription;

  /// No description provided for @adminVariantName.
  ///
  /// In uz, this message translates to:
  /// **'Variant nomi'**
  String get adminVariantName;

  /// No description provided for @adminVariantPriceDelta.
  ///
  /// In uz, this message translates to:
  /// **'Narx farqi (so\'m)'**
  String get adminVariantPriceDelta;

  /// No description provided for @adminVariantPriceDeltaHint.
  ///
  /// In uz, this message translates to:
  /// **'Masalan, 20000 yoki -5000'**
  String get adminVariantPriceDeltaHint;

  /// No description provided for @adminCategoryNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi toifa'**
  String get adminCategoryNew;

  /// No description provided for @adminCategoryEdit.
  ///
  /// In uz, this message translates to:
  /// **'Toifani tahrirlash'**
  String get adminCategoryEdit;

  /// No description provided for @adminCategoriesEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Toifalar yo\'q'**
  String get adminCategoriesEmptyTitle;

  /// No description provided for @adminCategoriesEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlarni guruhlash uchun toifa qo\'shing.'**
  String get adminCategoriesEmptyMessage;

  /// No description provided for @adminAddCategory.
  ///
  /// In uz, this message translates to:
  /// **'Toifa qo\'shish'**
  String get adminAddCategory;

  /// No description provided for @adminCategoryProducts.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta mahsulot'**
  String adminCategoryProducts(int count);

  /// No description provided for @adminCategorySortOrder.
  ///
  /// In uz, this message translates to:
  /// **'Tartib raqami'**
  String get adminCategorySortOrder;

  /// No description provided for @adminCategoryDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Toifani o\'chirasizmi?'**
  String get adminCategoryDeleteTitle;

  /// No description provided for @adminCategoryDeleteMessage.
  ///
  /// In uz, this message translates to:
  /// **'Undagi mahsulotlar o\'chmaydi, toifasiz qoladi.'**
  String get adminCategoryDeleteMessage;

  /// No description provided for @adminCategorySaved.
  ///
  /// In uz, this message translates to:
  /// **'Toifa saqlandi'**
  String get adminCategorySaved;

  /// No description provided for @adminCategoryDeleted.
  ///
  /// In uz, this message translates to:
  /// **'Toifa o\'chirildi'**
  String get adminCategoryDeleted;

  /// No description provided for @catalogSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Shirinlik qidirish'**
  String get catalogSearchHint;

  /// No description provided for @catalogAllCategories.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi'**
  String get catalogAllCategories;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shirinliklar hali yo\'q'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Tez orada yangilari qo\'shiladi.'**
  String get catalogEmptyMessage;

  /// No description provided for @catalogOutOfStock.
  ///
  /// In uz, this message translates to:
  /// **'Tugagan'**
  String get catalogOutOfStock;

  /// No description provided for @productAddToCart.
  ///
  /// In uz, this message translates to:
  /// **'Savatga qo\'shish'**
  String get productAddToCart;

  /// No description provided for @productTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get productTotal;

  /// No description provided for @productDescription.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif'**
  String get productDescription;

  /// No description provided for @productIngredients.
  ///
  /// In uz, this message translates to:
  /// **'Tarkibi'**
  String get productIngredients;

  /// No description provided for @productAllergens.
  ///
  /// In uz, this message translates to:
  /// **'Allergenlar'**
  String get productAllergens;

  /// No description provided for @productNoReviews.
  ///
  /// In uz, this message translates to:
  /// **'Hali baho yo\'q'**
  String get productNoReviews;

  /// No description provided for @productReviewsCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta baho'**
  String productReviewsCount(int count);

  /// No description provided for @productInStock.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud: {count} dona'**
  String productInStock(int count);

  /// No description provided for @cartTitle.
  ///
  /// In uz, this message translates to:
  /// **'Savat'**
  String get cartTitle;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Savat bo\'sh'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Yoqqan shirinliklarni tanlab, savatga qo\'shing.'**
  String get cartEmptyMessage;

  /// No description provided for @cartGoToCatalog.
  ///
  /// In uz, this message translates to:
  /// **'Katalogga o\'tish'**
  String get cartGoToCatalog;

  /// No description provided for @cartAdded.
  ///
  /// In uz, this message translates to:
  /// **'Savatga qo\'shildi'**
  String get cartAdded;

  /// No description provided for @cartOpen.
  ///
  /// In uz, this message translates to:
  /// **'Savat'**
  String get cartOpen;

  /// No description provided for @cartStockLimit.
  ///
  /// In uz, this message translates to:
  /// **'Omborda faqat {count} dona bor'**
  String cartStockLimit(int count);

  /// No description provided for @cartRemovedNotice.
  ///
  /// In uz, this message translates to:
  /// **'Tugagan yoki yashirilgan mahsulotlar savatdan chiqarildi: {names}'**
  String cartRemovedNotice(String names);

  /// No description provided for @cartReducedNotice.
  ///
  /// In uz, this message translates to:
  /// **'Ba\'zi mahsulotlar miqdori ombordagi qoldiqqa moslab kamaytirildi.'**
  String get cartReducedNotice;

  /// No description provided for @cartRemoveItem.
  ///
  /// In uz, this message translates to:
  /// **'Savatdan olib tashlash'**
  String get cartRemoveItem;

  /// No description provided for @cartCheckout.
  ///
  /// In uz, this message translates to:
  /// **'Rasmiylashtirish'**
  String get cartCheckout;

  /// No description provided for @checkoutTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani rasmiylashtirish'**
  String get checkoutTitle;

  /// No description provided for @checkoutOrderSection.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmangiz'**
  String get checkoutOrderSection;

  /// No description provided for @checkoutScheduleSection.
  ///
  /// In uz, this message translates to:
  /// **'Qachonga kerak?'**
  String get checkoutScheduleSection;

  /// No description provided for @checkoutSchedulePick.
  ///
  /// In uz, this message translates to:
  /// **'Sana va vaqtni tanlang'**
  String get checkoutSchedulePick;

  /// No description provided for @checkoutScheduleRequired.
  ///
  /// In uz, this message translates to:
  /// **'Sana va vaqtni tanlang'**
  String get checkoutScheduleRequired;

  /// No description provided for @checkoutScheduleTooSoon.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma kamida {minutes} daqiqa oldin berilishi kerak'**
  String checkoutScheduleTooSoon(int minutes);

  /// No description provided for @checkoutFulfillmentSection.
  ///
  /// In uz, this message translates to:
  /// **'Qanday olasiz?'**
  String get checkoutFulfillmentSection;

  /// No description provided for @checkoutAddress.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazish manzili'**
  String get checkoutAddress;

  /// No description provided for @checkoutNote.
  ///
  /// In uz, this message translates to:
  /// **'Izoh'**
  String get checkoutNote;

  /// No description provided for @checkoutNoteHint.
  ///
  /// In uz, this message translates to:
  /// **'Masalan, yong\'oqsiz bo\'lsin'**
  String get checkoutNoteHint;

  /// No description provided for @checkoutPaymentSection.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usuli'**
  String get checkoutPaymentSection;

  /// No description provided for @checkoutSubtotal.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get checkoutSubtotal;

  /// No description provided for @checkoutDeliveryFee.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish'**
  String get checkoutDeliveryFee;

  /// No description provided for @checkoutPlaceOrder.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma berish'**
  String get checkoutPlaceOrder;

  /// No description provided for @fulfillmentPickup.
  ///
  /// In uz, this message translates to:
  /// **'Olib ketish'**
  String get fulfillmentPickup;

  /// No description provided for @fulfillmentDelivery.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish'**
  String get fulfillmentDelivery;

  /// No description provided for @paymentCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd to\'lov'**
  String get paymentCash;

  /// No description provided for @paymentOnline.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn to\'lov'**
  String get paymentOnline;

  /// No description provided for @orderStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get orderStatusPending;

  /// No description provided for @orderStatusAccepted.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilindi'**
  String get orderStatusAccepted;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilindi'**
  String get orderStatusCancelled;

  /// No description provided for @orderStatusReady.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get orderStatusReady;

  /// No description provided for @orderStatusOnTheWay.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lda'**
  String get orderStatusOnTheWay;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In uz, this message translates to:
  /// **'Topshirildi'**
  String get orderStatusDelivered;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma yuborildi!'**
  String get orderSuccessTitle;

  /// No description provided for @orderSuccessMessage.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon buyurtmani ko\'rib chiqib, tez orada tasdiqlaydi.'**
  String get orderSuccessMessage;

  /// No description provided for @orderNumber.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma №{number}'**
  String orderNumber(int number);

  /// No description provided for @orderScheduledFor.
  ///
  /// In uz, this message translates to:
  /// **'Qachonga'**
  String get orderScheduledFor;

  /// No description provided for @orderBackHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifaga'**
  String get orderBackHome;

  /// No description provided for @errorInvalidSchedule.
  ///
  /// In uz, this message translates to:
  /// **'Tanlangan vaqt mos emas. Boshqa vaqtni tanlang.'**
  String get errorInvalidSchedule;

  /// No description provided for @errorAddressRequired.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish uchun manzilni kiriting.'**
  String get errorAddressRequired;

  /// No description provided for @errorItemsChanged.
  ///
  /// In uz, this message translates to:
  /// **'Savatdagi ba\'zi mahsulotlar o\'zgargan. Savatni tekshirib, qaytadan urinib ko\'ring.'**
  String get errorItemsChanged;

  /// No description provided for @adminTabOrders.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar'**
  String get adminTabOrders;

  /// No description provided for @adminOrdersEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar yo\'q'**
  String get adminOrdersEmptyTitle;

  /// No description provided for @adminOrdersEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Yangi buyurtmalar shu yerda ko\'rinadi.'**
  String get adminOrdersEmptyMessage;

  /// No description provided for @adminOrdersFilterAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get adminOrdersFilterAll;

  /// No description provided for @adminOrderTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma №{number}'**
  String adminOrderTitle(int number);

  /// No description provided for @adminOrderCustomer.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz'**
  String get adminOrderCustomer;

  /// No description provided for @adminOrderDetails.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma tafsilotlari'**
  String get adminOrderDetails;

  /// No description provided for @adminOrderReceiving.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilish usuli'**
  String get adminOrderReceiving;

  /// No description provided for @adminOrderPayment.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usuli'**
  String get adminOrderPayment;

  /// No description provided for @adminOrderNote.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz izohi'**
  String get adminOrderNote;

  /// No description provided for @adminOrderCancelReasonTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish sababi'**
  String get adminOrderCancelReasonTitle;

  /// No description provided for @adminOrderItems.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get adminOrderItems;

  /// No description provided for @adminOrderSubtotal.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar summasi'**
  String get adminOrderSubtotal;

  /// No description provided for @adminOrderDeliveryFee.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish'**
  String get adminOrderDeliveryFee;

  /// No description provided for @adminOrderDiscount.
  ///
  /// In uz, this message translates to:
  /// **'Chegirma'**
  String get adminOrderDiscount;

  /// No description provided for @adminOrderTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get adminOrderTotal;

  /// No description provided for @adminOrderAccept.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilish'**
  String get adminOrderAccept;

  /// No description provided for @adminOrderMarkReady.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get adminOrderMarkReady;

  /// No description provided for @adminOrderMarkOnTheWay.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lda'**
  String get adminOrderMarkOnTheWay;

  /// No description provided for @adminOrderMarkDelivered.
  ///
  /// In uz, this message translates to:
  /// **'Topshirildi'**
  String get adminOrderMarkDelivered;

  /// No description provided for @adminOrderCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get adminOrderCancel;

  /// No description provided for @adminOrderCancelTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani bekor qilasizmi?'**
  String get adminOrderCancelTitle;

  /// No description provided for @adminOrderCancelMessage.
  ///
  /// In uz, this message translates to:
  /// **'Mijozga ko\'rinadigan sababni yozing. Mahsulotlar omborga qaytariladi.'**
  String get adminOrderCancelMessage;

  /// No description provided for @adminOrderCancelReasonLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sabab'**
  String get adminOrderCancelReasonLabel;

  /// No description provided for @adminOrderCancelConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get adminOrderCancelConfirm;

  /// No description provided for @adminOrderCashHint.
  ///
  /// In uz, this message translates to:
  /// **'Topshirilganda to\'lov «to\'langan» deb belgilanadi.'**
  String get adminOrderCashHint;

  /// No description provided for @adminOrderUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Holat yangilandi'**
  String get adminOrderUpdated;

  /// No description provided for @paymentStatusUnpaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'lanmagan'**
  String get paymentStatusUnpaid;

  /// No description provided for @paymentStatusPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan'**
  String get paymentStatusPaid;

  /// No description provided for @paymentStatusRefunded.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarilgan'**
  String get paymentStatusRefunded;

  /// No description provided for @errorInvalidTransition.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma holati allaqachon o\'zgargan. Ro\'yxatni yangilab ko\'ring.'**
  String get errorInvalidTransition;

  /// No description provided for @errorOrderNotCancellable.
  ///
  /// In uz, this message translates to:
  /// **'Bu buyurtmani endi bekor qilib bo\'lmaydi.'**
  String get errorOrderNotCancellable;

  /// No description provided for @myOrdersTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalarim'**
  String get myOrdersTitle;

  /// No description provided for @myOrdersEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hali buyurtma yo\'q'**
  String get myOrdersEmptyTitle;

  /// No description provided for @myOrdersEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi buyurtmangizni bering — shirinliklar kutmoqda.'**
  String get myOrdersEmptyMessage;

  /// No description provided for @myOrdersBrowse.
  ///
  /// In uz, this message translates to:
  /// **'Katalogga o\'tish'**
  String get myOrdersBrowse;

  /// No description provided for @myOrderItems.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get myOrderItems;

  /// No description provided for @myOrderSubtotal.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar summasi'**
  String get myOrderSubtotal;

  /// No description provided for @myOrderPaymentStatus.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov holati'**
  String get myOrderPaymentStatus;

  /// No description provided for @orderCancelAction.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani bekor qilish'**
  String get orderCancelAction;

  /// No description provided for @orderCancelTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani bekor qilasizmi?'**
  String get orderCancelTitle;

  /// No description provided for @orderCancelMessage.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma qabul qilinishidan oldin bekor qilish mumkin. Bu amalni qaytarib bo\'lmaydi.'**
  String get orderCancelMessage;

  /// No description provided for @orderCancelConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Ha, bekor qilish'**
  String get orderCancelConfirm;

  /// No description provided for @orderCancelKeep.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'q, qoldirish'**
  String get orderCancelKeep;

  /// No description provided for @orderCancelDone.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma bekor qilindi'**
  String get orderCancelDone;

  /// No description provided for @payTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov'**
  String get payTitle;

  /// No description provided for @payNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir to\'lash'**
  String get payNow;

  /// No description provided for @payPayOnline.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn to\'lash'**
  String get payPayOnline;

  /// No description provided for @payProceed.
  ///
  /// In uz, this message translates to:
  /// **'To\'lashga o\'tish'**
  String get payProceed;

  /// No description provided for @payReadyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Siz to\'lov sahifasiga o\'tkaziladi. To\'lovdan keyin ilovaga qayting.'**
  String get payReadyMessage;

  /// No description provided for @payOpening.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov sahifasi ochilmoqda…'**
  String get payOpening;

  /// No description provided for @payChecking.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov tekshirilmoqda…'**
  String get payChecking;

  /// No description provided for @payWaitingTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovni yakunlang'**
  String get payWaitingTitle;

  /// No description provided for @payWaitingMessage.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov sahifasida to\'lovni tugatib, ilovaga qayting. Holatni avtomatik tekshiramiz.'**
  String get payWaitingMessage;

  /// No description provided for @payCheck.
  ///
  /// In uz, this message translates to:
  /// **'Holatni tekshirish'**
  String get payCheck;

  /// No description provided for @payRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get payRetry;

  /// No description provided for @payPendingTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov hali tasdiqlanmadi'**
  String get payPendingTitle;

  /// No description provided for @payPendingMessage.
  ///
  /// In uz, this message translates to:
  /// **'Pul yechilmagan bo\'lsa, qayta urinib ko\'ring. Yechilgan bo\'lsa, birozdan keyin holatni tekshiring.'**
  String get payPendingMessage;

  /// No description provided for @paySuccessTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov qabul qilindi'**
  String get paySuccessTitle;

  /// No description provided for @paySuccessMessage.
  ///
  /// In uz, this message translates to:
  /// **'Rahmat! Buyurtmangiz to\'langan deb belgilandi.'**
  String get paySuccessMessage;

  /// No description provided for @payCannotOpen.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov sahifasini ochib bo\'lmadi.'**
  String get payCannotOpen;

  /// No description provided for @adminOrderRefund.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovni qaytarish'**
  String get adminOrderRefund;

  /// No description provided for @adminOrderRefundTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovni qaytarasizmi?'**
  String get adminOrderRefundTitle;

  /// No description provided for @adminOrderRefundMessage.
  ///
  /// In uz, this message translates to:
  /// **'Mijozning kartasiga to\'liq summa qaytariladi. Bu amalni qaytarib bo\'lmaydi.'**
  String get adminOrderRefundMessage;

  /// No description provided for @adminOrderRefundConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish'**
  String get adminOrderRefundConfirm;

  /// No description provided for @errorPaymentUnavailable.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn to\'lov hozircha mavjud emas. Keyinroq urinib ko\'ring.'**
  String get errorPaymentUnavailable;

  /// No description provided for @errorPaymentProvider.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov tizimi javob bermadi. Birozdan keyin qayta urinib ko\'ring.'**
  String get errorPaymentProvider;

  /// No description provided for @errorPaymentNotAllowed.
  ///
  /// In uz, this message translates to:
  /// **'Bu buyurtma uchun onlayn to\'lab bo\'lmaydi.'**
  String get errorPaymentNotAllowed;

  /// No description provided for @errorRefundNotAllowed.
  ///
  /// In uz, this message translates to:
  /// **'Bu to\'lovni qaytarib bo\'lmaydi.'**
  String get errorRefundNotAllowed;

  /// No description provided for @reviewsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sharhlar'**
  String get reviewsTitle;

  /// No description provided for @reviewsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Bu shirinlikka hali sharh yozilmagan.'**
  String get reviewsEmpty;

  /// No description provided for @reviewsShowMore.
  ///
  /// In uz, this message translates to:
  /// **'Yana ko\'rsatish'**
  String get reviewsShowMore;

  /// No description provided for @reviewsLeave.
  ///
  /// In uz, this message translates to:
  /// **'Baho va izoh qoldirish'**
  String get reviewsLeave;

  /// No description provided for @reviewsOnlyBuyers.
  ///
  /// In uz, this message translates to:
  /// **'Baho qoldirish uchun avval shu shirinlikni olgan bo\'lishingiz kerak.'**
  String get reviewsOnlyBuyers;

  /// No description provided for @reviewsYourReview.
  ///
  /// In uz, this message translates to:
  /// **'Sizning sharhingiz'**
  String get reviewsYourReview;

  /// No description provided for @reviewsYou.
  ///
  /// In uz, this message translates to:
  /// **'Siz'**
  String get reviewsYou;

  /// No description provided for @reviewsAnonymous.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz'**
  String get reviewsAnonymous;

  /// No description provided for @reviewsHiddenNotice.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon bu izohni yashirgan, boshqa mijozlarga ko\'rinmaydi.'**
  String get reviewsHiddenNotice;

  /// No description provided for @reviewsShopReply.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon javobi'**
  String get reviewsShopReply;

  /// No description provided for @reviewFormTitle.
  ///
  /// In uz, this message translates to:
  /// **'Baho va izoh'**
  String get reviewFormTitle;

  /// No description provided for @reviewFormEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sharhni tahrirlash'**
  String get reviewFormEditTitle;

  /// No description provided for @reviewFormRatingLabel.
  ///
  /// In uz, this message translates to:
  /// **'Bahoingiz'**
  String get reviewFormRatingLabel;

  /// No description provided for @reviewFormRatingRequired.
  ///
  /// In uz, this message translates to:
  /// **'Yulduzchani tanlang'**
  String get reviewFormRatingRequired;

  /// No description provided for @reviewFormTextLabel.
  ///
  /// In uz, this message translates to:
  /// **'Izoh (ixtiyoriy)'**
  String get reviewFormTextLabel;

  /// No description provided for @reviewFormTextHint.
  ///
  /// In uz, this message translates to:
  /// **'Shirinlik sizga qanday yoqdi?'**
  String get reviewFormTextHint;

  /// No description provided for @reviewFormSubmit.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get reviewFormSubmit;

  /// No description provided for @reviewFormSent.
  ///
  /// In uz, this message translates to:
  /// **'Rahmat! Sharhingiz qo\'shildi.'**
  String get reviewFormSent;

  /// No description provided for @reviewFormUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Sharh yangilandi.'**
  String get reviewFormUpdated;

  /// No description provided for @reviewFormNotAllowedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha mumkin emas'**
  String get reviewFormNotAllowedTitle;

  /// No description provided for @reviewDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sharhni o\'chirasizmi?'**
  String get reviewDeleteTitle;

  /// No description provided for @reviewDeleteMessage.
  ///
  /// In uz, this message translates to:
  /// **'Baho va izohingiz o\'chiriladi.'**
  String get reviewDeleteMessage;

  /// No description provided for @reviewDeleted.
  ///
  /// In uz, this message translates to:
  /// **'Sharh o\'chirildi.'**
  String get reviewDeleted;

  /// No description provided for @orderRateItem.
  ///
  /// In uz, this message translates to:
  /// **'Baho qoldirish'**
  String get orderRateItem;

  /// No description provided for @errorReviewNotAllowed.
  ///
  /// In uz, this message translates to:
  /// **'Faqat shu shirinlikni olgan mijoz sharh qoldira oladi.'**
  String get errorReviewNotAllowed;

  /// No description provided for @errorReviewExists.
  ///
  /// In uz, this message translates to:
  /// **'Siz bu shirinlikka allaqachon sharh yozgansiz.'**
  String get errorReviewExists;

  /// No description provided for @adminTabReviews.
  ///
  /// In uz, this message translates to:
  /// **'Izohlar'**
  String get adminTabReviews;

  /// No description provided for @adminReviewsFilterAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get adminReviewsFilterAll;

  /// No description provided for @adminReviewsFilterVisible.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rinadigan'**
  String get adminReviewsFilterVisible;

  /// No description provided for @adminReviewsFilterHidden.
  ///
  /// In uz, this message translates to:
  /// **'Yashirilgan'**
  String get adminReviewsFilterHidden;

  /// No description provided for @adminReviewsEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Izohlar yo\'q'**
  String get adminReviewsEmptyTitle;

  /// No description provided for @adminReviewsEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar baho qoldirganda shu yerda ko\'rinadi.'**
  String get adminReviewsEmptyMessage;

  /// No description provided for @adminReviewHiddenBadge.
  ///
  /// In uz, this message translates to:
  /// **'Yashirilgan'**
  String get adminReviewHiddenBadge;

  /// No description provided for @adminReviewHide.
  ///
  /// In uz, this message translates to:
  /// **'Yashirish'**
  String get adminReviewHide;

  /// No description provided for @adminReviewShow.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rsatish'**
  String get adminReviewShow;

  /// No description provided for @adminReviewHideTitle.
  ///
  /// In uz, this message translates to:
  /// **'Izohni yashirasizmi?'**
  String get adminReviewHideTitle;

  /// No description provided for @adminReviewHideMessage.
  ///
  /// In uz, this message translates to:
  /// **'Izoh mahsulot sahifasida ko\'rinmaydi va o\'rtacha bahoga kirmaydi.'**
  String get adminReviewHideMessage;

  /// No description provided for @adminReviewReply.
  ///
  /// In uz, this message translates to:
  /// **'Javob yozish'**
  String get adminReviewReply;

  /// No description provided for @adminReviewReplyEdit.
  ///
  /// In uz, this message translates to:
  /// **'Javobni tahrirlash'**
  String get adminReviewReplyEdit;

  /// No description provided for @adminReviewReplyDelete.
  ///
  /// In uz, this message translates to:
  /// **'Javobni o\'chirish'**
  String get adminReviewReplyDelete;

  /// No description provided for @adminReviewReplyHint.
  ///
  /// In uz, this message translates to:
  /// **'Mijozga javobingiz'**
  String get adminReviewReplyHint;

  /// No description provided for @adminReviewReplyDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Javobni o\'chirasizmi?'**
  String get adminReviewReplyDeleteTitle;

  /// No description provided for @adminReviewReplyDeleteMessage.
  ///
  /// In uz, this message translates to:
  /// **'Javob mahsulot sahifasidan olib tashlanadi.'**
  String get adminReviewReplyDeleteMessage;

  /// No description provided for @stockAlertNotifyMe.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud bo\'lganda xabar bering'**
  String get stockAlertNotifyMe;

  /// No description provided for @stockAlertSubscribed.
  ///
  /// In uz, this message translates to:
  /// **'Xabar beramiz ✓'**
  String get stockAlertSubscribed;

  /// No description provided for @stockAlertDone.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot qaytganda sizga xabar beramiz.'**
  String get stockAlertDone;

  /// No description provided for @stockAlertNoPermission.
  ///
  /// In uz, this message translates to:
  /// **'Obuna qo\'shildi, lekin bildirishnomalar o\'chirilgan. Xabar olish uchun ularni telefon sozlamalarida yoqing.'**
  String get stockAlertNoPermission;

  /// No description provided for @stockAlertCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Obuna bekor qilindi.'**
  String get stockAlertCancelled;

  /// No description provided for @storeClosedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugun buyurtma qabul qilinmaydi'**
  String get storeClosedTitle;

  /// No description provided for @storeClosedMessage.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon bugun yangi buyurtma olmayapti. Ertaga yana urinib ko\'ring.'**
  String get storeClosedMessage;

  /// No description provided for @adminStoreAccepting.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma qabul qilish'**
  String get adminStoreAccepting;

  /// No description provided for @adminStoreOpenHint.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar buyurtma bera oladi.'**
  String get adminStoreOpenHint;

  /// No description provided for @adminStorePausedHint.
  ///
  /// In uz, this message translates to:
  /// **'Bugun yangi buyurtma qabul qilinmaydi.'**
  String get adminStorePausedHint;

  /// No description provided for @adminStorePauseTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugun buyurtma qabul qilmaysizmi?'**
  String get adminStorePauseTitle;

  /// No description provided for @adminStorePauseMessage.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar yangi buyurtma bera olmaydi. Qabul qilish kun oxirigacha to\'xtatiladi, uni istalgan payt qayta yoqishingiz mumkin.'**
  String get adminStorePauseMessage;

  /// No description provided for @adminStorePauseConfirm.
  ///
  /// In uz, this message translates to:
  /// **'To\'xtatish'**
  String get adminStorePauseConfirm;

  /// No description provided for @errorOrdersPaused.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon bugun yangi buyurtma qabul qilmayapti.'**
  String get errorOrdersPaused;

  /// No description provided for @errorProductInStock.
  ///
  /// In uz, this message translates to:
  /// **'Bu mahsulot hozir mavjud, uni savatga qo\'shishingiz mumkin.'**
  String get errorProductInStock;

  /// No description provided for @favoritesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilar'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilar bo\'sh'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Yoqqan shirinlikdagi yurakchani bosing — u shu yerda saqlanadi.'**
  String get favoritesEmptyMessage;

  /// No description provided for @favoritesBrowse.
  ///
  /// In uz, this message translates to:
  /// **'Katalogni ochish'**
  String get favoritesBrowse;

  /// No description provided for @favoriteAdd.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilarga qo\'shish'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilardan olib tashlash'**
  String get favoriteRemove;

  /// No description provided for @orderReorderAction.
  ///
  /// In uz, this message translates to:
  /// **'Qayta buyurtma'**
  String get orderReorderAction;

  /// No description provided for @orderReorderDone.
  ///
  /// In uz, this message translates to:
  /// **'Shirinliklar savatga qo\'shildi'**
  String get orderReorderDone;

  /// No description provided for @orderReorderAdjusted.
  ///
  /// In uz, this message translates to:
  /// **'Savatga qo\'shildi, ba\'zilarining miqdori ombordagi qoldiqqa moslandi'**
  String get orderReorderAdjusted;

  /// No description provided for @orderReorderPartial.
  ///
  /// In uz, this message translates to:
  /// **'Savatga qo\'shildi. Mavjud emas: {names}'**
  String orderReorderPartial(String names);

  /// No description provided for @orderReorderNothing.
  ///
  /// In uz, this message translates to:
  /// **'Bu buyurtmadagi shirinliklar hozir mavjud emas'**
  String get orderReorderNothing;

  /// No description provided for @errorReorderNotAllowed.
  ///
  /// In uz, this message translates to:
  /// **'Qayta buyurtma faqat topshirilgan buyurtma uchun mumkin.'**
  String get errorReorderNotAllowed;

  /// No description provided for @profileRoleOwner.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon egasi'**
  String get profileRoleOwner;

  /// No description provided for @profileRoleStaff.
  ///
  /// In uz, this message translates to:
  /// **'Xodim'**
  String get profileRoleStaff;

  /// No description provided for @adminTabManage.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruv'**
  String get adminTabManage;

  /// No description provided for @adminManagePromosHint.
  ///
  /// In uz, this message translates to:
  /// **'Chegirma kodlarini yarating va nazorat qiling'**
  String get adminManagePromosHint;

  /// No description provided for @adminManageStaffHint.
  ///
  /// In uz, this message translates to:
  /// **'Xodim qo\'shing yoki olib tashlang'**
  String get adminManageStaffHint;

  /// No description provided for @adminStaffTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar'**
  String get adminStaffTitle;

  /// No description provided for @adminStaffHint.
  ///
  /// In uz, this message translates to:
  /// **'Xodim buyurtmalar, mahsulotlar va izohlar bilan ishlay oladi. Promokodlar, xodimlar, toifalarni o\'zgartirish, mahsulotni o\'chirish va pulni qaytarish faqat do\'kon egasiga ochiq.'**
  String get adminStaffHint;

  /// No description provided for @adminStaffAdd.
  ///
  /// In uz, this message translates to:
  /// **'Xodim qo\'shish'**
  String get adminStaffAdd;

  /// No description provided for @adminStaffAddHint.
  ///
  /// In uz, this message translates to:
  /// **'Xodimning Google akkaunti emailini kiriting. U shu akkaunt bilan kirgach, admin panelga ega bo\'ladi.'**
  String get adminStaffAddHint;

  /// No description provided for @adminStaffEmail.
  ///
  /// In uz, this message translates to:
  /// **'Email'**
  String get adminStaffEmail;

  /// No description provided for @adminStaffEmailInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Email noto\'g\'ri yozilgan'**
  String get adminStaffEmailInvalid;

  /// No description provided for @adminStaffAdded.
  ///
  /// In uz, this message translates to:
  /// **'Xodim qo\'shildi'**
  String get adminStaffAdded;

  /// No description provided for @adminStaffRemove.
  ///
  /// In uz, this message translates to:
  /// **'Olib tashlash'**
  String get adminStaffRemove;

  /// No description provided for @adminStaffRemoveTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xodimni olib tashlaysizmi?'**
  String get adminStaffRemoveTitle;

  /// No description provided for @adminStaffRemoveMessage.
  ///
  /// In uz, this message translates to:
  /// **'{email} admin panelga kira olmaydi. U oddiy mijoz sifatida qoladi.'**
  String adminStaffRemoveMessage(String email);

  /// No description provided for @adminStaffRemoved.
  ///
  /// In uz, this message translates to:
  /// **'Xodim olib tashlandi'**
  String get adminStaffRemoved;

  /// No description provided for @adminStaffNotSignedIn.
  ///
  /// In uz, this message translates to:
  /// **'Hali kirmagan'**
  String get adminStaffNotSignedIn;

  /// No description provided for @adminPromosTitle.
  ///
  /// In uz, this message translates to:
  /// **'Promokodlar'**
  String get adminPromosTitle;

  /// No description provided for @adminPromoAdd.
  ///
  /// In uz, this message translates to:
  /// **'Promokod qo\'shish'**
  String get adminPromoAdd;

  /// No description provided for @adminPromosEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Promokodlar yo\'q'**
  String get adminPromosEmptyTitle;

  /// No description provided for @adminPromosEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi promokodni yarating, mijozlar uni savatda kiritib chegirma oladi.'**
  String get adminPromosEmptyMessage;

  /// No description provided for @adminPromoNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi promokod'**
  String get adminPromoNew;

  /// No description provided for @adminPromoEdit.
  ///
  /// In uz, this message translates to:
  /// **'Promokodni tahrirlash'**
  String get adminPromoEdit;

  /// No description provided for @adminPromoCode.
  ///
  /// In uz, this message translates to:
  /// **'Kod'**
  String get adminPromoCode;

  /// No description provided for @adminPromoCodeInvalid.
  ///
  /// In uz, this message translates to:
  /// **'3–32 ta belgi: lotin harflari, raqamlar, tire yoki pastki chiziq'**
  String get adminPromoCodeInvalid;

  /// No description provided for @adminPromoDiscountType.
  ///
  /// In uz, this message translates to:
  /// **'Chegirma turi'**
  String get adminPromoDiscountType;

  /// No description provided for @adminPromoTypePercent.
  ///
  /// In uz, this message translates to:
  /// **'Foiz'**
  String get adminPromoTypePercent;

  /// No description provided for @adminPromoTypeAmount.
  ///
  /// In uz, this message translates to:
  /// **'Summa'**
  String get adminPromoTypeAmount;

  /// No description provided for @adminPromoValuePercent.
  ///
  /// In uz, this message translates to:
  /// **'Chegirma (%)'**
  String get adminPromoValuePercent;

  /// No description provided for @adminPromoValueAmount.
  ///
  /// In uz, this message translates to:
  /// **'Chegirma (so\'m)'**
  String get adminPromoValueAmount;

  /// No description provided for @adminPromoPercentInvalid.
  ///
  /// In uz, this message translates to:
  /// **'1 dan 100 gacha kiriting'**
  String get adminPromoPercentInvalid;

  /// No description provided for @adminPromoUsageLimit.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanish chegarasi'**
  String get adminPromoUsageLimit;

  /// No description provided for @adminPromoUnlimited.
  ///
  /// In uz, this message translates to:
  /// **'Cheklanmagan'**
  String get adminPromoUnlimited;

  /// No description provided for @adminPromoLimitInvalid.
  ///
  /// In uz, this message translates to:
  /// **'1 yoki undan katta son kiriting'**
  String get adminPromoLimitInvalid;

  /// No description provided for @adminPromoExpiry.
  ///
  /// In uz, this message translates to:
  /// **'Amal qilish muddati'**
  String get adminPromoExpiry;

  /// No description provided for @adminPromoNoExpiry.
  ///
  /// In uz, this message translates to:
  /// **'Muddatsiz'**
  String get adminPromoNoExpiry;

  /// No description provided for @adminPromoClearExpiry.
  ///
  /// In uz, this message translates to:
  /// **'Muddatni olib tashlash'**
  String get adminPromoClearExpiry;

  /// No description provided for @adminPromoActiveSwitch.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get adminPromoActiveSwitch;

  /// No description provided for @adminPromoSaved.
  ///
  /// In uz, this message translates to:
  /// **'Promokod saqlandi'**
  String get adminPromoSaved;

  /// No description provided for @adminPromoDeleted.
  ///
  /// In uz, this message translates to:
  /// **'Promokod o\'chirildi'**
  String get adminPromoDeleted;

  /// No description provided for @adminPromoDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Promokodni o\'chirasizmi?'**
  String get adminPromoDeleteTitle;

  /// No description provided for @adminPromoDeleteMessage.
  ///
  /// In uz, this message translates to:
  /// **'{code} kodi o\'chiriladi. Undan olingan chegirmali buyurtmalar saqlanib qoladi.'**
  String adminPromoDeleteMessage(String code);

  /// No description provided for @adminPromoPercentValue.
  ///
  /// In uz, this message translates to:
  /// **'{percent}%'**
  String adminPromoPercentValue(int percent);

  /// No description provided for @adminPromoDiscountLine.
  ///
  /// In uz, this message translates to:
  /// **'Chegirma: {discount}'**
  String adminPromoDiscountLine(String discount);

  /// No description provided for @adminPromoUsedCount.
  ///
  /// In uz, this message translates to:
  /// **'Ishlatilgan: {count}'**
  String adminPromoUsedCount(int count);

  /// No description provided for @adminPromoUsedOf.
  ///
  /// In uz, this message translates to:
  /// **'Ishlatilgan: {used} / {limit}'**
  String adminPromoUsedOf(int used, int limit);

  /// No description provided for @adminPromoExpiresOn.
  ///
  /// In uz, this message translates to:
  /// **'Muddati: {date} gacha'**
  String adminPromoExpiresOn(String date);

  /// No description provided for @adminPromoStatusActive.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get adminPromoStatusActive;

  /// No description provided for @adminPromoStatusInactive.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirilgan'**
  String get adminPromoStatusInactive;

  /// No description provided for @adminPromoStatusExpired.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o\'tgan'**
  String get adminPromoStatusExpired;

  /// No description provided for @adminPromoStatusExhausted.
  ///
  /// In uz, this message translates to:
  /// **'Tugagan'**
  String get adminPromoStatusExhausted;

  /// No description provided for @adminPromoEnable.
  ///
  /// In uz, this message translates to:
  /// **'Yoqish'**
  String get adminPromoEnable;

  /// No description provided for @adminPromoDisable.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirib qo\'yish'**
  String get adminPromoDisable;

  /// No description provided for @promoHint.
  ///
  /// In uz, this message translates to:
  /// **'Promokod'**
  String get promoHint;

  /// No description provided for @promoApply.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llash'**
  String get promoApply;

  /// No description provided for @promoApplied.
  ///
  /// In uz, this message translates to:
  /// **'Chegirma: −{amount}'**
  String promoApplied(String amount);

  /// No description provided for @promoRemove.
  ///
  /// In uz, this message translates to:
  /// **'Promokodni olib tashlash'**
  String get promoRemove;

  /// No description provided for @promoDiscountLabel.
  ///
  /// In uz, this message translates to:
  /// **'Promokod chegirmasi'**
  String get promoDiscountLabel;

  /// No description provided for @errorPromoNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Bunday promokod topilmadi yoki u faol emas.'**
  String get errorPromoNotFound;

  /// No description provided for @errorPromoExpired.
  ///
  /// In uz, this message translates to:
  /// **'Promokodning muddati tugagan.'**
  String get errorPromoExpired;

  /// No description provided for @errorPromoLimitReached.
  ///
  /// In uz, this message translates to:
  /// **'Bu promokod ishlatilish chegarasiga yetgan.'**
  String get errorPromoLimitReached;

  /// No description provided for @errorPromoExists.
  ///
  /// In uz, this message translates to:
  /// **'Bu kod bilan promokod allaqachon bor.'**
  String get errorPromoExists;

  /// No description provided for @errorStaffExists.
  ///
  /// In uz, this message translates to:
  /// **'Bu foydalanuvchi allaqachon xodim.'**
  String get errorStaffExists;

  /// No description provided for @errorStaffIsOwner.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon egasini xodim qilib bo\'lmaydi va olib tashlab bo\'lmaydi.'**
  String get errorStaffIsOwner;

  /// No description provided for @errorOwnerOnly.
  ///
  /// In uz, this message translates to:
  /// **'Bu amal faqat do\'kon egasiga ruxsat etilgan.'**
  String get errorOwnerOnly;

  /// No description provided for @adminManageStatsHint.
  ///
  /// In uz, this message translates to:
  /// **'Savdo, eng ko\'p sotilganlar va mijozlar'**
  String get adminManageStatsHint;

  /// No description provided for @adminStatsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Statistika'**
  String get adminStatsTitle;

  /// No description provided for @adminStatsTabSales.
  ///
  /// In uz, this message translates to:
  /// **'Savdo'**
  String get adminStatsTabSales;

  /// No description provided for @adminStatsTabTop.
  ///
  /// In uz, this message translates to:
  /// **'Eng ko\'p sotilgan'**
  String get adminStatsTabTop;

  /// No description provided for @adminStatsTabCustomers.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar'**
  String get adminStatsTabCustomers;

  /// No description provided for @adminStatsToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get adminStatsToday;

  /// No description provided for @adminStatsThisMonth.
  ///
  /// In uz, this message translates to:
  /// **'Shu oy'**
  String get adminStatsThisMonth;

  /// No description provided for @adminStatsDaily.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik'**
  String get adminStatsDaily;

  /// No description provided for @adminStatsMonthly.
  ///
  /// In uz, this message translates to:
  /// **'Oylik'**
  String get adminStatsMonthly;

  /// No description provided for @adminStatsLastDays.
  ///
  /// In uz, this message translates to:
  /// **'So\'nggi {count} kun'**
  String adminStatsLastDays(int count);

  /// No description provided for @adminStatsLastMonths.
  ///
  /// In uz, this message translates to:
  /// **'So\'nggi {count} oy'**
  String adminStatsLastMonths(int count);

  /// No description provided for @adminStatsOrdersCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta buyurtma'**
  String adminStatsOrdersCount(int count);

  /// No description provided for @adminStatsNote.
  ///
  /// In uz, this message translates to:
  /// **'Savdoga bekor qilingan va puli qaytarilgan buyurtmalar kirmaydi. Kunlar O\'zbekiston vaqti bo\'yicha hisoblanadi.'**
  String get adminStatsNote;

  /// No description provided for @adminStatsTopEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali sotuv yo\'q'**
  String get adminStatsTopEmpty;

  /// No description provided for @adminStatsTopEmptyHint.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi buyurtmalar kelgach, eng ko\'p sotilgan shirinliklar shu yerda chiqadi.'**
  String get adminStatsTopEmptyHint;

  /// No description provided for @adminStatsCustomersEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali mijozlar yo\'q'**
  String get adminStatsCustomersEmpty;

  /// No description provided for @adminStatsNoOrders.
  ///
  /// In uz, this message translates to:
  /// **'Hali buyurtma bermagan'**
  String get adminStatsNoOrders;

  /// No description provided for @adminStatsLastOrder.
  ///
  /// In uz, this message translates to:
  /// **'oxirgisi {date}'**
  String adminStatsLastOrder(String date);

  /// No description provided for @legalSectionTitle.
  ///
  /// In uz, this message translates to:
  /// **'Huquqiy ma\'lumot'**
  String get legalSectionTitle;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik siyosati'**
  String get legalPrivacyTitle;

  /// No description provided for @legalRefundTitle.
  ///
  /// In uz, this message translates to:
  /// **'Pulni qaytarish qoidalari'**
  String get legalRefundTitle;

  /// No description provided for @legalLastUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Yangilangan: {date}'**
  String legalLastUpdated(String date);

  /// No description provided for @offlineBanner.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo\'q. Ulanish qaytguncha ma\'lumotlar yangilanmaydi.'**
  String get offlineBanner;

  /// No description provided for @offlineBackOnline.
  ///
  /// In uz, this message translates to:
  /// **'Internet qayta ulandi'**
  String get offlineBackOnline;

  /// No description provided for @navHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifa'**
  String get navHome;

  /// No description provided for @homeFeatured.
  ///
  /// In uz, this message translates to:
  /// **'Tanlangan shirinliklar'**
  String get homeFeatured;

  /// No description provided for @settingsReduceTransparency.
  ///
  /// In uz, this message translates to:
  /// **'Shaffoflikni kamaytirish'**
  String get settingsReduceTransparency;

  /// No description provided for @settingsReduceTransparencyHint.
  ///
  /// In uz, this message translates to:
  /// **'Shisha effektini soddalashtiradi: blur o\'chadi, matn aniqroq ko\'rinadi.'**
  String get settingsReduceTransparencyHint;
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
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Shirinliklar';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonSave => 'Saqlash';

  @override
  String get commonDelete => 'O\'chirish';

  @override
  String get commonEdit => 'Tahrirlash';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get commonClose => 'Yopish';

  @override
  String get commonConfirm => 'Tasdiqlash';

  @override
  String get commonBack => 'Orqaga';

  @override
  String get commonSearch => 'Qidirish';

  @override
  String get commonLoading => 'Yuklanmoqda…';

  @override
  String get fieldRequired => 'Bu maydonni to\'ldiring';

  @override
  String get emptyTitle => 'Hozircha bo\'sh';

  @override
  String get emptyMessage => 'Bu yerda hali hech narsa yo\'q.';

  @override
  String get noResultsTitle => 'Hech narsa topilmadi';

  @override
  String get noResultsMessage => 'Boshqa so\'z bilan qidirib ko\'ring.';

  @override
  String get errorGenericTitle => 'Nimadir xato ketdi';

  @override
  String get errorGenericMessage =>
      'Iltimos, birozdan keyin qayta urinib ko\'ring.';

  @override
  String get errorNetworkTitle => 'Internet aloqasi yo\'q';

  @override
  String get errorNetworkMessage =>
      'Ulanishni tekshirib, qayta urinib ko\'ring.';

  @override
  String get errorServerTitle => 'Server javob bermayapti';

  @override
  String get errorServerMessage =>
      'Xatolik bizning tomonda. Birozdan keyin qayta urinib ko\'ring.';

  @override
  String get errorUnauthorizedMessage => 'Davom etish uchun qaytadan kiring.';

  @override
  String get errorForbiddenMessage => 'Sizda bu amal uchun ruxsat yo\'q.';

  @override
  String get errorNotFoundMessage => 'So\'ralgan ma\'lumot topilmadi.';

  @override
  String get errorLastAdminMessage =>
      'Siz oxirgi adminsiz, hisobni o\'chirib bo\'lmaydi.';

  @override
  String get errorActiveOrdersMessage =>
      'Faol buyurtmalaringiz bor. Ular yakunlangach hisobni o\'chirishingiz mumkin.';

  @override
  String get errorImageTypeMessage =>
      'Faqat JPG, PNG yoki WebP rasm yuklash mumkin.';

  @override
  String get errorImageSizeMessage => 'Rasm hajmi 5 MB dan oshmasligi kerak.';

  @override
  String get settingsTitle => 'Sozlamalar';

  @override
  String get settingsLanguage => 'Til';

  @override
  String get settingsTheme => 'Mavzu';

  @override
  String get themeSystem => 'Tizim';

  @override
  String get themeLight => 'Kun';

  @override
  String get themeDark => 'Tun';

  @override
  String get languageUz => 'O\'zbekcha';

  @override
  String get languageEn => 'English';

  @override
  String get languageRu => 'Русский';

  @override
  String priceSum(String amount) {
    return '$amount so\'m';
  }

  @override
  String piecesCount(int count) {
    return '$count dona';
  }

  @override
  String get authLoginTitle => 'Xush kelibsiz!';

  @override
  String get authLoginSubtitle =>
      'Shirinliklarni tanlang, buyurtma bering va tayyor bo\'lganda olib keting.';

  @override
  String get authContinueWithGoogle => 'Google orqali kirish';

  @override
  String get authSignInFailed => 'Kirib bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get authSignOut => 'Chiqish';

  @override
  String get onboardingTitle => 'Keling, tanishamiz';

  @override
  String get onboardingSubtitle =>
      'Buyurtmani tez rasmiylashtirish uchun ma\'lumotlaringizni bir marta kiriting.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileEditTitle => 'Profilni tahrirlash';

  @override
  String get profileFirstName => 'Ism';

  @override
  String get profileLastName => 'Familiya';

  @override
  String get profilePhone => 'Telefon raqami';

  @override
  String get profilePhoneHint => '+998 90 123 45 67';

  @override
  String get profileAddress => 'Manzil';

  @override
  String get profileAddressHint => 'Shahar, ko\'cha, uy';

  @override
  String get profileLandmark => 'Mo\'ljal';

  @override
  String get profileLandmarkHint => 'Masalan, supermarket yonida';

  @override
  String get profileNotSet => 'Kiritilmagan';

  @override
  String get profileSaved => 'Profil saqlandi';

  @override
  String get profileRoleAdmin => 'Admin';

  @override
  String get profileAdminPanel => 'Admin panel';

  @override
  String get profileDeleteAccount => 'Hisobni o\'chirish';

  @override
  String get profileDeleteTitle => 'Hisobni o\'chirasizmi?';

  @override
  String get profileDeleteMessage =>
      'Shaxsiy ma\'lumotlaringiz, sevimlilar va sharhlaringiz o\'chiriladi. Bu amalni qaytarib bo\'lmaydi.';

  @override
  String get phoneInvalid => 'Telefon raqamini to\'g\'ri kiriting';

  @override
  String get adminPanelTitle => 'Admin panel';

  @override
  String get adminPanelPlaceholder =>
      'Mahsulotlar va buyurtmalarni boshqarish bo\'limlari keyingi bosqichlarda qo\'shiladi.';

  @override
  String get adminTabProducts => 'Mahsulotlar';

  @override
  String get adminTabCategories => 'Toifalar';

  @override
  String get adminShowHidden => 'Yashirinlarni ko\'rsatish';

  @override
  String get adminProductsEmptyTitle => 'Mahsulotlar yo\'q';

  @override
  String get adminProductsEmptyMessage => 'Birinchi shirinlikni qo\'shing.';

  @override
  String get adminAddProduct => 'Mahsulot qo\'shish';

  @override
  String get adminProductNew => 'Yangi mahsulot';

  @override
  String get adminProductEdit => 'Mahsulotni tahrirlash';

  @override
  String get adminBadgeHidden => 'Yashirin';

  @override
  String get adminBadgeOutOfStock => 'Tugagan';

  @override
  String get adminHide => 'Yashirish';

  @override
  String get adminShow => 'Ko\'rsatish';

  @override
  String adminStockCount(int count) {
    return 'Omborda: $count';
  }

  @override
  String get adminDeleteProductTitle => 'Mahsulotni o\'chirasizmi?';

  @override
  String get adminDeleteProductMessage =>
      'Mahsulot va uning rasmlari butunlay o\'chiriladi. Oldingi buyurtmalarda nomi saqlanib qoladi.';

  @override
  String get adminProductSaved => 'Mahsulot saqlandi';

  @override
  String get adminProductDeleted => 'Mahsulot o\'chirildi';

  @override
  String get adminFieldName => 'Nomi';

  @override
  String get adminFieldDescription => 'Izoh';

  @override
  String get adminFieldIngredients => 'Tarkibi';

  @override
  String get adminFieldAllergens => 'Allergenlar';

  @override
  String get adminFieldPrice => 'Narxi (so\'m)';

  @override
  String get adminFieldStock => 'Omborda (dona)';

  @override
  String get adminFieldCategory => 'Toifa';

  @override
  String get adminNoCategory => 'Toifasiz';

  @override
  String get adminFieldVisible => 'Mijozlarga ko\'rsatish';

  @override
  String get adminFillAllLanguages => 'Nomlarni uchala tilda to\'ldiring';

  @override
  String get adminNumberInvalid => 'Raqamni to\'g\'ri kiriting';

  @override
  String get adminImages => 'Rasmlar';

  @override
  String adminImagesHint(int count) {
    return 'Ko\'pi bilan $count ta rasm. Birinchisi asosiy bo\'ladi, tartibni o\'zgartirish uchun rasmni ushlab suring.';
  }

  @override
  String get adminMainImage => 'Asosiy';

  @override
  String get adminVariants => 'Variantlar';

  @override
  String get adminAddVariant => 'Variant qo\'shish';

  @override
  String get adminVariantGroup => 'Turi';

  @override
  String get adminVariantSize => 'O\'lcham';

  @override
  String get adminVariantCream => 'Krem turi';

  @override
  String get adminVariantInscription => 'Yozuv';

  @override
  String get adminVariantName => 'Variant nomi';

  @override
  String get adminVariantPriceDelta => 'Narx farqi (so\'m)';

  @override
  String get adminVariantPriceDeltaHint => 'Masalan, 20000 yoki -5000';

  @override
  String get adminCategoryNew => 'Yangi toifa';

  @override
  String get adminCategoryEdit => 'Toifani tahrirlash';

  @override
  String get adminCategoriesEmptyTitle => 'Toifalar yo\'q';

  @override
  String get adminCategoriesEmptyMessage =>
      'Mahsulotlarni guruhlash uchun toifa qo\'shing.';

  @override
  String get adminAddCategory => 'Toifa qo\'shish';

  @override
  String adminCategoryProducts(int count) {
    return '$count ta mahsulot';
  }

  @override
  String get adminCategorySortOrder => 'Tartib raqami';

  @override
  String get adminCategoryDeleteTitle => 'Toifani o\'chirasizmi?';

  @override
  String get adminCategoryDeleteMessage =>
      'Undagi mahsulotlar o\'chmaydi, toifasiz qoladi.';

  @override
  String get adminCategorySaved => 'Toifa saqlandi';

  @override
  String get adminCategoryDeleted => 'Toifa o\'chirildi';

  @override
  String get catalogSearchHint => 'Shirinlik qidirish';

  @override
  String get catalogAllCategories => 'Hammasi';

  @override
  String get catalogEmptyTitle => 'Shirinliklar hali yo\'q';

  @override
  String get catalogEmptyMessage => 'Tez orada yangilari qo\'shiladi.';

  @override
  String get catalogOutOfStock => 'Tugagan';

  @override
  String get productAddToCart => 'Savatga qo\'shish';

  @override
  String get productTotal => 'Jami';

  @override
  String get productDescription => 'Tavsif';

  @override
  String get productIngredients => 'Tarkibi';

  @override
  String get productAllergens => 'Allergenlar';

  @override
  String get productNoReviews => 'Hali baho yo\'q';

  @override
  String productReviewsCount(int count) {
    return '$count ta baho';
  }

  @override
  String productInStock(int count) {
    return 'Mavjud: $count dona';
  }

  @override
  String get cartTitle => 'Savat';

  @override
  String get cartEmptyTitle => 'Savat bo\'sh';

  @override
  String get cartEmptyMessage =>
      'Yoqqan shirinliklarni tanlab, savatga qo\'shing.';

  @override
  String get cartGoToCatalog => 'Katalogga o\'tish';

  @override
  String get cartAdded => 'Savatga qo\'shildi';

  @override
  String get cartOpen => 'Savat';

  @override
  String cartStockLimit(int count) {
    return 'Omborda faqat $count dona bor';
  }

  @override
  String cartRemovedNotice(String names) {
    return 'Tugagan yoki yashirilgan mahsulotlar savatdan chiqarildi: $names';
  }

  @override
  String get cartReducedNotice =>
      'Ba\'zi mahsulotlar miqdori ombordagi qoldiqqa moslab kamaytirildi.';

  @override
  String get cartRemoveItem => 'Savatdan olib tashlash';

  @override
  String get cartCheckout => 'Rasmiylashtirish';

  @override
  String get checkoutTitle => 'Buyurtmani rasmiylashtirish';

  @override
  String get checkoutOrderSection => 'Buyurtmangiz';

  @override
  String get checkoutScheduleSection => 'Qachonga kerak?';

  @override
  String get checkoutSchedulePick => 'Sana va vaqtni tanlang';

  @override
  String get checkoutScheduleRequired => 'Sana va vaqtni tanlang';

  @override
  String checkoutScheduleTooSoon(int minutes) {
    return 'Buyurtma kamida $minutes daqiqa oldin berilishi kerak';
  }

  @override
  String get checkoutFulfillmentSection => 'Qanday olasiz?';

  @override
  String get checkoutAddress => 'Yetkazish manzili';

  @override
  String get checkoutNote => 'Izoh';

  @override
  String get checkoutNoteHint => 'Masalan, yong\'oqsiz bo\'lsin';

  @override
  String get checkoutPaymentSection => 'To\'lov usuli';

  @override
  String get checkoutSubtotal => 'Mahsulotlar';

  @override
  String get checkoutDeliveryFee => 'Yetkazib berish';

  @override
  String get checkoutPlaceOrder => 'Buyurtma berish';

  @override
  String get fulfillmentPickup => 'Olib ketish';

  @override
  String get fulfillmentDelivery => 'Yetkazib berish';

  @override
  String get paymentCash => 'Naqd to\'lov';

  @override
  String get paymentOnline => 'Onlayn to\'lov';

  @override
  String get orderStatusPending => 'Kutilmoqda';

  @override
  String get orderStatusAccepted => 'Qabul qilindi';

  @override
  String get orderStatusCancelled => 'Bekor qilindi';

  @override
  String get orderStatusReady => 'Tayyor';

  @override
  String get orderStatusOnTheWay => 'Yo\'lda';

  @override
  String get orderStatusDelivered => 'Topshirildi';

  @override
  String get orderSuccessTitle => 'Buyurtma yuborildi!';

  @override
  String get orderSuccessMessage =>
      'Do\'kon buyurtmani ko\'rib chiqib, tez orada tasdiqlaydi.';

  @override
  String orderNumber(int number) {
    return 'Buyurtma №$number';
  }

  @override
  String get orderScheduledFor => 'Qachonga';

  @override
  String get orderBackHome => 'Bosh sahifaga';

  @override
  String get errorInvalidSchedule =>
      'Tanlangan vaqt mos emas. Boshqa vaqtni tanlang.';

  @override
  String get errorAddressRequired => 'Yetkazib berish uchun manzilni kiriting.';

  @override
  String get errorItemsChanged =>
      'Savatdagi ba\'zi mahsulotlar o\'zgargan. Savatni tekshirib, qaytadan urinib ko\'ring.';

  @override
  String get adminTabOrders => 'Buyurtmalar';

  @override
  String get adminOrdersEmptyTitle => 'Buyurtmalar yo\'q';

  @override
  String get adminOrdersEmptyMessage =>
      'Yangi buyurtmalar shu yerda ko\'rinadi.';

  @override
  String get adminOrdersFilterAll => 'Barchasi';

  @override
  String adminOrderTitle(int number) {
    return 'Buyurtma №$number';
  }

  @override
  String get adminOrderCustomer => 'Mijoz';

  @override
  String get adminOrderDetails => 'Buyurtma tafsilotlari';

  @override
  String get adminOrderReceiving => 'Qabul qilish usuli';

  @override
  String get adminOrderPayment => 'To\'lov usuli';

  @override
  String get adminOrderNote => 'Mijoz izohi';

  @override
  String get adminOrderCancelReasonTitle => 'Bekor qilish sababi';

  @override
  String get adminOrderItems => 'Mahsulotlar';

  @override
  String get adminOrderSubtotal => 'Mahsulotlar summasi';

  @override
  String get adminOrderDeliveryFee => 'Yetkazib berish';

  @override
  String get adminOrderDiscount => 'Chegirma';

  @override
  String get adminOrderTotal => 'Jami';

  @override
  String get adminOrderAccept => 'Qabul qilish';

  @override
  String get adminOrderMarkReady => 'Tayyor';

  @override
  String get adminOrderMarkOnTheWay => 'Yo\'lda';

  @override
  String get adminOrderMarkDelivered => 'Topshirildi';

  @override
  String get adminOrderCancel => 'Bekor qilish';

  @override
  String get adminOrderCancelTitle => 'Buyurtmani bekor qilasizmi?';

  @override
  String get adminOrderCancelMessage =>
      'Mijozga ko\'rinadigan sababni yozing. Mahsulotlar omborga qaytariladi.';

  @override
  String get adminOrderCancelReasonLabel => 'Sabab';

  @override
  String get adminOrderCancelConfirm => 'Bekor qilish';

  @override
  String get adminOrderCashHint =>
      'Topshirilganda to\'lov «to\'langan» deb belgilanadi.';

  @override
  String get adminOrderUpdated => 'Holat yangilandi';

  @override
  String get paymentStatusUnpaid => 'To\'lanmagan';

  @override
  String get paymentStatusPaid => 'To\'langan';

  @override
  String get paymentStatusRefunded => 'Qaytarilgan';

  @override
  String get errorInvalidTransition =>
      'Buyurtma holati allaqachon o\'zgargan. Ro\'yxatni yangilab ko\'ring.';

  @override
  String get errorOrderNotCancellable =>
      'Bu buyurtmani endi bekor qilib bo\'lmaydi.';

  @override
  String get myOrdersTitle => 'Buyurtmalarim';

  @override
  String get myOrdersEmptyTitle => 'Hali buyurtma yo\'q';

  @override
  String get myOrdersEmptyMessage =>
      'Birinchi buyurtmangizni bering — shirinliklar kutmoqda.';

  @override
  String get myOrdersBrowse => 'Katalogga o\'tish';

  @override
  String get myOrderItems => 'Mahsulotlar';

  @override
  String get myOrderSubtotal => 'Mahsulotlar summasi';

  @override
  String get myOrderPaymentStatus => 'To\'lov holati';

  @override
  String get orderCancelAction => 'Buyurtmani bekor qilish';

  @override
  String get orderCancelTitle => 'Buyurtmani bekor qilasizmi?';

  @override
  String get orderCancelMessage =>
      'Buyurtma qabul qilinishidan oldin bekor qilish mumkin. Bu amalni qaytarib bo\'lmaydi.';

  @override
  String get orderCancelConfirm => 'Ha, bekor qilish';

  @override
  String get orderCancelKeep => 'Yo\'q, qoldirish';

  @override
  String get orderCancelDone => 'Buyurtma bekor qilindi';

  @override
  String get payTitle => 'To\'lov';

  @override
  String get payNow => 'Hozir to\'lash';

  @override
  String get payPayOnline => 'Onlayn to\'lash';

  @override
  String get payProceed => 'To\'lashga o\'tish';

  @override
  String get payReadyMessage =>
      'Siz to\'lov sahifasiga o\'tkaziladi. To\'lovdan keyin ilovaga qayting.';

  @override
  String get payOpening => 'To\'lov sahifasi ochilmoqda…';

  @override
  String get payChecking => 'To\'lov tekshirilmoqda…';

  @override
  String get payWaitingTitle => 'To\'lovni yakunlang';

  @override
  String get payWaitingMessage =>
      'To\'lov sahifasida to\'lovni tugatib, ilovaga qayting. Holatni avtomatik tekshiramiz.';

  @override
  String get payCheck => 'Holatni tekshirish';

  @override
  String get payRetry => 'Qayta urinish';

  @override
  String get payPendingTitle => 'To\'lov hali tasdiqlanmadi';

  @override
  String get payPendingMessage =>
      'Pul yechilmagan bo\'lsa, qayta urinib ko\'ring. Yechilgan bo\'lsa, birozdan keyin holatni tekshiring.';

  @override
  String get paySuccessTitle => 'To\'lov qabul qilindi';

  @override
  String get paySuccessMessage =>
      'Rahmat! Buyurtmangiz to\'langan deb belgilandi.';

  @override
  String get payCannotOpen => 'To\'lov sahifasini ochib bo\'lmadi.';

  @override
  String get adminOrderRefund => 'To\'lovni qaytarish';

  @override
  String get adminOrderRefundTitle => 'To\'lovni qaytarasizmi?';

  @override
  String get adminOrderRefundMessage =>
      'Mijozning kartasiga to\'liq summa qaytariladi. Bu amalni qaytarib bo\'lmaydi.';

  @override
  String get adminOrderRefundConfirm => 'Qaytarish';

  @override
  String get errorPaymentUnavailable =>
      'Onlayn to\'lov hozircha mavjud emas. Keyinroq urinib ko\'ring.';

  @override
  String get errorPaymentProvider =>
      'To\'lov tizimi javob bermadi. Birozdan keyin qayta urinib ko\'ring.';

  @override
  String get errorPaymentNotAllowed =>
      'Bu buyurtma uchun onlayn to\'lab bo\'lmaydi.';

  @override
  String get errorRefundNotAllowed => 'Bu to\'lovni qaytarib bo\'lmaydi.';

  @override
  String get reviewsTitle => 'Sharhlar';

  @override
  String get reviewsEmpty => 'Bu shirinlikka hali sharh yozilmagan.';

  @override
  String get reviewsShowMore => 'Yana ko\'rsatish';

  @override
  String get reviewsLeave => 'Baho va izoh qoldirish';

  @override
  String get reviewsOnlyBuyers =>
      'Baho qoldirish uchun avval shu shirinlikni olgan bo\'lishingiz kerak.';

  @override
  String get reviewsYourReview => 'Sizning sharhingiz';

  @override
  String get reviewsYou => 'Siz';

  @override
  String get reviewsAnonymous => 'Mijoz';

  @override
  String get reviewsHiddenNotice =>
      'Do\'kon bu izohni yashirgan, boshqa mijozlarga ko\'rinmaydi.';

  @override
  String get reviewsShopReply => 'Do\'kon javobi';

  @override
  String get reviewFormTitle => 'Baho va izoh';

  @override
  String get reviewFormEditTitle => 'Sharhni tahrirlash';

  @override
  String get reviewFormRatingLabel => 'Bahoingiz';

  @override
  String get reviewFormRatingRequired => 'Yulduzchani tanlang';

  @override
  String get reviewFormTextLabel => 'Izoh (ixtiyoriy)';

  @override
  String get reviewFormTextHint => 'Shirinlik sizga qanday yoqdi?';

  @override
  String get reviewFormSubmit => 'Yuborish';

  @override
  String get reviewFormSent => 'Rahmat! Sharhingiz qo\'shildi.';

  @override
  String get reviewFormUpdated => 'Sharh yangilandi.';

  @override
  String get reviewFormNotAllowedTitle => 'Hozircha mumkin emas';

  @override
  String get reviewDeleteTitle => 'Sharhni o\'chirasizmi?';

  @override
  String get reviewDeleteMessage => 'Baho va izohingiz o\'chiriladi.';

  @override
  String get reviewDeleted => 'Sharh o\'chirildi.';

  @override
  String get orderRateItem => 'Baho qoldirish';

  @override
  String get errorReviewNotAllowed =>
      'Faqat shu shirinlikni olgan mijoz sharh qoldira oladi.';

  @override
  String get errorReviewExists =>
      'Siz bu shirinlikka allaqachon sharh yozgansiz.';

  @override
  String get adminTabReviews => 'Izohlar';

  @override
  String get adminReviewsFilterAll => 'Barchasi';

  @override
  String get adminReviewsFilterVisible => 'Ko\'rinadigan';

  @override
  String get adminReviewsFilterHidden => 'Yashirilgan';

  @override
  String get adminReviewsEmptyTitle => 'Izohlar yo\'q';

  @override
  String get adminReviewsEmptyMessage =>
      'Mijozlar baho qoldirganda shu yerda ko\'rinadi.';

  @override
  String get adminReviewHiddenBadge => 'Yashirilgan';

  @override
  String get adminReviewHide => 'Yashirish';

  @override
  String get adminReviewShow => 'Ko\'rsatish';

  @override
  String get adminReviewHideTitle => 'Izohni yashirasizmi?';

  @override
  String get adminReviewHideMessage =>
      'Izoh mahsulot sahifasida ko\'rinmaydi va o\'rtacha bahoga kirmaydi.';

  @override
  String get adminReviewReply => 'Javob yozish';

  @override
  String get adminReviewReplyEdit => 'Javobni tahrirlash';

  @override
  String get adminReviewReplyDelete => 'Javobni o\'chirish';

  @override
  String get adminReviewReplyHint => 'Mijozga javobingiz';

  @override
  String get adminReviewReplyDeleteTitle => 'Javobni o\'chirasizmi?';

  @override
  String get adminReviewReplyDeleteMessage =>
      'Javob mahsulot sahifasidan olib tashlanadi.';

  @override
  String get stockAlertNotifyMe => 'Mavjud bo\'lganda xabar bering';

  @override
  String get stockAlertSubscribed => 'Xabar beramiz ✓';

  @override
  String get stockAlertDone => 'Mahsulot qaytganda sizga xabar beramiz.';

  @override
  String get stockAlertNoPermission =>
      'Obuna qo\'shildi, lekin bildirishnomalar o\'chirilgan. Xabar olish uchun ularni telefon sozlamalarida yoqing.';

  @override
  String get stockAlertCancelled => 'Obuna bekor qilindi.';

  @override
  String get storeClosedTitle => 'Bugun buyurtma qabul qilinmaydi';

  @override
  String get storeClosedMessage =>
      'Do\'kon bugun yangi buyurtma olmayapti. Ertaga yana urinib ko\'ring.';

  @override
  String get adminStoreAccepting => 'Buyurtma qabul qilish';

  @override
  String get adminStoreOpenHint => 'Mijozlar buyurtma bera oladi.';

  @override
  String get adminStorePausedHint => 'Bugun yangi buyurtma qabul qilinmaydi.';

  @override
  String get adminStorePauseTitle => 'Bugun buyurtma qabul qilmaysizmi?';

  @override
  String get adminStorePauseMessage =>
      'Mijozlar yangi buyurtma bera olmaydi. Qabul qilish kun oxirigacha to\'xtatiladi, uni istalgan payt qayta yoqishingiz mumkin.';

  @override
  String get adminStorePauseConfirm => 'To\'xtatish';

  @override
  String get errorOrdersPaused =>
      'Do\'kon bugun yangi buyurtma qabul qilmayapti.';

  @override
  String get errorProductInStock =>
      'Bu mahsulot hozir mavjud, uni savatga qo\'shishingiz mumkin.';

  @override
  String get favoritesTitle => 'Sevimlilar';

  @override
  String get favoritesEmptyTitle => 'Sevimlilar bo\'sh';

  @override
  String get favoritesEmptyMessage =>
      'Yoqqan shirinlikdagi yurakchani bosing — u shu yerda saqlanadi.';

  @override
  String get favoritesBrowse => 'Katalogni ochish';

  @override
  String get favoriteAdd => 'Sevimlilarga qo\'shish';

  @override
  String get favoriteRemove => 'Sevimlilardan olib tashlash';

  @override
  String get orderReorderAction => 'Qayta buyurtma';

  @override
  String get orderReorderDone => 'Shirinliklar savatga qo\'shildi';

  @override
  String get orderReorderAdjusted =>
      'Savatga qo\'shildi, ba\'zilarining miqdori ombordagi qoldiqqa moslandi';

  @override
  String orderReorderPartial(String names) {
    return 'Savatga qo\'shildi. Mavjud emas: $names';
  }

  @override
  String get orderReorderNothing =>
      'Bu buyurtmadagi shirinliklar hozir mavjud emas';

  @override
  String get errorReorderNotAllowed =>
      'Qayta buyurtma faqat topshirilgan buyurtma uchun mumkin.';

  @override
  String get profileRoleOwner => 'Do\'kon egasi';

  @override
  String get profileRoleStaff => 'Xodim';

  @override
  String get adminTabManage => 'Boshqaruv';

  @override
  String get adminManagePromosHint =>
      'Chegirma kodlarini yarating va nazorat qiling';

  @override
  String get adminManageStaffHint => 'Xodim qo\'shing yoki olib tashlang';

  @override
  String get adminStaffTitle => 'Xodimlar';

  @override
  String get adminStaffHint =>
      'Xodim buyurtmalar, mahsulotlar va izohlar bilan ishlay oladi. Promokodlar, xodimlar, toifalarni o\'zgartirish, mahsulotni o\'chirish va pulni qaytarish faqat do\'kon egasiga ochiq.';

  @override
  String get adminStaffAdd => 'Xodim qo\'shish';

  @override
  String get adminStaffAddHint =>
      'Xodimning Google akkaunti emailini kiriting. U shu akkaunt bilan kirgach, admin panelga ega bo\'ladi.';

  @override
  String get adminStaffEmail => 'Email';

  @override
  String get adminStaffEmailInvalid => 'Email noto\'g\'ri yozilgan';

  @override
  String get adminStaffAdded => 'Xodim qo\'shildi';

  @override
  String get adminStaffRemove => 'Olib tashlash';

  @override
  String get adminStaffRemoveTitle => 'Xodimni olib tashlaysizmi?';

  @override
  String adminStaffRemoveMessage(String email) {
    return '$email admin panelga kira olmaydi. U oddiy mijoz sifatida qoladi.';
  }

  @override
  String get adminStaffRemoved => 'Xodim olib tashlandi';

  @override
  String get adminStaffNotSignedIn => 'Hali kirmagan';

  @override
  String get adminPromosTitle => 'Promokodlar';

  @override
  String get adminPromoAdd => 'Promokod qo\'shish';

  @override
  String get adminPromosEmptyTitle => 'Promokodlar yo\'q';

  @override
  String get adminPromosEmptyMessage =>
      'Birinchi promokodni yarating, mijozlar uni savatda kiritib chegirma oladi.';

  @override
  String get adminPromoNew => 'Yangi promokod';

  @override
  String get adminPromoEdit => 'Promokodni tahrirlash';

  @override
  String get adminPromoCode => 'Kod';

  @override
  String get adminPromoCodeInvalid =>
      '3–32 ta belgi: lotin harflari, raqamlar, tire yoki pastki chiziq';

  @override
  String get adminPromoDiscountType => 'Chegirma turi';

  @override
  String get adminPromoTypePercent => 'Foiz';

  @override
  String get adminPromoTypeAmount => 'Summa';

  @override
  String get adminPromoValuePercent => 'Chegirma (%)';

  @override
  String get adminPromoValueAmount => 'Chegirma (so\'m)';

  @override
  String get adminPromoPercentInvalid => '1 dan 100 gacha kiriting';

  @override
  String get adminPromoUsageLimit => 'Foydalanish chegarasi';

  @override
  String get adminPromoUnlimited => 'Cheklanmagan';

  @override
  String get adminPromoLimitInvalid => '1 yoki undan katta son kiriting';

  @override
  String get adminPromoExpiry => 'Amal qilish muddati';

  @override
  String get adminPromoNoExpiry => 'Muddatsiz';

  @override
  String get adminPromoClearExpiry => 'Muddatni olib tashlash';

  @override
  String get adminPromoActiveSwitch => 'Faol';

  @override
  String get adminPromoSaved => 'Promokod saqlandi';

  @override
  String get adminPromoDeleted => 'Promokod o\'chirildi';

  @override
  String get adminPromoDeleteTitle => 'Promokodni o\'chirasizmi?';

  @override
  String adminPromoDeleteMessage(String code) {
    return '$code kodi o\'chiriladi. Undan olingan chegirmali buyurtmalar saqlanib qoladi.';
  }

  @override
  String adminPromoPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String adminPromoDiscountLine(String discount) {
    return 'Chegirma: $discount';
  }

  @override
  String adminPromoUsedCount(int count) {
    return 'Ishlatilgan: $count';
  }

  @override
  String adminPromoUsedOf(int used, int limit) {
    return 'Ishlatilgan: $used / $limit';
  }

  @override
  String adminPromoExpiresOn(String date) {
    return 'Muddati: $date gacha';
  }

  @override
  String get adminPromoStatusActive => 'Faol';

  @override
  String get adminPromoStatusInactive => 'O\'chirilgan';

  @override
  String get adminPromoStatusExpired => 'Muddati o\'tgan';

  @override
  String get adminPromoStatusExhausted => 'Tugagan';

  @override
  String get adminPromoEnable => 'Yoqish';

  @override
  String get adminPromoDisable => 'O\'chirib qo\'yish';

  @override
  String get promoHint => 'Promokod';

  @override
  String get promoApply => 'Qo\'llash';

  @override
  String promoApplied(String amount) {
    return 'Chegirma: −$amount';
  }

  @override
  String get promoRemove => 'Promokodni olib tashlash';

  @override
  String get promoDiscountLabel => 'Promokod chegirmasi';

  @override
  String get errorPromoNotFound =>
      'Bunday promokod topilmadi yoki u faol emas.';

  @override
  String get errorPromoExpired => 'Promokodning muddati tugagan.';

  @override
  String get errorPromoLimitReached =>
      'Bu promokod ishlatilish chegarasiga yetgan.';

  @override
  String get errorPromoExists => 'Bu kod bilan promokod allaqachon bor.';

  @override
  String get errorStaffExists => 'Bu foydalanuvchi allaqachon xodim.';

  @override
  String get errorStaffIsOwner =>
      'Do\'kon egasini xodim qilib bo\'lmaydi va olib tashlab bo\'lmaydi.';

  @override
  String get errorOwnerOnly => 'Bu amal faqat do\'kon egasiga ruxsat etilgan.';

  @override
  String get adminManageStatsHint => 'Savdo, eng ko\'p sotilganlar va mijozlar';

  @override
  String get adminStatsTitle => 'Statistika';

  @override
  String get adminStatsTabSales => 'Savdo';

  @override
  String get adminStatsTabTop => 'Eng ko\'p sotilgan';

  @override
  String get adminStatsTabCustomers => 'Mijozlar';

  @override
  String get adminStatsToday => 'Bugun';

  @override
  String get adminStatsThisMonth => 'Shu oy';

  @override
  String get adminStatsDaily => 'Kunlik';

  @override
  String get adminStatsMonthly => 'Oylik';

  @override
  String adminStatsLastDays(int count) {
    return 'So\'nggi $count kun';
  }

  @override
  String adminStatsLastMonths(int count) {
    return 'So\'nggi $count oy';
  }

  @override
  String adminStatsOrdersCount(int count) {
    return '$count ta buyurtma';
  }

  @override
  String get adminStatsNote =>
      'Savdoga bekor qilingan va puli qaytarilgan buyurtmalar kirmaydi. Kunlar O\'zbekiston vaqti bo\'yicha hisoblanadi.';

  @override
  String get adminStatsTopEmpty => 'Hali sotuv yo\'q';

  @override
  String get adminStatsTopEmptyHint =>
      'Birinchi buyurtmalar kelgach, eng ko\'p sotilgan shirinliklar shu yerda chiqadi.';

  @override
  String get adminStatsCustomersEmpty => 'Hali mijozlar yo\'q';

  @override
  String get adminStatsNoOrders => 'Hali buyurtma bermagan';

  @override
  String adminStatsLastOrder(String date) {
    return 'oxirgisi $date';
  }

  @override
  String get legalSectionTitle => 'Huquqiy ma\'lumot';

  @override
  String get legalPrivacyTitle => 'Maxfiylik siyosati';

  @override
  String get legalRefundTitle => 'Pulni qaytarish qoidalari';

  @override
  String legalLastUpdated(String date) {
    return 'Yangilangan: $date';
  }

  @override
  String get offlineBanner =>
      'Internet aloqasi yo\'q. Ulanish qaytguncha ma\'lumotlar yangilanmaydi.';

  @override
  String get offlineBackOnline => 'Internet qayta ulandi';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get homeFeatured => 'Tanlangan shirinliklar';

  @override
  String get settingsReduceTransparency => 'Shaffoflikni kamaytirish';

  @override
  String get settingsReduceTransparencyHint =>
      'Shisha effektini soddalashtiradi: blur o\'chadi, matn aniqroq ko\'rinadi.';

  @override
  String get authLoginButton => 'Kirish';

  @override
  String get authLoginField => 'Username yoki email';

  @override
  String get authUsername => 'Username';

  @override
  String get authUsernameHint => 'masalan, ali_2024';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Parol';

  @override
  String get authPasswordRepeat => 'Parolni takrorlang';

  @override
  String get authOr => 'yoki';

  @override
  String get authRegister => 'Ro\'yxatdan o\'tish';

  @override
  String get authRegisterTitle => 'Ro\'yxatdan o\'tish';

  @override
  String get authRegisterSubtitle =>
      'Ma\'lumotlaringizni kiriting — buyurtma berish oson bo\'ladi.';

  @override
  String get authAddressFromMap => 'Yashash joyi (xaritadan)';

  @override
  String get authAddressFromMapHint => 'Xaritadan joyni tanlang';

  @override
  String get mapPickerTitle => 'Yashash joyini tanlang';

  @override
  String get mapPickerConfirm => 'Shu manzilni tanlash';

  @override
  String get mapPickerLocating => 'Manzil aniqlanmoqda…';

  @override
  String get mapPickerMyLocation => 'Mening joylashuvim';

  @override
  String get mapPickerLocationFailed =>
      'Joylashuvni aniqlab bo\'lmadi. Xaritani surib tanlang.';

  @override
  String get usernameInvalid => '3–24 ta belgi: lotin harflari, raqam, _ va .';

  @override
  String get emailInvalid => 'Email manzilni to\'g\'ri kiriting';

  @override
  String get passwordTooShort => 'Parol kamida 8 ta belgidan iborat bo\'lsin';

  @override
  String get passwordMismatch => 'Parollar bir xil emas';

  @override
  String get errorInvalidCredentials => 'Username yoki parol noto\'g\'ri.';

  @override
  String get errorEmailTaken => 'Bu email allaqachon ro\'yxatdan o\'tgan.';

  @override
  String get errorUsernameTaken => 'Bu username band. Boshqasini tanlang.';

  @override
  String get errorTooManyRequests =>
      'Juda ko\'p urinish. Birozdan keyin qayta urinib ko\'ring.';
}

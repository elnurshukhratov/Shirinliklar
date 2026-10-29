// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shirinliklar';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get fieldRequired => 'Please fill in this field';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String get emptyMessage => 'There is nothing here for now.';

  @override
  String get noResultsTitle => 'Nothing found';

  @override
  String get noResultsMessage => 'Try a different search word.';

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get errorGenericMessage => 'Please try again in a moment.';

  @override
  String get errorNetworkTitle => 'No internet connection';

  @override
  String get errorNetworkMessage => 'Check your connection and try again.';

  @override
  String get errorServerTitle => 'Server is not responding';

  @override
  String get errorServerMessage =>
      'The problem is on our side. Please try again later.';

  @override
  String get errorUnauthorizedMessage => 'Please sign in again to continue.';

  @override
  String get errorForbiddenMessage =>
      'You don\'t have permission for this action.';

  @override
  String get errorNotFoundMessage => 'The requested data was not found.';

  @override
  String get errorLastAdminMessage =>
      'You are the last admin, so the account can\'t be deleted.';

  @override
  String get errorActiveOrdersMessage =>
      'You have active orders. You can delete your account once they are completed.';

  @override
  String get errorImageTypeMessage =>
      'Only JPG, PNG or WebP images can be uploaded.';

  @override
  String get errorImageSizeMessage => 'An image must not exceed 5 MB.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageUz => 'O\'zbekcha';

  @override
  String get languageEn => 'English';

  @override
  String get languageRu => 'Русский';

  @override
  String priceSum(String amount) {
    return '$amount UZS';
  }

  @override
  String piecesCount(int count) {
    return '$count pcs';
  }

  @override
  String get authLoginTitle => 'Welcome!';

  @override
  String get authLoginSubtitle =>
      'Pick your sweets, place an order and collect it when it\'s ready.';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authSignInFailed => 'Couldn\'t sign in. Please try again.';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get onboardingTitle => 'Let\'s get to know you';

  @override
  String get onboardingSubtitle =>
      'Enter your details once so checkout is quick.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileFirstName => 'First name';

  @override
  String get profileLastName => 'Last name';

  @override
  String get profilePhone => 'Phone number';

  @override
  String get profilePhoneHint => '+998 90 123 45 67';

  @override
  String get profileAddress => 'Address';

  @override
  String get profileAddressHint => 'City, street, building';

  @override
  String get profileLandmark => 'Landmark';

  @override
  String get profileLandmarkHint => 'E.g. next to the supermarket';

  @override
  String get profileNotSet => 'Not set';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileRoleAdmin => 'Admin';

  @override
  String get profileAdminPanel => 'Admin panel';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileDeleteTitle => 'Delete your account?';

  @override
  String get profileDeleteMessage =>
      'Your personal data, favorites and reviews will be deleted. This can\'t be undone.';

  @override
  String get phoneInvalid => 'Enter a valid phone number';

  @override
  String get adminPanelTitle => 'Admin panel';

  @override
  String get adminPanelPlaceholder =>
      'Product and order management sections will be added in the next stages.';

  @override
  String get adminTabProducts => 'Products';

  @override
  String get adminTabCategories => 'Categories';

  @override
  String get adminShowHidden => 'Show hidden';

  @override
  String get adminProductsEmptyTitle => 'No products yet';

  @override
  String get adminProductsEmptyMessage => 'Add your first sweet.';

  @override
  String get adminAddProduct => 'Add product';

  @override
  String get adminProductNew => 'New product';

  @override
  String get adminProductEdit => 'Edit product';

  @override
  String get adminBadgeHidden => 'Hidden';

  @override
  String get adminBadgeOutOfStock => 'Out of stock';

  @override
  String get adminHide => 'Hide';

  @override
  String get adminShow => 'Show';

  @override
  String adminStockCount(int count) {
    return 'In stock: $count';
  }

  @override
  String get adminDeleteProductTitle => 'Delete this product?';

  @override
  String get adminDeleteProductMessage =>
      'The product and its images will be deleted permanently. Its name stays in past orders.';

  @override
  String get adminProductSaved => 'Product saved';

  @override
  String get adminProductDeleted => 'Product deleted';

  @override
  String get adminFieldName => 'Name';

  @override
  String get adminFieldDescription => 'Description';

  @override
  String get adminFieldIngredients => 'Ingredients';

  @override
  String get adminFieldAllergens => 'Allergens';

  @override
  String get adminFieldPrice => 'Price (UZS)';

  @override
  String get adminFieldStock => 'In stock (pcs)';

  @override
  String get adminFieldCategory => 'Category';

  @override
  String get adminNoCategory => 'No category';

  @override
  String get adminFieldVisible => 'Visible to customers';

  @override
  String get adminFillAllLanguages =>
      'Fill in the names in all three languages';

  @override
  String get adminNumberInvalid => 'Enter a valid number';

  @override
  String get adminImages => 'Images';

  @override
  String adminImagesHint(int count) {
    return 'Up to $count images. The first one is the main image; press and hold to reorder.';
  }

  @override
  String get adminMainImage => 'Main';

  @override
  String get adminVariants => 'Variants';

  @override
  String get adminAddVariant => 'Add variant';

  @override
  String get adminVariantGroup => 'Type';

  @override
  String get adminVariantSize => 'Size';

  @override
  String get adminVariantCream => 'Cream type';

  @override
  String get adminVariantInscription => 'Inscription';

  @override
  String get adminVariantName => 'Variant name';

  @override
  String get adminVariantPriceDelta => 'Price difference (UZS)';

  @override
  String get adminVariantPriceDeltaHint => 'E.g. 20000 or -5000';

  @override
  String get adminCategoryNew => 'New category';

  @override
  String get adminCategoryEdit => 'Edit category';

  @override
  String get adminCategoriesEmptyTitle => 'No categories yet';

  @override
  String get adminCategoriesEmptyMessage =>
      'Add a category to group your products.';

  @override
  String get adminAddCategory => 'Add category';

  @override
  String adminCategoryProducts(int count) {
    return '$count products';
  }

  @override
  String get adminCategorySortOrder => 'Sort order';

  @override
  String get adminCategoryDeleteTitle => 'Delete this category?';

  @override
  String get adminCategoryDeleteMessage =>
      'Its products won\'t be deleted, they will just have no category.';

  @override
  String get adminCategorySaved => 'Category saved';

  @override
  String get adminCategoryDeleted => 'Category deleted';

  @override
  String get catalogSearchHint => 'Search sweets';

  @override
  String get catalogAllCategories => 'All';

  @override
  String get catalogEmptyTitle => 'No sweets yet';

  @override
  String get catalogEmptyMessage => 'New ones will be added soon.';

  @override
  String get catalogOutOfStock => 'Sold out';

  @override
  String get productAddToCart => 'Add to cart';

  @override
  String get productTotal => 'Total';

  @override
  String get productDescription => 'Description';

  @override
  String get productIngredients => 'Ingredients';

  @override
  String get productAllergens => 'Allergens';

  @override
  String get productNoReviews => 'No ratings yet';

  @override
  String productReviewsCount(int count) {
    return '$count ratings';
  }

  @override
  String productInStock(int count) {
    return 'In stock: $count';
  }

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyMessage =>
      'Pick some sweets you like and add them to the cart.';

  @override
  String get cartGoToCatalog => 'Browse sweets';

  @override
  String get cartAdded => 'Added to cart';

  @override
  String get cartOpen => 'Cart';

  @override
  String cartStockLimit(int count) {
    return 'Only $count in stock';
  }

  @override
  String cartRemovedNotice(String names) {
    return 'Sold out or hidden items were removed from your cart: $names';
  }

  @override
  String get cartReducedNotice =>
      'Some quantities were reduced to match what is in stock.';

  @override
  String get cartRemoveItem => 'Remove from cart';

  @override
  String get cartCheckout => 'Checkout';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutOrderSection => 'Your order';

  @override
  String get checkoutScheduleSection => 'When do you need it?';

  @override
  String get checkoutSchedulePick => 'Pick date and time';

  @override
  String get checkoutScheduleRequired => 'Please pick date and time';

  @override
  String checkoutScheduleTooSoon(int minutes) {
    return 'Orders must be placed at least $minutes minutes ahead';
  }

  @override
  String get checkoutFulfillmentSection => 'How would you like to get it?';

  @override
  String get checkoutAddress => 'Delivery address';

  @override
  String get checkoutNote => 'Comment';

  @override
  String get checkoutNoteHint => 'E.g. no nuts, please';

  @override
  String get checkoutPaymentSection => 'Payment method';

  @override
  String get checkoutSubtotal => 'Items';

  @override
  String get checkoutDeliveryFee => 'Delivery';

  @override
  String get checkoutPlaceOrder => 'Place order';

  @override
  String get fulfillmentPickup => 'Pickup';

  @override
  String get fulfillmentDelivery => 'Delivery';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentOnline => 'Online payment';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusAccepted => 'Accepted';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderStatusReady => 'Ready';

  @override
  String get orderStatusOnTheWay => 'On the way';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderSuccessTitle => 'Order sent!';

  @override
  String get orderSuccessMessage =>
      'The shop will review your order and confirm it shortly.';

  @override
  String orderNumber(int number) {
    return 'Order #$number';
  }

  @override
  String get orderScheduledFor => 'Scheduled for';

  @override
  String get orderBackHome => 'Back to home';

  @override
  String get errorInvalidSchedule =>
      'The selected time doesn\'t work. Please pick another one.';

  @override
  String get errorAddressRequired => 'Please enter a delivery address.';

  @override
  String get errorItemsChanged =>
      'Some items in your cart have changed. Check your cart and try again.';

  @override
  String get adminTabOrders => 'Orders';

  @override
  String get adminOrdersEmptyTitle => 'No orders';

  @override
  String get adminOrdersEmptyMessage => 'New orders will appear here.';

  @override
  String get adminOrdersFilterAll => 'All';

  @override
  String adminOrderTitle(int number) {
    return 'Order #$number';
  }

  @override
  String get adminOrderCustomer => 'Customer';

  @override
  String get adminOrderDetails => 'Order details';

  @override
  String get adminOrderReceiving => 'Fulfillment';

  @override
  String get adminOrderPayment => 'Payment method';

  @override
  String get adminOrderNote => 'Customer note';

  @override
  String get adminOrderCancelReasonTitle => 'Cancellation reason';

  @override
  String get adminOrderItems => 'Items';

  @override
  String get adminOrderSubtotal => 'Items total';

  @override
  String get adminOrderDeliveryFee => 'Delivery';

  @override
  String get adminOrderDiscount => 'Discount';

  @override
  String get adminOrderTotal => 'Total';

  @override
  String get adminOrderAccept => 'Accept';

  @override
  String get adminOrderMarkReady => 'Ready';

  @override
  String get adminOrderMarkOnTheWay => 'On the way';

  @override
  String get adminOrderMarkDelivered => 'Delivered';

  @override
  String get adminOrderCancel => 'Cancel order';

  @override
  String get adminOrderCancelTitle => 'Cancel this order?';

  @override
  String get adminOrderCancelMessage =>
      'Write a reason the customer will see. Items will be returned to stock.';

  @override
  String get adminOrderCancelReasonLabel => 'Reason';

  @override
  String get adminOrderCancelConfirm => 'Cancel order';

  @override
  String get adminOrderCashHint =>
      'The payment is marked as paid once the order is handed over.';

  @override
  String get adminOrderUpdated => 'Status updated';

  @override
  String get paymentStatusUnpaid => 'Unpaid';

  @override
  String get paymentStatusPaid => 'Paid';

  @override
  String get paymentStatusRefunded => 'Refunded';

  @override
  String get errorInvalidTransition =>
      'The order status has already changed. Try refreshing the list.';

  @override
  String get errorOrderNotCancellable =>
      'This order can no longer be cancelled.';

  @override
  String get myOrdersTitle => 'My orders';

  @override
  String get myOrdersEmptyTitle => 'No orders yet';

  @override
  String get myOrdersEmptyMessage =>
      'Place your first order — the sweets are waiting.';

  @override
  String get myOrdersBrowse => 'Browse the catalog';

  @override
  String get myOrderItems => 'Items';

  @override
  String get myOrderSubtotal => 'Items total';

  @override
  String get myOrderPaymentStatus => 'Payment status';

  @override
  String get orderCancelAction => 'Cancel order';

  @override
  String get orderCancelTitle => 'Cancel this order?';

  @override
  String get orderCancelMessage =>
      'You can cancel only before the order is accepted. This cannot be undone.';

  @override
  String get orderCancelConfirm => 'Yes, cancel';

  @override
  String get orderCancelKeep => 'No, keep it';

  @override
  String get orderCancelDone => 'Order cancelled';

  @override
  String get payTitle => 'Payment';

  @override
  String get payNow => 'Pay now';

  @override
  String get payPayOnline => 'Pay online';

  @override
  String get payProceed => 'Continue to payment';

  @override
  String get payReadyMessage =>
      'You will be taken to the payment page. Come back to the app afterwards.';

  @override
  String get payOpening => 'Opening the payment page…';

  @override
  String get payChecking => 'Checking the payment…';

  @override
  String get payWaitingTitle => 'Finish your payment';

  @override
  String get payWaitingMessage =>
      'Complete the payment on the payment page, then come back to the app. We will check the status automatically.';

  @override
  String get payCheck => 'Check status';

  @override
  String get payRetry => 'Try again';

  @override
  String get payPendingTitle => 'Payment not confirmed yet';

  @override
  String get payPendingMessage =>
      'If no money was charged, try again. If it was, check the status again in a moment.';

  @override
  String get paySuccessTitle => 'Payment received';

  @override
  String get paySuccessMessage => 'Thank you! Your order is marked as paid.';

  @override
  String get payCannotOpen => 'Could not open the payment page.';

  @override
  String get adminOrderRefund => 'Refund payment';

  @override
  String get adminOrderRefundTitle => 'Refund this payment?';

  @override
  String get adminOrderRefundMessage =>
      'The full amount will be returned to the customer\'s card. This cannot be undone.';

  @override
  String get adminOrderRefundConfirm => 'Refund';

  @override
  String get errorPaymentUnavailable =>
      'Online payment is not available right now. Please try again later.';

  @override
  String get errorPaymentProvider =>
      'The payment system did not respond. Please try again in a moment.';

  @override
  String get errorPaymentNotAllowed => 'This order cannot be paid online.';

  @override
  String get errorRefundNotAllowed => 'This payment cannot be refunded.';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String get reviewsEmpty => 'There are no reviews for this treat yet.';

  @override
  String get reviewsShowMore => 'Show more';

  @override
  String get reviewsLeave => 'Rate and review';

  @override
  String get reviewsOnlyBuyers =>
      'You can leave a rating after you have received this treat.';

  @override
  String get reviewsYourReview => 'Your review';

  @override
  String get reviewsYou => 'You';

  @override
  String get reviewsAnonymous => 'Customer';

  @override
  String get reviewsHiddenNotice =>
      'The shop has hidden this review, other customers cannot see it.';

  @override
  String get reviewsShopReply => 'Reply from the shop';

  @override
  String get reviewFormTitle => 'Rating and review';

  @override
  String get reviewFormEditTitle => 'Edit review';

  @override
  String get reviewFormRatingLabel => 'Your rating';

  @override
  String get reviewFormRatingRequired => 'Choose a star rating';

  @override
  String get reviewFormTextLabel => 'Review (optional)';

  @override
  String get reviewFormTextHint => 'How did you like it?';

  @override
  String get reviewFormSubmit => 'Submit';

  @override
  String get reviewFormSent => 'Thank you! Your review was added.';

  @override
  String get reviewFormUpdated => 'Review updated.';

  @override
  String get reviewFormNotAllowedTitle => 'Not available yet';

  @override
  String get reviewDeleteTitle => 'Delete review?';

  @override
  String get reviewDeleteMessage => 'Your rating and review will be deleted.';

  @override
  String get reviewDeleted => 'Review deleted.';

  @override
  String get orderRateItem => 'Leave a rating';

  @override
  String get errorReviewNotAllowed =>
      'Only customers who received this treat can leave a review.';

  @override
  String get errorReviewExists => 'You have already reviewed this treat.';

  @override
  String get adminTabReviews => 'Reviews';

  @override
  String get adminReviewsFilterAll => 'All';

  @override
  String get adminReviewsFilterVisible => 'Visible';

  @override
  String get adminReviewsFilterHidden => 'Hidden';

  @override
  String get adminReviewsEmptyTitle => 'No reviews';

  @override
  String get adminReviewsEmptyMessage => 'Customer ratings will appear here.';

  @override
  String get adminReviewHiddenBadge => 'Hidden';

  @override
  String get adminReviewHide => 'Hide';

  @override
  String get adminReviewShow => 'Show';

  @override
  String get adminReviewHideTitle => 'Hide this review?';

  @override
  String get adminReviewHideMessage =>
      'It will not be shown on the product page or counted in the average rating.';

  @override
  String get adminReviewReply => 'Write a reply';

  @override
  String get adminReviewReplyEdit => 'Edit reply';

  @override
  String get adminReviewReplyDelete => 'Delete reply';

  @override
  String get adminReviewReplyHint => 'Your reply to the customer';

  @override
  String get adminReviewReplyDeleteTitle => 'Delete reply?';

  @override
  String get adminReviewReplyDeleteMessage =>
      'The reply will be removed from the product page.';

  @override
  String get stockAlertNotifyMe => 'Notify me when available';

  @override
  String get stockAlertSubscribed => 'We\'ll let you know ✓';

  @override
  String get stockAlertDone => 'We\'ll notify you when it\'s back in stock.';

  @override
  String get stockAlertNoPermission =>
      'Subscribed, but notifications are turned off. Enable them in your phone settings to get the message.';

  @override
  String get stockAlertCancelled => 'Subscription cancelled.';

  @override
  String get storeClosedTitle => 'No orders today';

  @override
  String get storeClosedMessage =>
      'The shop is not accepting new orders today. Please try again tomorrow.';

  @override
  String get adminStoreAccepting => 'Accepting orders';

  @override
  String get adminStoreOpenHint => 'Customers can place orders.';

  @override
  String get adminStorePausedHint => 'New orders are not accepted today.';

  @override
  String get adminStorePauseTitle => 'Stop accepting orders today?';

  @override
  String get adminStorePauseMessage =>
      'Customers will not be able to place new orders. This lasts until the end of the day, and you can turn it back on at any time.';

  @override
  String get adminStorePauseConfirm => 'Stop';

  @override
  String get errorOrdersPaused => 'The shop is not accepting new orders today.';

  @override
  String get errorProductInStock =>
      'This treat is available now, you can add it to the cart.';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyMessage =>
      'Tap the heart on a treat you like and it will be saved here.';

  @override
  String get favoritesBrowse => 'Browse the catalog';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String get orderReorderAction => 'Reorder';

  @override
  String get orderReorderDone => 'Treats added to your cart';

  @override
  String get orderReorderAdjusted =>
      'Added to your cart; some quantities were reduced to what\'s in stock';

  @override
  String orderReorderPartial(String names) {
    return 'Added to your cart. Not available: $names';
  }

  @override
  String get orderReorderNothing =>
      'None of the treats from this order are available right now';

  @override
  String get errorReorderNotAllowed =>
      'You can only reorder after an order has been delivered.';

  @override
  String get profileRoleOwner => 'Store owner';

  @override
  String get profileRoleStaff => 'Staff';

  @override
  String get adminTabManage => 'Manage';

  @override
  String get adminManagePromosHint => 'Create and track discount codes';

  @override
  String get adminManageStaffHint => 'Add or remove staff members';

  @override
  String get adminStaffTitle => 'Staff';

  @override
  String get adminStaffHint =>
      'Staff can work with orders, products and reviews. Promo codes, staff, editing categories, deleting products and refunds are available to the store owner only.';

  @override
  String get adminStaffAdd => 'Add staff member';

  @override
  String get adminStaffAddHint =>
      'Enter the email of their Google account. Once they sign in with it, they get access to the admin panel.';

  @override
  String get adminStaffEmail => 'Email';

  @override
  String get adminStaffEmailInvalid => 'The email looks incorrect';

  @override
  String get adminStaffAdded => 'Staff member added';

  @override
  String get adminStaffRemove => 'Remove';

  @override
  String get adminStaffRemoveTitle => 'Remove this staff member?';

  @override
  String adminStaffRemoveMessage(String email) {
    return '$email will lose access to the admin panel and stay as a regular customer.';
  }

  @override
  String get adminStaffRemoved => 'Staff member removed';

  @override
  String get adminStaffNotSignedIn => 'Hasn\'t signed in yet';

  @override
  String get adminPromosTitle => 'Promo codes';

  @override
  String get adminPromoAdd => 'Add promo code';

  @override
  String get adminPromosEmptyTitle => 'No promo codes yet';

  @override
  String get adminPromosEmptyMessage =>
      'Create your first promo code — customers enter it in the cart to get a discount.';

  @override
  String get adminPromoNew => 'New promo code';

  @override
  String get adminPromoEdit => 'Edit promo code';

  @override
  String get adminPromoCode => 'Code';

  @override
  String get adminPromoCodeInvalid =>
      '3–32 characters: Latin letters, digits, hyphen or underscore';

  @override
  String get adminPromoDiscountType => 'Discount type';

  @override
  String get adminPromoTypePercent => 'Percent';

  @override
  String get adminPromoTypeAmount => 'Amount';

  @override
  String get adminPromoValuePercent => 'Discount (%)';

  @override
  String get adminPromoValueAmount => 'Discount (UZS)';

  @override
  String get adminPromoPercentInvalid => 'Enter a value from 1 to 100';

  @override
  String get adminPromoUsageLimit => 'Usage limit';

  @override
  String get adminPromoUnlimited => 'Unlimited';

  @override
  String get adminPromoLimitInvalid => 'Enter 1 or more';

  @override
  String get adminPromoExpiry => 'Valid until';

  @override
  String get adminPromoNoExpiry => 'No expiry date';

  @override
  String get adminPromoClearExpiry => 'Clear expiry date';

  @override
  String get adminPromoActiveSwitch => 'Active';

  @override
  String get adminPromoSaved => 'Promo code saved';

  @override
  String get adminPromoDeleted => 'Promo code deleted';

  @override
  String get adminPromoDeleteTitle => 'Delete this promo code?';

  @override
  String adminPromoDeleteMessage(String code) {
    return 'The code $code will be deleted. Orders that already used it are kept.';
  }

  @override
  String adminPromoPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String adminPromoDiscountLine(String discount) {
    return 'Discount: $discount';
  }

  @override
  String adminPromoUsedCount(int count) {
    return 'Used: $count';
  }

  @override
  String adminPromoUsedOf(int used, int limit) {
    return 'Used: $used / $limit';
  }

  @override
  String adminPromoExpiresOn(String date) {
    return 'Valid until $date';
  }

  @override
  String get adminPromoStatusActive => 'Active';

  @override
  String get adminPromoStatusInactive => 'Disabled';

  @override
  String get adminPromoStatusExpired => 'Expired';

  @override
  String get adminPromoStatusExhausted => 'Used up';

  @override
  String get adminPromoEnable => 'Enable';

  @override
  String get adminPromoDisable => 'Disable';

  @override
  String get promoHint => 'Promo code';

  @override
  String get promoApply => 'Apply';

  @override
  String promoApplied(String amount) {
    return 'Discount: −$amount';
  }

  @override
  String get promoRemove => 'Remove promo code';

  @override
  String get promoDiscountLabel => 'Promo discount';

  @override
  String get errorPromoNotFound =>
      'This promo code was not found or is not active.';

  @override
  String get errorPromoExpired => 'This promo code has expired.';

  @override
  String get errorPromoLimitReached =>
      'This promo code has reached its usage limit.';

  @override
  String get errorPromoExists => 'A promo code with this code already exists.';

  @override
  String get errorStaffExists => 'This user is already a staff member.';

  @override
  String get errorStaffIsOwner =>
      'The store owner can\'t be added or removed as staff.';

  @override
  String get errorOwnerOnly => 'Only the store owner can do this.';

  @override
  String get adminManageStatsHint => 'Sales, best sellers and customers';

  @override
  String get adminStatsTitle => 'Statistics';

  @override
  String get adminStatsTabSales => 'Sales';

  @override
  String get adminStatsTabTop => 'Best sellers';

  @override
  String get adminStatsTabCustomers => 'Customers';

  @override
  String get adminStatsToday => 'Today';

  @override
  String get adminStatsThisMonth => 'This month';

  @override
  String get adminStatsDaily => 'Daily';

  @override
  String get adminStatsMonthly => 'Monthly';

  @override
  String adminStatsLastDays(int count) {
    return 'Last $count days';
  }

  @override
  String adminStatsLastMonths(int count) {
    return 'Last $count months';
  }

  @override
  String adminStatsOrdersCount(int count) {
    return '$count orders';
  }

  @override
  String get adminStatsNote =>
      'Cancelled and refunded orders are not counted. Days are calculated in Uzbekistan time.';

  @override
  String get adminStatsTopEmpty => 'No sales yet';

  @override
  String get adminStatsTopEmptyHint =>
      'Best-selling sweets will appear here once the first orders come in.';

  @override
  String get adminStatsCustomersEmpty => 'No customers yet';

  @override
  String get adminStatsNoOrders => 'No orders yet';

  @override
  String adminStatsLastOrder(String date) {
    return 'last on $date';
  }

  @override
  String get legalSectionTitle => 'Legal';

  @override
  String get legalPrivacyTitle => 'Privacy policy';

  @override
  String get legalRefundTitle => 'Refund policy';

  @override
  String legalLastUpdated(String date) {
    return 'Updated: $date';
  }

  @override
  String get offlineBanner =>
      'No internet connection. Data won\'t update until you\'re back online.';

  @override
  String get offlineBackOnline => 'Back online';

  @override
  String get navHome => 'Home';

  @override
  String get homeFeatured => 'Featured sweets';

  @override
  String get settingsReduceTransparency => 'Reduce transparency';

  @override
  String get settingsReduceTransparencyHint =>
      'Simplifies the glass effect: blur is off and text is easier to read.';

  @override
  String get authLoginButton => 'Sign in';

  @override
  String get authLoginField => 'Username or email';

  @override
  String get authUsername => 'Username';

  @override
  String get authUsernameHint => 'e.g. ali_2024';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordRepeat => 'Repeat password';

  @override
  String get authOr => 'or';

  @override
  String get authRegister => 'Create account';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get authRegisterSubtitle =>
      'Enter your details to make ordering quick and easy.';

  @override
  String get authAddressFromMap => 'Home location (from map)';

  @override
  String get authAddressFromMapHint => 'Pick a place on the map';

  @override
  String get mapPickerTitle => 'Choose your location';

  @override
  String get mapPickerConfirm => 'Use this address';

  @override
  String get mapPickerLocating => 'Finding address…';

  @override
  String get mapPickerMyLocation => 'My location';

  @override
  String get mapPickerLocationFailed =>
      'Couldn\'t get your location. Move the map to pick a place.';

  @override
  String get usernameInvalid =>
      '3–24 characters: Latin letters, digits, _ and .';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordMismatch => 'Passwords don\'t match';

  @override
  String get errorInvalidCredentials => 'Wrong username or password.';

  @override
  String get errorEmailTaken => 'This email is already registered.';

  @override
  String get errorUsernameTaken =>
      'This username is taken. Choose another one.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get credentialsTitle => 'Change username and password';

  @override
  String get credentialsCurrentPassword => 'Current password';

  @override
  String get credentialsNewPassword => 'New password (optional)';

  @override
  String get credentialsSaved => 'Username and password updated';

  @override
  String get errorWrongPassword => 'Current password is incorrect.';

  @override
  String get errorStaffNotRegistered =>
      'No registered user with this email. They need to sign up in the app first.';
}

import '../../l10n/gen/app_localizations.dart';
import '../network/api_exception.dart';

typedef ErrorText = ({String title, String message});

/// Xatoni foydalanuvchiga ko'rsatiladigan tarjima qilingan matnga aylantiradi.
ErrorText describeError(AppLocalizations l10n, Object error) {
  if (error is ApiException) {
    switch (error.code) {
      case 'NETWORK_ERROR':
        return (title: l10n.errorNetworkTitle, message: l10n.errorNetworkMessage);
      case 'TOO_MANY_REQUESTS':
        return (title: l10n.errorGenericTitle, message: l10n.errorTooManyRequests);
      case 'UNAUTHORIZED':
        return (title: l10n.errorGenericTitle, message: l10n.errorUnauthorizedMessage);
      case 'FORBIDDEN':
        if (error.message == 'REVIEW_NOT_ALLOWED') {
          return (title: l10n.errorGenericTitle, message: l10n.errorReviewNotAllowed);
        }
        if (error.message == 'OWNER_ONLY') {
          return (title: l10n.errorGenericTitle, message: l10n.errorOwnerOnly);
        }
        return (title: l10n.errorGenericTitle, message: l10n.errorForbiddenMessage);
      case 'NOT_FOUND':
        if (error.message == 'STAFF_NOT_REGISTERED') {
          return (title: l10n.errorGenericTitle, message: l10n.errorStaffNotRegistered);
        }
        return (title: l10n.errorGenericTitle, message: l10n.errorNotFoundMessage);
      case 'UNSUPPORTED_MEDIA_TYPE':
        return (title: l10n.errorGenericTitle, message: l10n.errorImageTypeMessage);
      case 'PAYLOAD_TOO_LARGE':
        return (title: l10n.errorGenericTitle, message: l10n.errorImageSizeMessage);
      case 'BAD_REQUEST':
        switch (error.message) {
          case 'INVALID_SCHEDULE':
            return (title: l10n.errorGenericTitle, message: l10n.errorInvalidSchedule);
          case 'ADDRESS_REQUIRED':
            return (title: l10n.errorGenericTitle, message: l10n.errorAddressRequired);
          case 'PHONE_REQUIRED':
          case 'INVALID_PHONE':
            return (title: l10n.errorGenericTitle, message: l10n.phoneInvalid);
          case 'PROMO_NOT_FOUND':
            return (title: l10n.errorGenericTitle, message: l10n.errorPromoNotFound);
          case 'PROMO_EXPIRED':
            return (title: l10n.errorGenericTitle, message: l10n.errorPromoExpired);
          case 'PROMO_LIMIT_REACHED':
            return (title: l10n.errorGenericTitle, message: l10n.errorPromoLimitReached);
          case 'INVALID_EMAIL':
            return (title: l10n.errorGenericTitle, message: l10n.adminStaffEmailInvalid);
          case 'WRONG_PASSWORD':
            return (title: l10n.errorGenericTitle, message: l10n.errorWrongPassword);
          case 'INVALID_CREDENTIALS':
            return (title: l10n.errorGenericTitle, message: l10n.errorInvalidCredentials);
          case 'WEAK_PASSWORD':
            return (title: l10n.errorGenericTitle, message: l10n.passwordTooShort);
        }
      case 'CONFLICT':
        if (error.message == 'EMAIL_TAKEN') {
          return (title: l10n.errorGenericTitle, message: l10n.errorEmailTaken);
        }
        if (error.message == 'USERNAME_TAKEN') {
          return (title: l10n.errorGenericTitle, message: l10n.errorUsernameTaken);
        }
        if (error.message == 'ITEMS_CHANGED') {
          return (title: l10n.errorGenericTitle, message: l10n.errorItemsChanged);
        }
        if (error.message == 'LAST_ADMIN') {
          return (title: l10n.errorGenericTitle, message: l10n.errorLastAdminMessage);
        }
        if (error.message == 'ACTIVE_ORDERS') {
          return (title: l10n.errorGenericTitle, message: l10n.errorActiveOrdersMessage);
        }
        if (error.message == 'INVALID_TRANSITION') {
          return (title: l10n.errorGenericTitle, message: l10n.errorInvalidTransition);
        }
        if (error.message == 'PAYMENT_NOT_ALLOWED') {
          return (title: l10n.errorGenericTitle, message: l10n.errorPaymentNotAllowed);
        }
        if (error.message == 'REFUND_NOT_ALLOWED') {
          return (title: l10n.errorGenericTitle, message: l10n.errorRefundNotAllowed);
        }
        if (error.message == 'ORDERS_PAUSED') {
          return (title: l10n.errorGenericTitle, message: l10n.errorOrdersPaused);
        }
        if (error.message == 'PRODUCT_IN_STOCK') {
          return (title: l10n.errorGenericTitle, message: l10n.errorProductInStock);
        }
        if (error.message == 'REVIEW_EXISTS') {
          return (title: l10n.errorGenericTitle, message: l10n.errorReviewExists);
        }
        if (error.message == 'ORDER_NOT_CANCELLABLE') {
          return (title: l10n.errorGenericTitle, message: l10n.errorOrderNotCancellable);
        }
        if (error.message == 'REORDER_NOT_ALLOWED') {
          return (title: l10n.errorGenericTitle, message: l10n.errorReorderNotAllowed);
        }
        if (error.message == 'PROMO_EXISTS') {
          return (title: l10n.errorGenericTitle, message: l10n.errorPromoExists);
        }
        if (error.message == 'STAFF_EXISTS') {
          return (title: l10n.errorGenericTitle, message: l10n.errorStaffExists);
        }
        if (error.message == 'STAFF_IS_OWNER') {
          return (title: l10n.errorGenericTitle, message: l10n.errorStaffIsOwner);
        }
        break;
      case 'PAYMENT_PROVIDER_ERROR':
        return (title: l10n.errorGenericTitle, message: l10n.errorPaymentProvider);
      case 'SERVICE_UNAVAILABLE':
        if (error.message == 'PAYMENT_UNAVAILABLE') {
          return (title: l10n.errorGenericTitle, message: l10n.errorPaymentUnavailable);
        }
        return (title: l10n.errorServerTitle, message: l10n.errorServerMessage);
      case 'INTERNAL_ERROR':
        return (title: l10n.errorServerTitle, message: l10n.errorServerMessage);
    }
  }
  return (title: l10n.errorGenericTitle, message: l10n.errorGenericMessage);
}
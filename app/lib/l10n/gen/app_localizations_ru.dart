// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Shirinliklar';

  @override
  String get commonOk => 'ОК';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonSearch => 'Поиск';

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String get fieldRequired => 'Заполните это поле';

  @override
  String get emptyTitle => 'Пока пусто';

  @override
  String get emptyMessage => 'Здесь пока ничего нет.';

  @override
  String get noResultsTitle => 'Ничего не найдено';

  @override
  String get noResultsMessage => 'Попробуйте другой запрос.';

  @override
  String get errorGenericTitle => 'Что-то пошло не так';

  @override
  String get errorGenericMessage => 'Пожалуйста, повторите попытку чуть позже.';

  @override
  String get errorNetworkTitle => 'Нет подключения к интернету';

  @override
  String get errorNetworkMessage => 'Проверьте соединение и повторите попытку.';

  @override
  String get errorServerTitle => 'Сервер не отвечает';

  @override
  String get errorServerMessage =>
      'Ошибка на нашей стороне. Повторите попытку позже.';

  @override
  String get errorUnauthorizedMessage => 'Войдите снова, чтобы продолжить.';

  @override
  String get errorForbiddenMessage => 'У вас нет доступа к этому действию.';

  @override
  String get errorNotFoundMessage => 'Запрошенные данные не найдены.';

  @override
  String get errorLastAdminMessage =>
      'Вы последний администратор, поэтому аккаунт нельзя удалить.';

  @override
  String get errorActiveOrdersMessage =>
      'У вас есть активные заказы. Аккаунт можно удалить после их завершения.';

  @override
  String get errorImageTypeMessage =>
      'Можно загружать только JPG, PNG или WebP.';

  @override
  String get errorImageSizeMessage => 'Размер фото не должен превышать 5 МБ.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'День';

  @override
  String get themeDark => 'Ночь';

  @override
  String get languageUz => 'O\'zbekcha';

  @override
  String get languageEn => 'English';

  @override
  String get languageRu => 'Русский';

  @override
  String priceSum(String amount) {
    return '$amount сум';
  }

  @override
  String piecesCount(int count) {
    return '$count шт.';
  }

  @override
  String get authLoginTitle => 'Добро пожаловать!';

  @override
  String get authLoginSubtitle =>
      'Выбирайте сладости, оформляйте заказ и забирайте, когда он готов.';

  @override
  String get authContinueWithGoogle => 'Войти через Google';

  @override
  String get authSignInFailed => 'Не удалось войти. Попробуйте ещё раз.';

  @override
  String get authSignOut => 'Выйти';

  @override
  String get onboardingTitle => 'Давайте познакомимся';

  @override
  String get onboardingSubtitle =>
      'Укажите данные один раз, чтобы оформлять заказы быстрее.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileEditTitle => 'Редактирование профиля';

  @override
  String get profileFirstName => 'Имя';

  @override
  String get profileLastName => 'Фамилия';

  @override
  String get profilePhone => 'Номер телефона';

  @override
  String get profilePhoneHint => '+998 90 123 45 67';

  @override
  String get profileAddress => 'Адрес';

  @override
  String get profileAddressHint => 'Город, улица, дом';

  @override
  String get profileLandmark => 'Ориентир';

  @override
  String get profileLandmarkHint => 'Например, рядом с супермаркетом';

  @override
  String get profileNotSet => 'Не указано';

  @override
  String get profileSaved => 'Профиль сохранён';

  @override
  String get profileRoleAdmin => 'Админ';

  @override
  String get profileAdminPanel => 'Панель администратора';

  @override
  String get profileDeleteAccount => 'Удалить аккаунт';

  @override
  String get profileDeleteTitle => 'Удалить аккаунт?';

  @override
  String get profileDeleteMessage =>
      'Ваши личные данные, избранное и отзывы будут удалены. Это действие нельзя отменить.';

  @override
  String get phoneInvalid => 'Введите корректный номер телефона';

  @override
  String get adminPanelTitle => 'Панель администратора';

  @override
  String get adminPanelPlaceholder =>
      'Разделы управления товарами и заказами появятся на следующих этапах.';

  @override
  String get adminTabProducts => 'Товары';

  @override
  String get adminTabCategories => 'Категории';

  @override
  String get adminShowHidden => 'Показывать скрытые';

  @override
  String get adminProductsEmptyTitle => 'Товаров пока нет';

  @override
  String get adminProductsEmptyMessage => 'Добавьте первую сладость.';

  @override
  String get adminAddProduct => 'Добавить товар';

  @override
  String get adminProductNew => 'Новый товар';

  @override
  String get adminProductEdit => 'Редактирование товара';

  @override
  String get adminBadgeHidden => 'Скрыт';

  @override
  String get adminBadgeOutOfStock => 'Нет в наличии';

  @override
  String get adminHide => 'Скрыть';

  @override
  String get adminShow => 'Показать';

  @override
  String adminStockCount(int count) {
    return 'В наличии: $count';
  }

  @override
  String get adminDeleteProductTitle => 'Удалить товар?';

  @override
  String get adminDeleteProductMessage =>
      'Товар и его фото будут удалены навсегда. В прошлых заказах название сохранится.';

  @override
  String get adminProductSaved => 'Товар сохранён';

  @override
  String get adminProductDeleted => 'Товар удалён';

  @override
  String get adminFieldName => 'Название';

  @override
  String get adminFieldDescription => 'Описание';

  @override
  String get adminFieldIngredients => 'Состав';

  @override
  String get adminFieldAllergens => 'Аллергены';

  @override
  String get adminFieldPrice => 'Цена (сум)';

  @override
  String get adminFieldStock => 'На складе (шт.)';

  @override
  String get adminFieldCategory => 'Категория';

  @override
  String get adminNoCategory => 'Без категории';

  @override
  String get adminFieldVisible => 'Показывать клиентам';

  @override
  String get adminFillAllLanguages => 'Заполните названия на всех трёх языках';

  @override
  String get adminNumberInvalid => 'Введите корректное число';

  @override
  String get adminImages => 'Фото';

  @override
  String adminImagesHint(int count) {
    return 'До $count фото. Первое станет основным, чтобы изменить порядок, удерживайте фото.';
  }

  @override
  String get adminMainImage => 'Главное';

  @override
  String get adminVariants => 'Варианты';

  @override
  String get adminAddVariant => 'Добавить вариант';

  @override
  String get adminVariantGroup => 'Тип';

  @override
  String get adminVariantSize => 'Размер';

  @override
  String get adminVariantCream => 'Тип крема';

  @override
  String get adminVariantInscription => 'Надпись';

  @override
  String get adminVariantName => 'Название варианта';

  @override
  String get adminVariantPriceDelta => 'Разница в цене (сум)';

  @override
  String get adminVariantPriceDeltaHint => 'Например, 20000 или -5000';

  @override
  String get adminCategoryNew => 'Новая категория';

  @override
  String get adminCategoryEdit => 'Редактирование категории';

  @override
  String get adminCategoriesEmptyTitle => 'Категорий пока нет';

  @override
  String get adminCategoriesEmptyMessage =>
      'Добавьте категорию, чтобы сгруппировать товары.';

  @override
  String get adminAddCategory => 'Добавить категорию';

  @override
  String adminCategoryProducts(int count) {
    return 'Товаров: $count';
  }

  @override
  String get adminCategorySortOrder => 'Порядковый номер';

  @override
  String get adminCategoryDeleteTitle => 'Удалить категорию?';

  @override
  String get adminCategoryDeleteMessage =>
      'Товары не удалятся, они останутся без категории.';

  @override
  String get adminCategorySaved => 'Категория сохранена';

  @override
  String get adminCategoryDeleted => 'Категория удалена';

  @override
  String get catalogSearchHint => 'Поиск сладостей';

  @override
  String get catalogAllCategories => 'Все';

  @override
  String get catalogEmptyTitle => 'Сладостей пока нет';

  @override
  String get catalogEmptyMessage => 'Скоро появятся новые.';

  @override
  String get catalogOutOfStock => 'Нет в наличии';

  @override
  String get productAddToCart => 'В корзину';

  @override
  String get productTotal => 'Итого';

  @override
  String get productDescription => 'Описание';

  @override
  String get productIngredients => 'Состав';

  @override
  String get productAllergens => 'Аллергены';

  @override
  String get productNoReviews => 'Оценок пока нет';

  @override
  String productReviewsCount(int count) {
    return 'Оценок: $count';
  }

  @override
  String productInStock(int count) {
    return 'В наличии: $count шт.';
  }

  @override
  String get cartTitle => 'Корзина';

  @override
  String get cartEmptyTitle => 'Корзина пуста';

  @override
  String get cartEmptyMessage =>
      'Выберите понравившиеся сладости и добавьте их в корзину.';

  @override
  String get cartGoToCatalog => 'Перейти в каталог';

  @override
  String get cartAdded => 'Добавлено в корзину';

  @override
  String get cartOpen => 'Корзина';

  @override
  String cartStockLimit(int count) {
    return 'В наличии только $count шт.';
  }

  @override
  String cartRemovedNotice(String names) {
    return 'Товары, которых нет в наличии или которые скрыты, удалены из корзины: $names';
  }

  @override
  String get cartReducedNotice =>
      'Количество некоторых товаров уменьшено до остатка на складе.';

  @override
  String get cartRemoveItem => 'Убрать из корзины';

  @override
  String get cartCheckout => 'Оформить';

  @override
  String get checkoutTitle => 'Оформление заказа';

  @override
  String get checkoutOrderSection => 'Ваш заказ';

  @override
  String get checkoutScheduleSection => 'На какое время?';

  @override
  String get checkoutSchedulePick => 'Выберите дату и время';

  @override
  String get checkoutScheduleRequired => 'Выберите дату и время';

  @override
  String checkoutScheduleTooSoon(int minutes) {
    return 'Заказ нужно оформлять минимум за $minutes мин.';
  }

  @override
  String get checkoutFulfillmentSection => 'Как получить?';

  @override
  String get checkoutAddress => 'Адрес доставки';

  @override
  String get checkoutNote => 'Комментарий';

  @override
  String get checkoutNoteHint => 'Например, без орехов';

  @override
  String get checkoutPaymentSection => 'Способ оплаты';

  @override
  String get checkoutSubtotal => 'Товары';

  @override
  String get checkoutDeliveryFee => 'Доставка';

  @override
  String get checkoutPlaceOrder => 'Оформить заказ';

  @override
  String get fulfillmentPickup => 'Самовывоз';

  @override
  String get fulfillmentDelivery => 'Доставка';

  @override
  String get paymentCash => 'Наличными';

  @override
  String get paymentOnline => 'Онлайн-оплата';

  @override
  String get orderStatusPending => 'Ожидает';

  @override
  String get orderStatusAccepted => 'Принят';

  @override
  String get orderStatusCancelled => 'Отменён';

  @override
  String get orderStatusReady => 'Готов';

  @override
  String get orderStatusOnTheWay => 'В пути';

  @override
  String get orderStatusDelivered => 'Выдан';

  @override
  String get orderSuccessTitle => 'Заказ отправлен!';

  @override
  String get orderSuccessMessage =>
      'Магазин рассмотрит заказ и скоро подтвердит его.';

  @override
  String orderNumber(int number) {
    return 'Заказ №$number';
  }

  @override
  String get orderScheduledFor => 'На время';

  @override
  String get orderBackHome => 'На главную';

  @override
  String get errorInvalidSchedule =>
      'Выбранное время не подходит. Выберите другое.';

  @override
  String get errorAddressRequired => 'Введите адрес доставки.';

  @override
  String get errorItemsChanged =>
      'Некоторые товары в корзине изменились. Проверьте корзину и попробуйте снова.';

  @override
  String get adminTabOrders => 'Заказы';

  @override
  String get adminOrdersEmptyTitle => 'Заказов нет';

  @override
  String get adminOrdersEmptyMessage => 'Новые заказы появятся здесь.';

  @override
  String get adminOrdersFilterAll => 'Все';

  @override
  String adminOrderTitle(int number) {
    return 'Заказ №$number';
  }

  @override
  String get adminOrderCustomer => 'Клиент';

  @override
  String get adminOrderDetails => 'Детали заказа';

  @override
  String get adminOrderReceiving => 'Способ получения';

  @override
  String get adminOrderPayment => 'Способ оплаты';

  @override
  String get adminOrderNote => 'Комментарий клиента';

  @override
  String get adminOrderCancelReasonTitle => 'Причина отмены';

  @override
  String get adminOrderItems => 'Товары';

  @override
  String get adminOrderSubtotal => 'Сумма товаров';

  @override
  String get adminOrderDeliveryFee => 'Доставка';

  @override
  String get adminOrderDiscount => 'Скидка';

  @override
  String get adminOrderTotal => 'Итого';

  @override
  String get adminOrderAccept => 'Принять';

  @override
  String get adminOrderMarkReady => 'Готов';

  @override
  String get adminOrderMarkOnTheWay => 'В пути';

  @override
  String get adminOrderMarkDelivered => 'Выдан';

  @override
  String get adminOrderCancel => 'Отменить заказ';

  @override
  String get adminOrderCancelTitle => 'Отменить заказ?';

  @override
  String get adminOrderCancelMessage =>
      'Напишите причину, которую увидит клиент. Товары вернутся на склад.';

  @override
  String get adminOrderCancelReasonLabel => 'Причина';

  @override
  String get adminOrderCancelConfirm => 'Отменить заказ';

  @override
  String get adminOrderCashHint =>
      'При выдаче заказа оплата будет отмечена как оплаченная.';

  @override
  String get adminOrderUpdated => 'Статус обновлён';

  @override
  String get paymentStatusUnpaid => 'Не оплачено';

  @override
  String get paymentStatusPaid => 'Оплачено';

  @override
  String get paymentStatusRefunded => 'Возвращено';

  @override
  String get errorInvalidTransition =>
      'Статус заказа уже изменился. Обновите список.';

  @override
  String get errorOrderNotCancellable => 'Этот заказ больше нельзя отменить.';

  @override
  String get myOrdersTitle => 'Мои заказы';

  @override
  String get myOrdersEmptyTitle => 'Заказов пока нет';

  @override
  String get myOrdersEmptyMessage =>
      'Сделайте первый заказ — сладости уже ждут.';

  @override
  String get myOrdersBrowse => 'Перейти в каталог';

  @override
  String get myOrderItems => 'Товары';

  @override
  String get myOrderSubtotal => 'Сумма товаров';

  @override
  String get myOrderPaymentStatus => 'Статус оплаты';

  @override
  String get orderCancelAction => 'Отменить заказ';

  @override
  String get orderCancelTitle => 'Отменить заказ?';

  @override
  String get orderCancelMessage =>
      'Отменить можно только до принятия заказа. Это действие нельзя отменить.';

  @override
  String get orderCancelConfirm => 'Да, отменить';

  @override
  String get orderCancelKeep => 'Нет, оставить';

  @override
  String get orderCancelDone => 'Заказ отменён';

  @override
  String get payTitle => 'Оплата';

  @override
  String get payNow => 'Оплатить сейчас';

  @override
  String get payPayOnline => 'Оплатить онлайн';

  @override
  String get payProceed => 'Перейти к оплате';

  @override
  String get payReadyMessage =>
      'Вы перейдёте на страницу оплаты. После оплаты вернитесь в приложение.';

  @override
  String get payOpening => 'Открываем страницу оплаты…';

  @override
  String get payChecking => 'Проверяем оплату…';

  @override
  String get payWaitingTitle => 'Завершите оплату';

  @override
  String get payWaitingMessage =>
      'Завершите оплату на странице оплаты и вернитесь в приложение. Статус проверится автоматически.';

  @override
  String get payCheck => 'Проверить статус';

  @override
  String get payRetry => 'Повторить';

  @override
  String get payPendingTitle => 'Оплата ещё не подтверждена';

  @override
  String get payPendingMessage =>
      'Если деньги не списались, попробуйте снова. Если списались — проверьте статус чуть позже.';

  @override
  String get paySuccessTitle => 'Оплата принята';

  @override
  String get paySuccessMessage => 'Спасибо! Заказ отмечен как оплаченный.';

  @override
  String get payCannotOpen => 'Не удалось открыть страницу оплаты.';

  @override
  String get adminOrderRefund => 'Вернуть оплату';

  @override
  String get adminOrderRefundTitle => 'Вернуть оплату?';

  @override
  String get adminOrderRefundMessage =>
      'Полная сумма вернётся на карту клиента. Это действие нельзя отменить.';

  @override
  String get adminOrderRefundConfirm => 'Вернуть';

  @override
  String get errorPaymentUnavailable =>
      'Онлайн-оплата сейчас недоступна. Попробуйте позже.';

  @override
  String get errorPaymentProvider =>
      'Платёжная система не отвечает. Попробуйте чуть позже.';

  @override
  String get errorPaymentNotAllowed => 'Этот заказ нельзя оплатить онлайн.';

  @override
  String get errorRefundNotAllowed => 'Этот платёж нельзя вернуть.';

  @override
  String get reviewsTitle => 'Отзывы';

  @override
  String get reviewsEmpty => 'Об этой сладости пока нет отзывов.';

  @override
  String get reviewsShowMore => 'Показать ещё';

  @override
  String get reviewsLeave => 'Оценить и написать отзыв';

  @override
  String get reviewsOnlyBuyers =>
      'Оценить можно после получения этой сладости.';

  @override
  String get reviewsYourReview => 'Ваш отзыв';

  @override
  String get reviewsYou => 'Вы';

  @override
  String get reviewsAnonymous => 'Покупатель';

  @override
  String get reviewsHiddenNotice =>
      'Магазин скрыл этот отзыв, другие покупатели его не видят.';

  @override
  String get reviewsShopReply => 'Ответ магазина';

  @override
  String get reviewFormTitle => 'Оценка и отзыв';

  @override
  String get reviewFormEditTitle => 'Редактировать отзыв';

  @override
  String get reviewFormRatingLabel => 'Ваша оценка';

  @override
  String get reviewFormRatingRequired => 'Выберите количество звёзд';

  @override
  String get reviewFormTextLabel => 'Отзыв (по желанию)';

  @override
  String get reviewFormTextHint => 'Как вам понравилось?';

  @override
  String get reviewFormSubmit => 'Отправить';

  @override
  String get reviewFormSent => 'Спасибо! Ваш отзыв добавлен.';

  @override
  String get reviewFormUpdated => 'Отзыв обновлён.';

  @override
  String get reviewFormNotAllowedTitle => 'Пока недоступно';

  @override
  String get reviewDeleteTitle => 'Удалить отзыв?';

  @override
  String get reviewDeleteMessage => 'Ваша оценка и отзыв будут удалены.';

  @override
  String get reviewDeleted => 'Отзыв удалён.';

  @override
  String get orderRateItem => 'Оставить оценку';

  @override
  String get errorReviewNotAllowed =>
      'Оставить отзыв может только покупатель, получивший эту сладость.';

  @override
  String get errorReviewExists => 'Вы уже оставили отзыв об этой сладости.';

  @override
  String get adminTabReviews => 'Отзывы';

  @override
  String get adminReviewsFilterAll => 'Все';

  @override
  String get adminReviewsFilterVisible => 'Видимые';

  @override
  String get adminReviewsFilterHidden => 'Скрытые';

  @override
  String get adminReviewsEmptyTitle => 'Отзывов нет';

  @override
  String get adminReviewsEmptyMessage => 'Оценки покупателей появятся здесь.';

  @override
  String get adminReviewHiddenBadge => 'Скрыт';

  @override
  String get adminReviewHide => 'Скрыть';

  @override
  String get adminReviewShow => 'Показать';

  @override
  String get adminReviewHideTitle => 'Скрыть отзыв?';

  @override
  String get adminReviewHideMessage =>
      'Он не будет виден на странице товара и не войдёт в средний рейтинг.';

  @override
  String get adminReviewReply => 'Написать ответ';

  @override
  String get adminReviewReplyEdit => 'Изменить ответ';

  @override
  String get adminReviewReplyDelete => 'Удалить ответ';

  @override
  String get adminReviewReplyHint => 'Ваш ответ покупателю';

  @override
  String get adminReviewReplyDeleteTitle => 'Удалить ответ?';

  @override
  String get adminReviewReplyDeleteMessage =>
      'Ответ будет убран со страницы товара.';

  @override
  String get stockAlertNotifyMe => 'Сообщить, когда появится';

  @override
  String get stockAlertSubscribed => 'Сообщим ✓';

  @override
  String get stockAlertDone => 'Мы сообщим вам, когда товар снова появится.';

  @override
  String get stockAlertNoPermission =>
      'Подписка оформлена, но уведомления выключены. Включите их в настройках телефона, чтобы получить сообщение.';

  @override
  String get stockAlertCancelled => 'Подписка отменена.';

  @override
  String get storeClosedTitle => 'Сегодня заказы не принимаются';

  @override
  String get storeClosedMessage =>
      'Магазин сегодня не принимает новые заказы. Попробуйте завтра.';

  @override
  String get adminStoreAccepting => 'Приём заказов';

  @override
  String get adminStoreOpenHint => 'Покупатели могут оформлять заказы.';

  @override
  String get adminStorePausedHint => 'Сегодня новые заказы не принимаются.';

  @override
  String get adminStorePauseTitle => 'Не принимать заказы сегодня?';

  @override
  String get adminStorePauseMessage =>
      'Покупатели не смогут оформить новые заказы. Приём приостановлен до конца дня, включить его снова можно в любой момент.';

  @override
  String get adminStorePauseConfirm => 'Приостановить';

  @override
  String get errorOrdersPaused => 'Магазин сегодня не принимает новые заказы.';

  @override
  String get errorProductInStock =>
      'Эта сладость сейчас в наличии, её можно добавить в корзину.';

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get favoritesEmptyTitle => 'В избранном пусто';

  @override
  String get favoritesEmptyMessage =>
      'Нажмите на сердечко у понравившейся сладости — она сохранится здесь.';

  @override
  String get favoritesBrowse => 'Открыть каталог';

  @override
  String get favoriteAdd => 'Добавить в избранное';

  @override
  String get favoriteRemove => 'Убрать из избранного';

  @override
  String get orderReorderAction => 'Заказать снова';

  @override
  String get orderReorderDone => 'Сладости добавлены в корзину';

  @override
  String get orderReorderAdjusted =>
      'Добавлено в корзину; количество некоторых уменьшено до остатка на складе';

  @override
  String orderReorderPartial(String names) {
    return 'Добавлено в корзину. Нет в наличии: $names';
  }

  @override
  String get orderReorderNothing =>
      'Сладости из этого заказа сейчас недоступны';

  @override
  String get errorReorderNotAllowed => 'Повторить можно только выданный заказ.';

  @override
  String get profileRoleOwner => 'Владелец магазина';

  @override
  String get profileRoleStaff => 'Сотрудник';

  @override
  String get adminTabManage => 'Управление';

  @override
  String get adminManagePromosHint => 'Создавайте и отслеживайте коды скидок';

  @override
  String get adminManageStaffHint => 'Добавляйте и удаляйте сотрудников';

  @override
  String get adminStaffTitle => 'Сотрудники';

  @override
  String get adminStaffHint =>
      'Сотрудник работает с заказами, товарами и отзывами. Промокоды, сотрудники, изменение категорий, удаление товаров и возврат денег доступны только владельцу магазина.';

  @override
  String get adminStaffAdd => 'Добавить сотрудника';

  @override
  String get adminStaffAddHint =>
      'Введите email его Google-аккаунта. Когда он войдёт с этим аккаунтом, у него появится доступ к панели администратора.';

  @override
  String get adminStaffEmail => 'Email';

  @override
  String get adminStaffEmailInvalid => 'Email указан неверно';

  @override
  String get adminStaffAdded => 'Сотрудник добавлен';

  @override
  String get adminStaffRemove => 'Убрать';

  @override
  String get adminStaffRemoveTitle => 'Убрать сотрудника?';

  @override
  String adminStaffRemoveMessage(String email) {
    return '$email потеряет доступ к панели администратора и останется обычным покупателем.';
  }

  @override
  String get adminStaffRemoved => 'Сотрудник убран';

  @override
  String get adminStaffNotSignedIn => 'Ещё не входил';

  @override
  String get adminPromosTitle => 'Промокоды';

  @override
  String get adminPromoAdd => 'Добавить промокод';

  @override
  String get adminPromosEmptyTitle => 'Промокодов пока нет';

  @override
  String get adminPromosEmptyMessage =>
      'Создайте первый промокод — покупатели вводят его в корзине и получают скидку.';

  @override
  String get adminPromoNew => 'Новый промокод';

  @override
  String get adminPromoEdit => 'Изменить промокод';

  @override
  String get adminPromoCode => 'Код';

  @override
  String get adminPromoCodeInvalid =>
      '3–32 символа: латинские буквы, цифры, дефис или нижнее подчёркивание';

  @override
  String get adminPromoDiscountType => 'Тип скидки';

  @override
  String get adminPromoTypePercent => 'Процент';

  @override
  String get adminPromoTypeAmount => 'Сумма';

  @override
  String get adminPromoValuePercent => 'Скидка (%)';

  @override
  String get adminPromoValueAmount => 'Скидка (сум)';

  @override
  String get adminPromoPercentInvalid => 'Введите значение от 1 до 100';

  @override
  String get adminPromoUsageLimit => 'Лимит использований';

  @override
  String get adminPromoUnlimited => 'Без ограничений';

  @override
  String get adminPromoLimitInvalid => 'Введите 1 или больше';

  @override
  String get adminPromoExpiry => 'Действует до';

  @override
  String get adminPromoNoExpiry => 'Бессрочно';

  @override
  String get adminPromoClearExpiry => 'Убрать срок';

  @override
  String get adminPromoActiveSwitch => 'Активен';

  @override
  String get adminPromoSaved => 'Промокод сохранён';

  @override
  String get adminPromoDeleted => 'Промокод удалён';

  @override
  String get adminPromoDeleteTitle => 'Удалить промокод?';

  @override
  String adminPromoDeleteMessage(String code) {
    return 'Код $code будет удалён. Заказы, где он уже использован, сохранятся.';
  }

  @override
  String adminPromoPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String adminPromoDiscountLine(String discount) {
    return 'Скидка: $discount';
  }

  @override
  String adminPromoUsedCount(int count) {
    return 'Использован: $count';
  }

  @override
  String adminPromoUsedOf(int used, int limit) {
    return 'Использован: $used / $limit';
  }

  @override
  String adminPromoExpiresOn(String date) {
    return 'Действует до $date';
  }

  @override
  String get adminPromoStatusActive => 'Активен';

  @override
  String get adminPromoStatusInactive => 'Отключён';

  @override
  String get adminPromoStatusExpired => 'Истёк';

  @override
  String get adminPromoStatusExhausted => 'Исчерпан';

  @override
  String get adminPromoEnable => 'Включить';

  @override
  String get adminPromoDisable => 'Отключить';

  @override
  String get promoHint => 'Промокод';

  @override
  String get promoApply => 'Применить';

  @override
  String promoApplied(String amount) {
    return 'Скидка: −$amount';
  }

  @override
  String get promoRemove => 'Убрать промокод';

  @override
  String get promoDiscountLabel => 'Скидка по промокоду';

  @override
  String get errorPromoNotFound => 'Такой промокод не найден или не активен.';

  @override
  String get errorPromoExpired => 'Срок действия промокода истёк.';

  @override
  String get errorPromoLimitReached => 'Промокод исчерпал лимит использований.';

  @override
  String get errorPromoExists => 'Промокод с таким кодом уже существует.';

  @override
  String get errorStaffExists => 'Этот пользователь уже сотрудник.';

  @override
  String get errorStaffIsOwner =>
      'Владельца магазина нельзя добавить или убрать как сотрудника.';

  @override
  String get errorOwnerOnly =>
      'Это действие доступно только владельцу магазина.';

  @override
  String get adminManageStatsHint => 'Продажи, хиты и клиенты';

  @override
  String get adminStatsTitle => 'Статистика';

  @override
  String get adminStatsTabSales => 'Продажи';

  @override
  String get adminStatsTabTop => 'Хиты продаж';

  @override
  String get adminStatsTabCustomers => 'Клиенты';

  @override
  String get adminStatsToday => 'Сегодня';

  @override
  String get adminStatsThisMonth => 'Этот месяц';

  @override
  String get adminStatsDaily => 'По дням';

  @override
  String get adminStatsMonthly => 'По месяцам';

  @override
  String adminStatsLastDays(int count) {
    return 'Последние $count дн.';
  }

  @override
  String adminStatsLastMonths(int count) {
    return 'Последние $count мес.';
  }

  @override
  String adminStatsOrdersCount(int count) {
    return 'Заказов: $count';
  }

  @override
  String get adminStatsNote =>
      'Отменённые и возвращённые заказы не учитываются. Дни считаются по времени Узбекистана.';

  @override
  String get adminStatsTopEmpty => 'Продаж пока нет';

  @override
  String get adminStatsTopEmptyHint =>
      'Самые продаваемые сладости появятся здесь после первых заказов.';

  @override
  String get adminStatsCustomersEmpty => 'Клиентов пока нет';

  @override
  String get adminStatsNoOrders => 'Заказов ещё не было';

  @override
  String adminStatsLastOrder(String date) {
    return 'последний $date';
  }

  @override
  String get legalSectionTitle => 'Правовая информация';

  @override
  String get legalPrivacyTitle => 'Политика конфиденциальности';

  @override
  String get legalRefundTitle => 'Правила возврата денег';

  @override
  String legalLastUpdated(String date) {
    return 'Обновлено: $date';
  }

  @override
  String get offlineBanner =>
      'Нет подключения к интернету. Данные не обновятся, пока связь не восстановится.';

  @override
  String get offlineBackOnline => 'Интернет снова подключён';

  @override
  String get navHome => 'Главная';

  @override
  String get homeFeatured => 'Избранные сладости';

  @override
  String get settingsReduceTransparency => 'Уменьшить прозрачность';

  @override
  String get settingsReduceTransparencyHint =>
      'Упрощает стеклянный эффект: размытие отключается, текст читается чётче.';

  @override
  String get authLoginButton => 'Войти';

  @override
  String get authLoginField => 'Username или email';

  @override
  String get authUsername => 'Username';

  @override
  String get authUsernameHint => 'например, ali_2024';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authPasswordRepeat => 'Повторите пароль';

  @override
  String get authOr => 'или';

  @override
  String get authRegister => 'Регистрация';

  @override
  String get authRegisterTitle => 'Регистрация';

  @override
  String get authRegisterSubtitle =>
      'Введите свои данные — так заказывать будет проще.';

  @override
  String get authAddressFromMap => 'Место проживания (с карты)';

  @override
  String get authAddressFromMapHint => 'Выберите место на карте';

  @override
  String get mapPickerTitle => 'Выберите место проживания';

  @override
  String get mapPickerConfirm => 'Выбрать этот адрес';

  @override
  String get mapPickerLocating => 'Определяем адрес…';

  @override
  String get mapPickerMyLocation => 'Моё местоположение';

  @override
  String get mapPickerLocationFailed =>
      'Не удалось определить местоположение. Сдвиньте карту, чтобы выбрать место.';

  @override
  String get usernameInvalid => '3–24 символа: латиница, цифры, _ и .';

  @override
  String get emailInvalid => 'Введите корректный email';

  @override
  String get passwordTooShort => 'Пароль должен быть не короче 8 символов';

  @override
  String get passwordMismatch => 'Пароли не совпадают';

  @override
  String get errorInvalidCredentials => 'Неверный username или пароль.';

  @override
  String get errorEmailTaken => 'Этот email уже зарегистрирован.';

  @override
  String get errorUsernameTaken => 'Этот username занят. Выберите другой.';

  @override
  String get errorTooManyRequests => 'Слишком много попыток. Попробуйте позже.';

  @override
  String get credentialsTitle => 'Смена логина и пароля';

  @override
  String get credentialsCurrentPassword => 'Текущий пароль';

  @override
  String get credentialsNewPassword => 'Новый пароль (необязательно)';

  @override
  String get credentialsSaved => 'Логин и пароль обновлены';

  @override
  String get errorWrongPassword => 'Текущий пароль неверен.';

  @override
  String get errorStaffNotRegistered =>
      'Пользователь с таким email не найден. Пусть сначала зарегистрируется в приложении.';
}

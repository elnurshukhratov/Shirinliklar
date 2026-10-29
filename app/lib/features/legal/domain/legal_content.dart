import '../../../core/config/app_config.dart';

enum LegalDoc { privacy, refund }

/// Hujjatlar oxirgi marta yangilangan sana (matn o'zgarsa, shuni yangilang).
final DateTime kLegalUpdatedAt = DateTime(2026, 10, 29);

class LegalSection {
  const LegalSection(this.title, this.body);

  final String title;
  final String body;
}

/// Hujjat matnlari ilova ichida, uch tilda. {store}, {email}, {days} joriy sozlamadan to'ldiriladi.
List<LegalSection> legalSections(LegalDoc doc, String languageCode) {
  final raw = switch (doc) {
    LegalDoc.privacy => _privacy[languageCode] ?? _privacy['uz']!,
    LegalDoc.refund => _refund[languageCode] ?? _refund['uz']!,
  };
  String fill(String s) => s
      .replaceAll('{store}', AppConfig.appName)
      .replaceAll('{email}', AppConfig.supportEmail)
      .replaceAll('{days}', AppConfig.refundDays.toString());
  return [for (final (t, b) in raw) LegalSection(fill(t), fill(b))];
}

const _privacy = <String, List<(String, String)>>{
  'uz': [
    ('Bu hujjat haqida', "Ushbu maxfiylik siyosati «{store}» ilovasi sizning ma'lumotlaringizni qanday yig'ishi, ishlatishi va himoya qilishini tushuntiradi. Ilovadan foydalanib, siz shu qoidalar bilan tanishganingizni tasdiqlaysiz."),
    ("Qanday ma'lumotlar yig'iladi", "Google orqali kirganingizda — ismingiz va email manzilingiz.\nProfilda siz kiritgan ma'lumotlar — ism, familiya, telefon raqami, manzil va mo'ljal.\nBuyurtmalar — tarkibi, summasi, sanasi, to'lov usuli va holati, izohingiz.\nSharhlar, baholar va sevimli mahsulotlar.\nBildirishnoma yuborish uchun qurilma tokeni.\nIlova sizning joylashuvingiz, kontaktlaringiz, kamerangiz yoki fayllaringizdan foydalanmaydi (admin mahsulot rasmini tanlayotganda galereyaga kirishidan tashqari)."),
    ("Ma'lumotlar nima uchun kerak", "Buyurtmani qabul qilish, tayyorlash va yetkazib berish yoki topshirish uchun.\nBuyurtma holati haqida bildirishnoma yuborish uchun.\nTo'lovni tasdiqlash va kerak bo'lsa pulni qaytarish uchun.\nSharhlarni to'g'ri mahsulot va haqiqiy xaridorga bog'lash uchun.\nMa'lumotlaringiz reklama maqsadida sotilmaydi va uchinchi shaxslarga berilmaydi."),
    ("Kimlar bilan ulashiladi", "Faqat xizmat ishlashi uchun zarur tomonlar bilan: Google (kirish), Firebase (bildirishnomalar) va onlayn to'lov tizimi (to'lov qilganingizda, faqat to'lov uchun kerakli ma'lumot). Do'kon egasi va xodimlari buyurtmangizni bajarish uchun ismingiz, telefon raqamingiz va manzilingizni ko'radi. Qonun talab qilsa, vakolatli organlarga berilishi mumkin."),
    ("Saqlash va himoya", "Ma'lumotlar himoyalangan serverda saqlanadi, ilova bilan aloqa faqat HTTPS orqali o'tadi. Karta ma'lumotlaringiz bizda saqlanmaydi — to'lov tizimi tomonida qayta ishlanadi. Ma'lumotlar hisobingiz mavjud bo'lgan davrda saqlanadi."),
    ("Sizning huquqlaringiz", "Profil ma'lumotlarini istalgan vaqt «Profil» bo'limida ko'rishingiz va tahrirlashingiz mumkin.\nHisobingizni profil ekranidagi «Hisobni o'chirish» orqali o'chirishingiz mumkin — shaxsiy ma'lumotlaringiz o'chiriladi. Hisobotlar va qonun talab qilgan yozuvlar shaxsiylashtirilmagan holda qolishi mumkin.\nSavollar bo'lsa: {email}."),
    ("O'zgarishlar", "Siyosat o'zgarsa, yangi versiya shu sahifada e'lon qilinadi va yuqoridagi sana yangilanadi."),
  ],
  'en': [
    ('About this document', 'This privacy policy explains how the "{store}" app collects, uses and protects your data. By using the app you confirm that you have read these rules.'),
    ('What data we collect', "When you sign in with Google — your name and email address.\nProfile details you enter — first and last name, phone number, address and landmark.\nOrders — items, amount, date, payment method and status, your notes.\nReviews, ratings and favorite products.\nA device token to send you notifications.\nThe app does not use your location, contacts, camera or files (except that an admin can pick a product photo from the gallery)."),
    ('Why we need it', 'To accept, prepare and deliver or hand over your order.\nTo notify you about the order status.\nTo confirm payment and, when needed, refund it.\nTo link reviews to the right product and a real buyer.\nYour data is not sold and is not shared for advertising.'),
    ('Who it is shared with', "Only with parties needed for the service to work: Google (sign-in), Firebase (notifications) and the online payment provider (when you pay, only what the payment needs). The store owner and staff see your name, phone number and address to fulfil your order. It may be disclosed to authorities when required by law."),
    ('Storage and protection', 'Data is stored on a protected server and the app communicates only over HTTPS. Your card details are not stored by us — they are processed by the payment provider. Data is kept for as long as your account exists.'),
    ('Your rights', 'You can view and edit your profile at any time in the Profile section.\nYou can delete your account with "Delete account" on the profile screen — your personal data will be erased. Records required by law or for accounting may remain in a non-personalised form.\nQuestions: {email}.'),
    ('Changes', 'If this policy changes, the new version will be published on this page and the date above will be updated.'),
  ],
  'ru': [
    ('Об этом документе', 'Эта политика конфиденциальности объясняет, как приложение «{store}» собирает, использует и защищает ваши данные. Используя приложение, вы подтверждаете, что ознакомились с этими правилами.'),
    ('Какие данные собираются', 'При входе через Google — ваше имя и адрес электронной почты.\nДанные профиля, которые вы вводите, — имя, фамилия, номер телефона, адрес и ориентир.\nЗаказы — состав, сумма, дата, способ и статус оплаты, ваш комментарий.\nОтзывы, оценки и избранные товары.\nТокен устройства для отправки уведомлений.\nПриложение не использует вашу геолокацию, контакты, камеру или файлы (кроме выбора фото товара из галереи администратором).'),
    ('Для чего нужны данные', 'Чтобы принять, приготовить и доставить или выдать заказ.\nЧтобы уведомлять о статусе заказа.\nЧтобы подтвердить оплату и при необходимости вернуть деньги.\nЧтобы привязать отзыв к нужному товару и реальному покупателю.\nВаши данные не продаются и не передаются для рекламы.'),
    ('С кем делимся', 'Только со сторонами, необходимыми для работы сервиса: Google (вход), Firebase (уведомления) и платёжная система (при онлайн-оплате — только данные, нужные для платежа). Владелец и сотрудники магазина видят ваше имя, телефон и адрес для выполнения заказа. По требованию закона данные могут быть переданы уполномоченным органам.'),
    ('Хранение и защита', 'Данные хранятся на защищённом сервере, связь приложения с сервером идёт только по HTTPS. Данные вашей карты у нас не хранятся — они обрабатываются платёжной системой. Данные хранятся, пока существует ваш аккаунт.'),
    ('Ваши права', 'Вы можете в любое время посмотреть и изменить данные в разделе «Профиль».\nВы можете удалить аккаунт кнопкой «Удалить аккаунт» на экране профиля — ваши личные данные будут удалены. Записи, которые требуются по закону или для учёта, могут остаться в обезличенном виде.\nВопросы: {email}.'),
    ('Изменения', 'Если политика изменится, новая версия будет опубликована на этой странице, а дата выше обновится.'),
  ],
};

const _refund = <String, List<(String, String)>>{
  'uz': [
    ('Umumiy qoida', "Bu qoidalar «{store}» ilovasi orqali berilgan buyurtmalarda pulni qaytarish va bekor qilish tartibini belgilaydi."),
    ('Mijoz bekor qilishi', "Buyurtma do'kon tomonidan qabul qilinmaguncha (holati «Kutilmoqda») uni «Buyurtmalarim» bo'limidan o'zingiz bekor qilishingiz mumkin. Qabul qilingandan keyin tayyorlash boshlanadi, shuning uchun bekor qilish do'kon bilan kelishiladi: {email}."),
    ("Do'kon bekor qilishi", "Mahsulot tugab qolgan yoki buyurtmani bajarib bo'lmaydigan bo'lsa, do'kon buyurtmani sababi bilan bekor qiladi va sizga bildirishnoma boradi. Oldindan to'langan bo'lsa, to'liq summa qaytariladi."),
    ("Onlayn to'lovni qaytarish", "Bekor qilingan yoki sifati qoniqtirmagan buyurtma uchun to'lov do'kon tomonidan qaytariladi. Pul to'lov qilingan kartaga qaytadi. Odatda {days} ish kunigacha, aniq muddat bankingizga bog'liq. To'lov holati buyurtmada «Qaytarilgan» deb ko'rinadi."),
    ("Naqd to'lov", "Naqd to'lovda buyurtmani olishdan oldin pul olinmaydi, shuning uchun bekor qilinganda qaytariladigan narsa yo'q. Mahsulotni olib, to'lagandan keyin muammo chiqsa, do'kon bilan bog'laning."),
    ("Sifat bo'yicha e'tiroz", "Mahsulot buyurtmaga mos kelmasa yoki sifati yomon bo'lsa, buyurtmani olgan kuniyoq {email} manziliga buyurtma raqami va iloji bo'lsa surat bilan yozing. Har bir holat alohida ko'rib chiqiladi va qaror sizga bildiriladi."),
    ("Aloqa", "Savollar bo'lsa: {email}."),
  ],
  'en': [
    ('General', 'These rules set out how cancellations and refunds work for orders placed through the "{store}" app.'),
    ('Cancelling by the customer', 'Until the store accepts your order (status "Pending") you can cancel it yourself in "My orders". After acceptance, preparation begins, so cancelling is agreed with the store: {email}.'),
    ('Cancelling by the store', 'If an item is out of stock or the order cannot be fulfilled, the store cancels the order with a reason and you receive a notification. If you paid in advance, the full amount is refunded.'),
    ('Refunds for online payments', 'For a cancelled order or unsatisfactory quality, the store issues the refund. The money returns to the card you paid with, usually within {days} business days; the exact time depends on your bank. The order will show the payment as "Refunded".'),
    ('Cash payments', 'With cash payment no money is taken before you receive the order, so there is nothing to refund on cancellation. If a problem appears after you received and paid for the order, contact the store.'),
    ('Quality complaints', 'If the product does not match the order or its quality is poor, write to {email} on the day you receive it, with the order number and, if possible, a photo. Each case is reviewed individually and you will be told the decision.'),
    ('Contact', 'Questions: {email}.'),
  ],
  'ru': [
    ('Общие положения', 'Эти правила определяют порядок отмены и возврата денег по заказам, оформленным через приложение «{store}».'),
    ('Отмена клиентом', 'Пока магазин не принял заказ (статус «Ожидается»), вы можете отменить его сами в разделе «Мои заказы». После принятия начинается приготовление, поэтому отмена согласуется с магазином: {email}.'),
    ('Отмена магазином', 'Если товара нет в наличии или заказ невозможно выполнить, магазин отменяет заказ с указанием причины, и вам приходит уведомление. Если вы оплатили заранее, возвращается вся сумма.'),
    ('Возврат онлайн-оплаты', 'За отменённый заказ или при неудовлетворительном качестве возврат оформляет магазин. Деньги возвращаются на карту, с которой была оплата, обычно в течение {days} рабочих дней; точный срок зависит от вашего банка. В заказе оплата отобразится как «Возвращена».'),
    ('Оплата наличными', 'При оплате наличными деньги до получения заказа не берутся, поэтому при отмене возвращать нечего. Если проблема обнаружилась после получения и оплаты, свяжитесь с магазином.'),
    ('Претензии по качеству', 'Если товар не соответствует заказу или качество плохое, напишите на {email} в день получения, указав номер заказа и по возможности приложив фото. Каждый случай рассматривается отдельно, о решении вам сообщат.'),
    ('Контакты', 'Вопросы: {email}.'),
  ],
};

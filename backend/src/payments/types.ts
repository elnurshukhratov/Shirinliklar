/**
 * To'lov tizimi adapteri. Yangi tizim (Payme, Uzum) qo'shish uchun shu interfeysni
 * amalga oshiring va payments/index.ts dagi tanlovga ulang.
 */
export interface PaymentProvider {
  readonly name: string;

  /** Mijoz to'lov qiladigan sahifa manzili. */
  createPaymentUrl(input: { orderId: string; amount: number; returnUrl?: string }): string;

  /** Tasdiqlangan to'lovni to'liq qaytaradi. Xato bo'lsa AppError tashlaydi. */
  refund(input: { providerPaymentId: string }): Promise<void>;
}

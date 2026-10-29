import { Category, Product, ProductVariant } from '@prisma/client';
import { pack } from './i18n';

export function toCategoryDto(c: Category, productsCount?: number) {
  return {
    id: c.id,
    name: pack(c, 'name'),
    sortOrder: c.sortOrder,
    isActive: c.isActive,
    ...(productsCount !== undefined ? { productsCount } : {}),
  };
}

export function toVariantDto(v: ProductVariant) {
  return {
    id: v.id,
    group: v.group,
    name: pack(v, 'name'),
    priceDelta: Number(v.priceDelta),
    sortOrder: v.sortOrder,
    isActive: v.isActive,
  };
}

export type ProductWithRels = Product & {
  category: Category | null;
  variants: ProductVariant[];
};

export function toProductDto(p: ProductWithRels) {
  return {
    id: p.id,
    name: pack(p, 'name'),
    description: pack(p, 'description'),
    ingredients: pack(p, 'ingredients'),
    allergens: pack(p, 'allergens'),
    price: Number(p.price),
    stock: p.stock,
    inStock: p.stock > 0,
    images: p.images,
    isActive: p.isActive,
    categoryId: p.categoryId,
    category: p.category ? { id: p.category.id, name: pack(p.category, 'name') } : null,
    variants: p.variants.map(toVariantDto),
    createdAt: p.createdAt,
    updatedAt: p.updatedAt,
  };
}
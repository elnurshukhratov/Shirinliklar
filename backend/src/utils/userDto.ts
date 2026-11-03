import { User } from '@prisma/client';

const PLACEHOLDER_EMAIL_DOMAIN = '@users.shirinliklar.invalid';

export function toUserDto(u: User) {
  const email = u.email.endsWith(PLACEHOLDER_EMAIL_DOMAIN) && u.username ? `@${u.username}` : u.email;
  return {
    id: u.id,
    email,
    username: u.username,
    firstName: u.firstName,
    lastName: u.lastName,
    phone: u.phone,
    address: u.address,
    landmark: u.landmark,
    role: u.role,
    isProfileComplete: u.isProfileComplete,
    createdAt: u.createdAt,
  };
}
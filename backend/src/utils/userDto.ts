import { User } from '@prisma/client';

export function toUserDto(u: User) {
  return {
    id: u.id,
    email: u.email,
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
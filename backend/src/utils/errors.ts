export class AppError extends Error {
  constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
    public readonly details?: unknown,
  ) {
    super(message);
    this.name = 'AppError';
  }

  static badRequest(message = 'BAD_REQUEST', details?: unknown) {
    return new AppError(400, 'BAD_REQUEST', message, details);
  }
  static unauthorized(message = 'UNAUTHORIZED') {
    return new AppError(401, 'UNAUTHORIZED', message);
  }
  static forbidden(message = 'FORBIDDEN') {
    return new AppError(403, 'FORBIDDEN', message);
  }
  static notFound(message = 'NOT_FOUND') {
    return new AppError(404, 'NOT_FOUND', message);
  }
  static conflict(message = 'CONFLICT') {
    return new AppError(409, 'CONFLICT', message);
  }
}

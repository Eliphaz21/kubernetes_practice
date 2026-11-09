import { Request, Response, NextFunction } from 'express';
import { ApiErrorResponse } from '../types/welcome.types';

/**
 * 404 Not Found handler for undefined endpoints.
 */
export function notFoundHandler(
  req: Request,
  res: Response<ApiErrorResponse>,
  _next: NextFunction
): void {
  res.status(404).json({
    error: {
      message: `Endpoint ${req.method} ${req.originalUrl} not found`,
      statusCode: 404,
    },
  });
}

/**
 * Global internal server error handler.
 */
export function errorHandler(
  err: Error,
  _req: Request,
  res: Response<ApiErrorResponse>,
  _next: NextFunction
): void {
  // Production-safe logging
  console.error(`[Error] ${err.message}`, err.stack);

  res.status(500).json({
    error: {
      message: err.message || 'Internal Server Error',
      statusCode: 500,
    },
  });
}


import express, { Application } from 'express';
import cors from 'cors';
import welcomeRoutes from './routes/welcome.routes';
import { notFoundHandler, errorHandler } from './middleware/error.middleware';

/**
 * Creates and configures the Express application.
 */
export function createApp(): Application {
  const app: Application = express();

  // Enable CORS for frontend communication
  const allowedOrigin = process.env.CORS_ORIGIN || 'http://localhost:5173';
  app.use(
    cors({
      origin: allowedOrigin === '*' ? '*' : allowedOrigin,
      methods: ['GET', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
    })
  );

  // Parse incoming JSON payloads
  app.use(express.json());

  // Mount API routes under /api prefix
  app.use('/api', welcomeRoutes);

  // 404 Fallback
  app.use(notFoundHandler);

  // Global Error Handler
  app.use(errorHandler);

  return app;
}

export const app = createApp();


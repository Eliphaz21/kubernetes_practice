import { Request, Response } from 'express';
import {
  WelcomeResponse,
  HealthResponse,
  ReadinessResponse,
} from '../types/welcome.types';

const startTime = Date.now();

/**
 * Controller for CSEC Welcome and operational endpoints.
 */
export class WelcomeController {
  /**
   * GET /api/welcome
   * Returns CSEC ASTU Development Division welcome information.
   */
  public static getWelcome(_req: Request, res: Response<WelcomeResponse>): void {
    const welcomeData: WelcomeResponse = {
      organization: 'CSEC ASTU',
      division: 'Development Division',
      heading: 'CSEC ASTU',
      subtitle: 'Development Division',
      welcomeMessage:
        'Welcome to the CSEC ASTU Development Division. We learn, build and collaborate to develop software engineering skills and create meaningful technology solutions.',
      description:
        'Empowering student engineers through hands-on development, collaborative teamwork, and open-source innovation to build real-world software systems.',
      environment: process.env.NODE_ENV || 'development',
      timestamp: new Date().toISOString(),
    };

    res.status(200).json(welcomeData);
  }

  /**
   * GET /api/health
   * Liveness probe endpoint indicating backend service is alive.
   */
  public static getHealth(_req: Request, res: Response<HealthResponse>): void {
    const uptimeSeconds = Math.floor((Date.now() - startTime) / 1000);

    const healthData: HealthResponse = {
      status: 'healthy',
      service: 'csec-welcome-backend',
      uptimeSeconds,
      timestamp: new Date().toISOString(),
    };

    res.status(200).json(healthData);
  }

  /**
   * GET /api/ready
   * Readiness probe endpoint indicating backend is ready to accept traffic.
   */
  public static getReady(_req: Request, res: Response<ReadinessResponse>): void {
    const readinessData: ReadinessResponse = {
      status: 'ready',
      service: 'csec-welcome-backend',
      checks: {
        server: true,
        timestamp: new Date().toISOString(),
      },
      timestamp: new Date().toISOString(),
    };

    res.status(200).json(readinessData);
  }
}


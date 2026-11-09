/**
 * CSEC ASTU - TypeScript Type Definitions
 * Strict contracts for API responses and application state.
 */

export interface WelcomeResponse {
  organization: string;
  division: string;
  heading: string;
  subtitle: string;
  welcomeMessage: string;
  description: string;
  environment: string;
  timestamp: string;
}

export interface HealthResponse {
  status: 'healthy' | 'unhealthy';
  service: string;
  uptimeSeconds: number;
  timestamp: string;
}

export interface ReadinessCheck {
  server: boolean;
  timestamp: string;
}

export interface ReadinessResponse {
  status: 'ready' | 'not_ready';
  service: string;
  checks: ReadinessCheck;
  timestamp: string;
}

export interface ApiErrorResponse {
  error: {
    message: string;
    statusCode: number;
    details?: unknown;
  };
}


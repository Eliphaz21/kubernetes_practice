import { Router } from 'express';
import { WelcomeController } from '../controllers/welcome.controller';

const router = Router();

/**
 * Route: GET /api/welcome
 * Returns the CSEC ASTU welcome payload.
 */
router.get('/welcome', WelcomeController.getWelcome);

/**
 * Route: GET /api/health
 * Returns service health status (Kubernetes liveness probe).
 */
router.get('/health', WelcomeController.getHealth);

/**
 * Route: GET /api/ready
 * Returns service readiness status (Kubernetes readiness probe).
 */
router.get('/ready', WelcomeController.getReady);

export default router;


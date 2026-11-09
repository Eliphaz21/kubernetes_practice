import http from 'http';
import { app } from './app';

const PORT = parseInt(process.env.PORT || '5000', 10);
const HOST = process.env.HOST || '0.0.0.0';

/**
 * Create HTTP server instance.
 */
const server = http.createServer(app);

server.listen(PORT, HOST, () => {
  console.log(`====================================================`);
  console.log(` CSEC Welcome Backend API Server`);
  console.log(` Organization: CSEC ASTU - Development Division`);
  console.log(` Status: Running`);
  console.log(` Listening: http://${HOST}:${PORT}`);
  console.log(` Health:    http://${HOST}:${PORT}/api/health`);
  console.log(` Ready:     http://${HOST}:${PORT}/api/ready`);
  console.log(` Welcome:   http://${HOST}:${PORT}/api/welcome`);
  console.log(`====================================================`);
});

/**
 * Graceful shutdown handler for containerized environments.
 * Kubernetes sends SIGTERM when terminating a Pod.
 */
function handleGracefulShutdown(signal: string): void {
  console.log(`[Lifecycle] Received ${signal}. Starting graceful shutdown...`);

  server.close((err) => {
    if (err) {
      console.error('[Lifecycle] Error during server close:', err);
      process.exit(1);
    }
    console.log('[Lifecycle] HTTP server closed cleanly. Exiting.');
    process.exit(0);
  });

  // Force shutdown after 10s timeout if connections remain open
  setTimeout(() => {
    console.error('[Lifecycle] Forced shutdown due to timeout.');
    process.exit(1);
  }, 10000).unref();
}

process.on('SIGTERM', () => handleGracefulShutdown('SIGTERM'));
process.on('SIGINT', () => handleGracefulShutdown('SIGINT'));


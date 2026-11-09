import { describe, it } from 'node:test';
import assert from 'node:assert';
import request from 'supertest';
import { app } from '../src/app';

describe('CSEC Welcome Backend API Integration Tests', () => {
  it('GET /api/health returns 200 and healthy status', async () => {
    const res = await request(app).get('/api/health');

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.status, 'healthy');
    assert.strictEqual(res.body.service, 'csec-welcome-backend');
    assert.ok(typeof res.body.uptimeSeconds === 'number');
    assert.ok(res.body.timestamp);
  });

  it('GET /api/ready returns 200 and ready status', async () => {
    const res = await request(app).get('/api/ready');

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.status, 'ready');
    assert.strictEqual(res.body.service, 'csec-welcome-backend');
    assert.strictEqual(res.body.checks.server, true);
    assert.ok(res.body.timestamp);
  });

  it('GET /api/welcome returns 200 with CSEC ASTU payload', async () => {
    const res = await request(app).get('/api/welcome');

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.heading, 'CSEC ASTU');
    assert.strictEqual(res.body.subtitle, 'Development Division');
    assert.strictEqual(
      res.body.welcomeMessage,
      'Welcome to the CSEC ASTU Development Division. We learn, build and collaborate to develop software engineering skills and create meaningful technology solutions.'
    );
    assert.ok(res.body.description.length > 0);
  });

  it('GET /api/unknown-route returns 404 with error payload', async () => {
    const res = await request(app).get('/api/unknown-route');

    assert.strictEqual(res.status, 404);
    assert.strictEqual(res.body.error.statusCode, 404);
    assert.ok(res.body.error.message.includes('not found'));
  });
});


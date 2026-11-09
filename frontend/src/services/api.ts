import { WelcomeData } from '../types/welcome';

/**
 * Determines the API base URL:
 * In local dev or container proxy, relative URL '/api' routes through Vite or Nginx proxy.
 * Can also be overridden with VITE_API_BASE_URL.
 */
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '';

/**
 * Fetches welcome information from the backend API.
 * @throws Error if network fails or non-200 status returned.
 */
export async function fetchWelcomeData(): Promise<WelcomeData> {
  const endpoint = `${API_BASE_URL}/api/welcome`;

  try {
    const response = await fetch(endpoint, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(
        `Failed to fetch welcome information: ${response.status} ${response.statusText}`
      );
    }

    const data: WelcomeData = await response.json();
    return data;
  } catch (err: unknown) {
    if (err instanceof Error) {
      throw new Error(`API Service Error: ${err.message}`);
    }
    throw new Error('An unexpected network error occurred');
  }
}


/**
 * Interface representing the CSEC ASTU Welcome data fetched from backend.
 */
export interface WelcomeData {
  organization: string;
  division: string;
  heading: string;
  subtitle: string;
  welcomeMessage: string;
  description: string;
  environment: string;
  timestamp: string;
}

/**
 * State for async data loading in React component.
 */
export interface FetchState<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
}


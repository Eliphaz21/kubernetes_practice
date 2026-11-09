import React, { useEffect, useState } from 'react';
import { WelcomeData, FetchState } from '../types/welcome';
import { fetchWelcomeData } from '../services/api';

/**
 * Welcome Component - Primary view for CSEC Welcome landing page.
 * Retrieves data from the Express backend API and presents community details.
 */
export const Welcome: React.FC = () => {
  const [state, setState] = useState<FetchState<WelcomeData>>({
    data: null,
    loading: true,
    error: null,
  });

  const loadData = async (): Promise<void> => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const data = await fetchWelcomeData();
      setState({ data, loading: false, error: null });
    } catch (err: unknown) {
      const errorMessage =
        err instanceof Error ? err.message : 'Failed to communicate with backend API';
      setState({ data: null, loading: false, error: errorMessage });
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  return (
    <section className="hero-section">
      <h1 className="hero-heading">
        {state.data ? state.data.heading : 'CSEC ASTU'}
      </h1>
      <h2 className="hero-subtitle">
        {state.data ? state.data.subtitle : 'Development Division'}
      </h2>

      {state.loading && (
        <div className="status-box status-loading" role="status">
          <p>Connecting to backend service...</p>
        </div>
      )}

      {state.error && (
        <div className="status-box status-error" role="alert">
          <p>
            <strong>Service Notice:</strong> {state.error}
          </p>
          <button className="btn-retry" onClick={loadData}>
            Retry Connection
          </button>
        </div>
      )}

      {state.data && (
        <>
          <p className="welcome-message">{state.data.welcomeMessage}</p>
          <p className="welcome-description">{state.data.description}</p>

          <div className="meta-details">
            <div className="meta-item">
              <strong>Organization:</strong> {state.data.organization}
            </div>
            <div className="meta-item">
              <strong>Division:</strong> {state.data.division}
            </div>
            <div className="meta-item">
              <strong>Environment:</strong> {state.data.environment}
            </div>
            <div className="meta-item">
              <strong>API Verified At:</strong> {new Date(state.data.timestamp).toLocaleString()}
            </div>
          </div>
        </>
      )}
    </section>
  );
};


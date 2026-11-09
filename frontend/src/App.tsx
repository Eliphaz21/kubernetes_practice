import React from 'react';
import { Welcome } from './components/Welcome';

export const App: React.FC = () => {
  return (
    <div className="page-container">
      <header className="site-header">
        <div className="header-content">
          <div className="brand-title">CSEC ASTU</div>
          <div className="brand-tag">Development Division</div>
        </div>
      </header>

      <main className="main-content">
        <Welcome />
      </main>

      <footer className="site-footer">
        <p>
          &copy; {new Date().getFullYear()} CSEC ASTU – Computer Science &amp;
          Engineering Club. Adama Science and Technology University.
        </p>
      </footer>
    </div>
  );
};

export default App;


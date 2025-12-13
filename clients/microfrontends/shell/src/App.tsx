import React, { useState } from 'react';
import { ThemeProvider, useTheme } from './contexts/ThemeContext';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import Sidebar from './components/Layout/Sidebar';
import Header from './components/Layout/Header';
import RemoteApp from './components/RemoteApp';

const AppContent: React.FC = () => {
  const { isAuthenticated, login } = useAuth();
  const { theme } = useTheme();
  const [currentPage, setCurrentPage] = useState('home');

  if (!isAuthenticated) {
    return (
      <RemoteApp
        moduleName="auth"
        theme={theme}
        onAuth={login}
      />
    );
  }

  return (
    <div className="flex h-screen overflow-hidden">
      <Sidebar currentPage={currentPage} onNavigate={setCurrentPage} />
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />
        <main className="flex-1 overflow-hidden bg-gray-50">
          {/* Student Pages */}
          {/* Home page is the Dashboard */}
          {currentPage === 'home' && (
            <RemoteApp
              moduleName="dashboard"
              theme={theme}
            />
          )}
          {/* Explore */}
          {currentPage === 'explore' && (
            <RemoteApp
              moduleName="courses"
              theme={theme}
            />
          )}
          {/* My Learning - Coming Soon */}
          {currentPage === 'learning' && (
            <div className="flex-1 p-8 flex items-center justify-center">
              <h1 className="text-2xl font-bold text-gray-400">My Learning - Coming Soon</h1>
            </div>
          )}
          {/* Wishlist - Coming Soon */}
          {currentPage === 'wishlist' && (
            <div className="flex-1 p-8 flex items-center justify-center">
              <h1 className="text-2xl font-bold text-gray-400">Wishlist - Coming Soon</h1>
            </div>
          )}
          {/* Profile - Coming Soon */}
          {currentPage === 'profile' && (
            <div className="flex-1 p-8 flex items-center justify-center">
              <h1 className="text-2xl font-bold text-gray-400">Profile - Coming Soon</h1>
            </div>
          )}

          {/* Professor Pages - All load Dashboard microfrontend with page parameter */}
          {currentPage === 'professor-dashboard' && (
            <RemoteApp
              moduleName="dashboard"
              theme={theme}
              page="professor-dashboard"
            />
          )}
          {currentPage === 'my-courses' && (
            <RemoteApp
              moduleName="dashboard"
              theme={theme}
              page="my-courses"
            />
          )}
          {currentPage === 'students' && (
            <RemoteApp
              moduleName="dashboard"
              theme={theme}
              page="students"
            />
          )}
          {currentPage === 'analytics' && (
            <RemoteApp
              moduleName="dashboard"
              theme={theme}
              page="analytics"
            />
          )}
          {currentPage === 'settings' && (
            <RemoteApp
              moduleName="dashboard"
              theme={theme}
              page="settings"
            />
          )}
        </main>
      </div>
    </div>
  );
};

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <AppContent />
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;

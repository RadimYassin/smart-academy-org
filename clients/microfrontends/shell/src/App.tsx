import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider } from './contexts/ThemeContext';
import { AuthProvider } from './contexts/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';
import MainLayout from './components/Layout/MainLayout';
import AuthPage from './pages/AuthPage';
import Dashboard from './pages/Dashboard';
import Courses from './pages/Courses';

function App() {
  return (
    <BrowserRouter>
      <ThemeProvider>
        <AuthProvider>
          <Routes>
            {/* Auth Route - Public */}
            <Route path="/auth" element={<AuthPage />} />

            {/* Protected Routes with Layout */}
            <Route
              path="/"
              element={
                <ProtectedRoute>
                  <MainLayout />
                </ProtectedRoute>
              }
            >
              <Route index element={<Dashboard />} />
              <Route path="dashboard" element={<Dashboard />} />

              {/* Teacher Routes */}
              <Route path="teacher/dashboard" element={<Dashboard />} />
              <Route path="teacher/courses" element={<Courses />} />
              <Route path="teacher/students" element={<div className="p-8"><h1 className="text-2xl font-bold text-gray-400">Students - Coming Soon</h1></div>} />
              <Route path="teacher/analytics" element={<div className="p-8"><h1 className="text-2xl font-bold text-gray-400">Analytics - Coming Soon</h1></div>} />
              <Route path="teacher/settings" element={<div className="p-8"><h1 className="text-2xl font-bold text-gray-400">Settings - Coming Soon</h1></div>} />

              {/* Student Routes */}
              <Route path="student/dashboard" element={<Dashboard />} />
              <Route path="student/explore" element={<Courses />} />
              <Route path="student/learning" element={<div className="p-8"><h1 className="text-2xl font-bold text-gray-400">My Learning - Coming Soon</h1></div>} />
              <Route path="student/wishlist" element={<div className="p-8"><h1 className="text-2xl font-bold text-gray-400">Wishlist - Coming Soon</h1></div>} />
              <Route path="student/profile" element={<div className="p-8"><h1 className="text-2xl font-bold text-gray-400">Profile - Coming Soon</h1></div>} />

              {/* Legacy routes (for backwards compatibility) */}
              <Route path="courses" element={<Courses />} />
              <Route path="learning" element={<div className="p-8"><h1 className="text-2xl font-bold text-gray-400">My Learning - Coming Soon</h1></div>} />
              <Route path="wishlist" element={<div className="p-8"><h1 className="text-2xl font-bold text-gray-400">Wishlist - Coming Soon</h1></div>} />
              <Route path="profile" element={<div className="p-8"><h1 className="text-2xl font-bold text-gray-400">Profile - Coming Soon</h1></div>} />
            </Route>

            {/* Catch all - redirect to home */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </AuthProvider>
      </ThemeProvider>
    </BrowserRouter>
  );
}

export default App;

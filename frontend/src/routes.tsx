import { Routes, Route } from 'react-router-dom';
import HomePage from './pages/HomePage';

function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<HomePage />} />
      {/* TODO: Add more routes */}
      {/* <Route path="/login" element={<LoginPage />} /> */}
      {/* <Route path="/register" element={<RegisterPage />} /> */}
      {/* <Route path="/dashboard" element={<DashboardPage />} /> */}
      {/* <Route path="/chat" element={<ChatPage />} /> */}
      {/* <Route path="/quests" element={<QuestsPage />} /> */}
      {/* <Route path="/profile" element={<ProfilePage />} /> */}
    </Routes>
  );
}

export default AppRoutes;

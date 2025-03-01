"use client";
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import SignIn from './sign-in/SignIn';
import SignUp from './sign-up/SignUp';
import MarketingPage from './home-page/MarketingPage';
import AppTheme from './shared-theme/AppTheme'

function App() {
  return (
    <AppTheme>
    <Router>
      <Routes>
        <Route path="/sign-in" element={<SignIn />} />
        <Route path="/sign-up" element={<SignUp />} />
        <Route path="/home-page" element={<MarketingPage />} /> {/* Home page */}
        <Route path="*" element={<MarketingPage />} /> {/* Default route to SignIn */}
      </Routes>
    </Router>
    </AppTheme>
  );
}

export default App;
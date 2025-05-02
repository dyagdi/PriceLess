"use client";
import { Route, Routes } from 'react-router-dom';
import SignIn from './sign-in/SignIn';
import SignUp from './sign-up/SignUp';
import MarketingPage from './home-page/MarketingPage';
import FavoritesPage from './favorites/page';
import MyBasket from './components/MyBasket';

function App() {
  return (
    <Routes>
      <Route path="/sign-in" element={<SignIn />} />
      <Route path="/sign-up" element={<SignUp />} />
      <Route path="/home-page" element={<MarketingPage />} /> {/* Home page */}
      <Route path="/favorites" element={<FavoritesPage />} /> {/* Favorites page */}
      <Route path="/my-basket" element={<MyBasket />} />
      <Route path="*" element={<MarketingPage />} /> {/* Default route to SignIn */}
    </Routes>
  );
}

export default App;

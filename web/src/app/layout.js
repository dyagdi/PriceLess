'use client';
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { BrowserRouter } from 'react-router-dom';
import { BasketProvider } from './context/BasketContext';
import AppTheme from './shared-theme/AppTheme'
import { FavoritesProvider } from './context/FavoritesContext';


export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <BrowserRouter>
          <BasketProvider>
            <FavoritesProvider>
              <AppTheme>
                {children}
              </AppTheme>
            </FavoritesProvider>
          </BasketProvider>
        </BrowserRouter>
      </body>
    </html>
  );
}

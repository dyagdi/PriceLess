'use client';
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { BrowserRouter } from 'react-router-dom';
import { BasketProvider } from './context/BasketContext';
import AppTheme from './shared-theme/AppTheme'


export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body >
          <BasketProvider>
          {children}
          </BasketProvider>
      </body>
    </html>
  );
}

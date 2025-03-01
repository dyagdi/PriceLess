'use client';
import { BasketProvider } from './context/BasketContext';

export default function ClientLayout({ children }) {
  return (
    <BasketProvider>
      {children}
    </BasketProvider>
  );
} 
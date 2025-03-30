'use client';

import React from 'react';
import { useRouter } from 'next/navigation';
import AppAppBar from './AppAppBar';

// This is a simple higher-order component that provides a mock useNavigate function
// that uses Next.js router instead of React Router

// Mock the useNavigate hook to work with Next.js
const MockRouterContext = React.createContext({
  navigate: (path) => {}
});

// Export the context so it can be imported in AppAppBar.js
export const UseNavigateContext = MockRouterContext;

export default function AppAppBarNextAdapter() {
  const router = useRouter();
  
  // Create a navigate function that mimics React Router's useNavigate but uses Next.js router
  const navigate = React.useCallback((path) => {
    router.push(path);
  }, [router]);
  
  return (
    <MockRouterContext.Provider value={{ navigate }}>
      <AppAppBar />
    </MockRouterContext.Provider>
  );
} 
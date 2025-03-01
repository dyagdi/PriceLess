'use client';
import * as React from 'react';
import CssBaseline from '@mui/material/CssBaseline';
import Divider from '@mui/material/Divider';
import CircularProgress from '@mui/material/CircularProgress';
import Box from '@mui/material/Box';
import Alert from '@mui/material/Alert';
import AppAppBar from '../components/AppAppBar';
import Hero from '../components/Hero';
import LogoCollection from '../components/LogoCollection';
import Markets from '../components/Markets';
import Discounts from '../components/Discounts';
import Populars from '../components/Populars';
import FAQ from '../components/FAQ';
import Footer from '../components/Footer';
import AppTheme from '../shared-theme/AppTheme';
import Categories from '../components/Categories';

// Define API endpoint base URL as a constant
const API_BASE_URL = 'http://127.0.0.1:8000/api';

export default function MarketingPage(props) {
  const [cheapestProducts, setCheapestProducts] = React.useState([]);
  const [marketProducts, setMarketProducts] = React.useState([]);
  const [popularProducts, setPopularProducts] = React.useState([]);
  const [categoryProducts, setCategoryProducts] = React.useState([]);
  const [isLoading, setIsLoading] = React.useState(true);
  const [error, setError] = React.useState(null);

  React.useEffect(() => {
    const fetchData = async () => {
      setIsLoading(true);
      setError(null);
      
      try {
        const [cheapestData, marketsData, productsData, categoryData] = await Promise.all([
          fetchApi('/cheapest-products/'),
          fetchApi('/markets-products/'),
          fetchApi('/products/'),
          fetchApi('/cheapest-products-per-category/')
        ]);
        
        setCheapestProducts(cheapestData);
        setMarketProducts(marketsData);
        setPopularProducts(Array.isArray(productsData) ? productsData.slice(0, 8) : []);
        setCategoryProducts(categoryData);
      } catch (err) {
        console.error('Error fetching data:', err);
        setError('Failed to load product data. Please try again later.');
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  // Helper function to fetch data from API
  const fetchApi = async (endpoint) => {
    const response = await fetch(`${API_BASE_URL}${endpoint}`);
    
    if (!response.ok) {
      throw new Error(`API request failed with status ${response.status}`);
    }
    
    return await response.json();
  };

  // Render loading state
  if (isLoading) {
    return (
      <AppTheme {...props}>
        <CssBaseline enableColorScheme />
        <AppAppBar />
        <Box 
          sx={{ 
            display: 'flex', 
            justifyContent: 'center', 
            alignItems: 'center', 
            minHeight: '50vh' 
          }}
        >
          <CircularProgress />
        </Box>
      </AppTheme>
    );
  }

  // Render error state
  if (error) {
    return (
      <AppTheme {...props}>
        <CssBaseline enableColorScheme />
        <AppAppBar />
        <Box 
          sx={{ 
            display: 'flex', 
            justifyContent: 'center', 
            alignItems: 'center', 
            minHeight: '50vh', 
            p: 3 
          }}
        >
          <Alert severity="error">{error}</Alert>
        </Box>
      </AppTheme>
    );
  }

  return (
    <AppTheme {...props}>
      <CssBaseline enableColorScheme />
      <AppAppBar />
      <Hero />
      <div>
        <Divider />
        <Discounts products={cheapestProducts} />
        <Divider />
        <Categories categoryProducts={categoryProducts} />
        <Divider />
        <Populars products={popularProducts} />
        <Divider />
        <Markets marketProducts={marketProducts} />
        <Divider />
        <FAQ />
        <Divider />
        <Footer />
        <LogoCollection />
      </div>
    </AppTheme>
  );
}

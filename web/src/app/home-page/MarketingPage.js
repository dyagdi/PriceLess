'use client';
import * as React from 'react';
import CssBaseline from '@mui/material/CssBaseline';
import Divider from '@mui/material/Divider';
import CircularProgress from '@mui/material/CircularProgress';
import Box from '@mui/material/Box';
import Alert from '@mui/material/Alert';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
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
            flexDirection: 'column',
            justifyContent: 'center', 
            alignItems: 'center', 
            minHeight: '70vh',
            pt: 10
          }}
        >
          <CircularProgress size={60} thickness={4} />
          <Typography variant="h6" sx={{ mt: 3, fontWeight: 500 }}>
            Ürünler Yükleniyor...
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
            En iyi fiyatları buluyoruz
          </Typography>
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
            minHeight: '70vh',
            p: 3,
            pt: 10
          }}
        >
          <Paper 
            elevation={0} 
            sx={{ 
              p: 4, 
              maxWidth: 600, 
              borderRadius: 2,
              border: '1px solid',
              borderColor: 'error.light',
              bgcolor: 'error.lightest'
            }}
          >
            <Alert 
              severity="error" 
              variant="outlined"
              sx={{ mb: 2 }}
            >
              {error}
            </Alert>
            <Typography variant="body1" sx={{ mb: 2 }}>
              Ürün verilerini yüklerken bir sorun oluştu. Lütfen daha sonra tekrar deneyin veya müşteri hizmetlerimizle iletişime geçin.
            </Typography>
            <Button 
              variant="contained" 
              color="primary"
              onClick={() => window.location.reload()}
            >
              Tekrar Dene
            </Button>
          </Paper>
        </Box>
      </AppTheme>
    );
  }

  // Section divider with enhanced styling
  const StyledDivider = () => (
    <Box 
      sx={{ 
        position: 'relative', 
        py: 4,
        overflow: 'hidden'
      }}
    >
      <Divider />
      <Box 
        sx={{ 
          position: 'absolute', 
          left: '50%', 
          top: '50%', 
          transform: 'translate(-50%, -50%)',
          width: 50,
          height: 50,
          borderRadius: '50%',
          bgcolor: 'background.paper',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          zIndex: 1,
          boxShadow: '0 0 0 4px rgba(0,0,0,0.03)'
        }}
      >
        <Box 
          sx={{ 
            width: 8, 
            height: 8, 
            borderRadius: '50%', 
            bgcolor: 'primary.main',
            opacity: 0.7
          }} 
        />
      </Box>
    </Box>
  );

  return (
    <AppTheme {...props}>
      <CssBaseline enableColorScheme />
      <AppAppBar />
      <Hero />
      <Box sx={{ overflow: 'hidden' }}>
        {/* Discounted Products Section */}
        <Box 
          sx={{ 
            position: 'relative',
            py: 2,
            '&::before': {
              content: '""',
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              bottom: '50%',
              background: 'linear-gradient(180deg, rgba(245,247,250,0.5) 0%, rgba(255,255,255,0) 100%)',
              zIndex: -1
            }
          }}
        >
          <StyledDivider />
          <Discounts products={cheapestProducts} />
        </Box>
        
        {/* Categories Section */}
        <Box 
          sx={{ 
            position: 'relative',
            py: 2,
            '&::before': {
              content: '""',
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              height: '30%',
              background: 'radial-gradient(circle at 70% 20%, rgba(240,247,255,0.4) 0%, rgba(255,255,255,0) 70%)',
              zIndex: -1
            }
          }}
        >
          <StyledDivider />
          <Categories categoryProducts={categoryProducts} />
        </Box>
        
        {/* Popular Products Section */}
        <Box 
          sx={{ 
            position: 'relative',
            py: 2,
            '&::before': {
              content: '""',
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              height: '40%',
              background: 'linear-gradient(135deg, rgba(245,250,255,0.4) 0%, rgba(255,255,255,0) 60%)',
              zIndex: -1
            }
          }}
        >
          <StyledDivider />
          <Populars products={popularProducts} />
        </Box>
        
        {/* Markets Section */}
        <Box 
          sx={{ 
            position: 'relative',
            py: 2,
            '&::before': {
              content: '""',
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              height: '30%',
              background: 'radial-gradient(circle at 30% 20%, rgba(240,247,255,0.4) 0%, rgba(255,255,255,0) 70%)',
              zIndex: -1
            }
          }}
        >
          <StyledDivider />
          <Markets marketProducts={marketProducts} />
        </Box>
        
        {/* FAQ Section */}
        <Box 
          sx={{ 
            position: 'relative',
            py: 2,
            bgcolor: 'background.paper',
            boxShadow: 'inset 0 4px 8px -4px rgba(0,0,0,0.05), inset 0 -4px 8px -4px rgba(0,0,0,0.05)'
          }}
        >
          <StyledDivider />
          <FAQ />
        </Box>
        
        {/* Footer Section */}
        <Box 
          sx={{ 
            bgcolor: (theme) => 
              theme.palette.mode === 'light' 
                ? 'rgba(245,247,250,0.8)' 
                : 'rgba(10,15,25,0.8)',
            pt: 2
          }}
        >
          <StyledDivider />
          <Footer />
          <LogoCollection />
        </Box>
      </Box>
    </AppTheme>
  );
}

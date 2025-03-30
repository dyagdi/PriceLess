'use client';

import React from 'react';
import { 
  Box, 
  Typography, 
  Container, 
  Grid, 
  Button,
  Paper,
  Divider,
  alpha,
  Breadcrumbs,
  IconButton,
  Tooltip,
  useMediaQuery,
  Chip,
  useTheme
} from '@mui/material';
import ProductCard from '../components/ProductCard';
import { useFavorites } from '../context/FavoritesContext';
import FavoriteBorderIcon from '@mui/icons-material/FavoriteBorder';
import HomeIcon from '@mui/icons-material/Home';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import NavigateNextIcon from '@mui/icons-material/NavigateNext';
import SortIcon from '@mui/icons-material/Sort';
import FavoriteIcon from '@mui/icons-material/Favorite';
import DeleteSweepIcon from '@mui/icons-material/DeleteSweep';
import Link from 'next/link';
import AppAppBar from '../components/AppAppBar';
import { useNavigate } from 'react-router-dom';

export default function FavoritesPage() {
  const { favorites, clearFavorites } = useFavorites();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const navigate = useNavigate();

  // Use a more restricted max width for better spacing on sides
  const contentMaxWidth = "lg"; // This is more restricted than "xl"

  // Use useEffect to handle hash navigation when page loads
  React.useEffect(() => {
    // Check if there's a hash in the URL
    if (window.location.hash) {
      // Get the ID from the hash
      const id = window.location.hash.substring(1);
      // Find the element and scroll to it
      const element = document.getElementById(id);
      if (element) {
        setTimeout(() => {
          element.scrollIntoView({ behavior: 'smooth' });
        }, 100); // Small delay to ensure the page is fully loaded
      }
    }
  }, []);

  return (
    <>
      <AppAppBar />
      <Box 
        sx={{ 
          minHeight: 'calc(100vh - 64px)',
          pt: { xs: 8, sm: 10 },
          pb: 8,
          backgroundColor: 'background.default',
          position: 'relative',
          overflow: 'hidden',
          '&::before': {
            content: '""',
            position: 'absolute',
            top: 0,
            right: 0,
            width: '40%',
            height: '30%',
            background: alpha(theme.palette.primary.main, 0.03),
            borderRadius: '0 0 0 100%',
            zIndex: 0
          },
          '&::after': {
            content: '""',
            position: 'absolute',
            bottom: 0,
            left: 0,
            width: '30%',
            height: '25%',
            background: alpha(theme.palette.primary.main, 0.03),
            borderRadius: '0 100% 0 0',
            zIndex: 0
          }
        }}
      >
        {/* Breadcrumbs with more side padding */}
        <Container 
          maxWidth={contentMaxWidth} 
          sx={{ 
            mt: 2, 
            mb: 1,
            px: { xs: 3, sm: 4, md: 5 }, // Increased side padding
            position: 'relative',
            zIndex: 1
          }}
        >
          <Breadcrumbs 
            separator={<NavigateNextIcon fontSize="small" />} 
            aria-label="breadcrumb"
            sx={{ 
              mb: 2, 
              '& .MuiBreadcrumbs-ol': {
                flexWrap: 'nowrap',
              }
            }}
          >
            <Button
              onClick={() => navigate('/')}
              sx={{ 
                textDecoration: 'none', 
                display: 'flex', 
                alignItems: 'center',
                p: 0,
                minWidth: 'auto',
                color: 'text.secondary',
                textTransform: 'none',
                '&:hover': {
                  backgroundColor: 'transparent',
                  color: theme.palette.primary.main,
                }
              }}
            >
              <HomeIcon sx={{ mr: 0.5, fontSize: 18, color: theme.palette.primary.main }} />
              <Typography variant="body2" color="inherit">Anasayfa</Typography>
            </Button>
            <Typography variant="body2" color="text.primary" fontWeight={600}>
              Favorilerim
            </Typography>
          </Breadcrumbs>
        </Container>

        {/* Hero Section with extra side spacing */}
        <Box
          sx={{
            mb: 4,
            py: { xs: 3, md: 4 },
            position: 'relative',
            boxShadow: '0 4px 20px rgba(0,0,0,0.03)',
            backgroundColor: alpha(theme.palette.background.paper, 0.7),
            backdropFilter: 'blur(8px)',
            zIndex: 1
          }}
        >
          <Container 
            maxWidth={contentMaxWidth}
            sx={{ 
              px: { xs: 3, sm: 4, md: 5 } // Increased side padding
            }}
          >
            <Grid container spacing={3} alignItems="center">
              <Grid item xs={12} md={7}>
                <Box sx={{ pl: { md: 2, lg: 3 } }}>
                  <Typography 
                    variant="h4" 
                    component="h1" 
                    fontWeight={700}
                    sx={{ 
                      mb: 2,
                      background: `linear-gradient(135deg, ${theme.palette.primary.main} 0%, ${theme.palette.primary.dark} 100%)`,
                      WebkitBackgroundClip: 'text',
                      WebkitTextFillColor: 'transparent',
                      display: 'inline-block'
                    }}
                  >
                    Favori Ürünleriniz
                  </Typography>
                  <Typography 
                    variant="subtitle1" 
                    color="text.secondary"
                    sx={{ 
                      mb: 3,
                      maxWidth: 600,
                      lineHeight: 1.6
                    }}
                  >
                    Beğendiğiniz ürünleri tek bir yerde görebilir, fiyat değişimlerini takip edebilir ve istediğiniz zaman sepetinize ekleyebilirsiniz.
                  </Typography>
                  {favorites.length > 0 && (
                    <Chip 
                      icon={<FavoriteIcon fontSize="small" />} 
                      label={`${favorites.length} ürün`}
                      color="primary"
                      sx={{ 
                        fontWeight: 600, 
                        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                        '& .MuiChip-icon': { color: 'inherit' },
                        px: 1.5,
                        py: 2.5
                      }}
                    />
                  )}
                </Box>
              </Grid>
              <Grid item xs={12} md={5} sx={{ display: { xs: 'none', md: 'block' } }}>
                <Box 
                  sx={{ 
                    display: 'flex', 
                    justifyContent: 'center', 
                    position: 'relative',
                    height: '180px'
                  }}
                >
                  <Box 
                    sx={{ 
                      position: 'absolute', 
                      width: '300px',
                      height: '300px',
                      top: '-100px',
                      right: { md: '0px', lg: '20px' },
                      opacity: 0.1,
                      borderRadius: '50%',
                      background: `radial-gradient(circle, ${theme.palette.primary.main} 0%, ${theme.palette.background.paper} 70%)`,
                      zIndex: 0
                    }} 
                  />
                  <Box 
                    component="img"
                    src="/favorites-illustration.svg" 
                    alt="Favorites"
                    sx={{
                      height: 180,
                      maxWidth: '100%',
                      objectFit: 'contain',
                      zIndex: 1,
                      filter: 'drop-shadow(0px 10px 20px rgba(0,0,0,0.08))'
                    }}
                    onError={(e) => {
                      e.target.style.display = 'none';
                      const parent = e.target.parentElement;
                      const fallbackIcon = document.createElement('div');
                      fallbackIcon.innerHTML = `<svg width="180" height="180" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="${theme.palette.primary.main}" />
                      </svg>`;
                      parent.appendChild(fallbackIcon);
                    }}
                  />
                </Box>
              </Grid>
            </Grid>
          </Container>
        </Box>

        {/* Main content with extra side spacing */}
        <Container 
          maxWidth={contentMaxWidth}
          sx={{ 
            px: { xs: 3, sm: 4, md: 5 }, // Increased side padding
            position: 'relative',
            zIndex: 1
          }}
        >
          {/* Empty State */}
          {favorites.length === 0 ? (
            <Paper
              elevation={0}
              sx={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                p: { xs: 4, md: 8 },
                textAlign: 'center',
                borderRadius: 2,
                minHeight: 400,
                overflow: 'hidden',
                position: 'relative',
                mx: { xs: 0, md: 3 }, // Extra horizontal margin for desktop
                border: `1px solid ${alpha(theme.palette.divider, 0.1)}`,
                boxShadow: '0 8px 40px rgba(0,0,0,0.05)'
              }}
            >
              <Box
                sx={{
                  position: 'absolute',
                  top: 0,
                  left: 0,
                  right: 0,
                  height: '8px',
                  background: `linear-gradient(90deg, ${theme.palette.primary.light}, ${theme.palette.primary.main}, ${theme.palette.primary.dark})`,
                  opacity: 0.8
                }}
              />
              
              <Box
                sx={{
                  display: 'flex',
                  justifyContent: 'center',
                  alignItems: 'center',
                  mb: 4,
                  width: 120,
                  height: 120,
                  borderRadius: '50%',
                  backgroundColor: alpha(theme.palette.primary.main, 0.1),
                  boxShadow: `0 0 0 12px ${alpha(theme.palette.primary.main, 0.05)}`
                }}
              >
                <FavoriteBorderIcon
                  sx={{
                    fontSize: 60,
                    color: theme.palette.primary.main
                  }}
                />
              </Box>
              
              <Typography
                variant="h5"
                sx={{
                  fontWeight: 700,
                  mb: 2,
                }}
              >
                Henüz favorilerinizde ürün bulunmuyor
              </Typography>
              
              <Typography
                variant="body1"
                sx={{
                  maxWidth: 580,
                  mb: 5,
                  lineHeight: 1.7,
                  px: { xs: 1, sm: 2, md: 4 }, // Add internal padding for text
                  color: alpha(theme.palette.text.primary, 0.8)
                }}
              >
                Beğendiğiniz ürünleri favorilerinize ekleyerek fiyat değişikliklerini takip edebilir, 
                kampanyaları kaçırmadan istediğiniz zaman kolayca satın alabilirsiniz. 
                Ürünlerin yanındaki kalp simgesine tıklayarak favorilerinize ekleyebilirsiniz.
              </Typography>
              
              <Button
                variant="contained"
                onClick={() => navigate('/')}
                startIcon={<ShoppingCartIcon />}
                size="large"
                sx={{
                  px: 4,
                  py: 1.5,
                  borderRadius: 2,
                  fontWeight: 600,
                  textTransform: 'none',
                  fontSize: '1rem',
                  boxShadow: '0 8px 16px rgba(0,0,0,0.15)',
                  background: `linear-gradient(to right, ${theme.palette.primary.main}, ${theme.palette.primary.dark})`,
                  '&:hover': {
                    boxShadow: '0 10px 20px rgba(0,0,0,0.2)',
                    transform: 'translateY(-2px)',
                    background: `linear-gradient(to right, ${theme.palette.primary.dark}, ${theme.palette.primary.main})`,
                  },
                  transition: 'all 0.3s ease'
                }}
              >
                Alışverişe Başla
              </Button>
            </Paper>
          ) : (
            /* Products Grid with Controls */
            <>
              <Paper
                elevation={0}
                sx={{
                  p: { xs: 2, md: 3 },
                  borderRadius: 2,
                  mb: 4,
                  border: `1px solid ${alpha(theme.palette.divider, 0.1)}`,
                  boxShadow: '0 4px 20px rgba(0,0,0,0.03)'
                }}
              >
                <Box
                  sx={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    mb: 2,
                    flexWrap: 'wrap',
                    gap: 2
                  }}
                >
                  <Box>
                    <Typography
                      variant="h6"
                      sx={{
                        fontWeight: 600,
                        mb: 0.5,
                        color: theme.palette.primary.main
                      }}
                    >
                      Favori Ürünleriniz
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Özenle seçtiğiniz {favorites.length} ürün listenizde
                    </Typography>
                  </Box>
                  
                  <Box sx={{ display: 'flex', gap: 1 }}>
                    <Tooltip title="Sırala">
                      <Button
                        variant="outlined"
                        size="small"
                        startIcon={<SortIcon />}
                        sx={{
                          borderRadius: '8px',
                          borderColor: alpha(theme.palette.primary.main, 0.5),
                          color: theme.palette.primary.main,
                          px: 2,
                          '&:hover': {
                            borderColor: theme.palette.primary.main,
                            backgroundColor: alpha(theme.palette.primary.main, 0.05)
                          }
                        }}
                      >
                        {isMobile ? "" : "Sırala"}
                      </Button>
                    </Tooltip>
                    
                    <Tooltip title="Tüm favorileri temizle">
                      <Button
                        variant="outlined"
                        color="error"
                        size="small"
                        startIcon={<DeleteSweepIcon />}
                        onClick={clearFavorites}
                        sx={{
                          borderRadius: '8px',
                          px: 2,
                          '&:hover': {
                            backgroundColor: alpha(theme.palette.error.main, 0.05)
                          }
                        }}
                      >
                        {isMobile ? "" : "Temizle"}
                      </Button>
                    </Tooltip>
                  </Box>
                </Box>
                
                <Divider sx={{ mb: 3 }} />
                
                {/* Adjust grid spacing and reduce columns for better product size */}
                <Grid 
                  container 
                  spacing={2}
                  sx={{ 
                    mb: 1
                  }}
                >
                  {favorites.map((product) => (
                    <Grid item key={product.id} xs={6} sm={6} md={4} lg={3} xl={3}>
                      <ProductCard product={product} />
                    </Grid>
                  ))}
                </Grid>
              </Paper>
            </>
          )}
        </Container>
      </Box>
    </>
  );
} 

import * as React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
//import InputLabel from '@mui/material/InputLabel';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import Grid from '@mui/material/Grid';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import { useTheme } from '@mui/material/styles';
//import { visuallyHidden } from '@mui/utils';
//import { styled } from '@mui/material/styles';
import LocalOfferIcon from '@mui/icons-material/LocalOffer';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import FavoriteIcon from '@mui/icons-material/Favorite';
import SearchIcon from '@mui/icons-material/Search';
import InputAdornment from '@mui/material/InputAdornment';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';

/*const StyledBox = styled('div')(({ theme }) => ({
  alignSelf: 'center',
  width: '100%',
  height: 400,
  marginTop: theme.spacing(8),
  borderRadius: (theme.vars || theme).shape.borderRadius,
  outline: '6px solid',
  outlineColor: 'hsla(220, 25%, 80%, 0.2)',
  border: '1px solid',
  borderColor: (theme.vars || theme).palette.grey[200],
  boxShadow: '0 0 12px 8px hsla(220, 25%, 80%, 0.2)',
  backgroundImage: `url(${process.env.TEMPLATE_IMAGE_URL || 'https://mui.com'}/static/screenshots/material-ui/getting-started/templates/dashboard.jpg)`,
  backgroundSize: 'cover',
  [theme.breakpoints.up('sm')]: {
    marginTop: theme.spacing(10),
    height: 700,
  },
  ...theme.applyStyles('dark', {
    boxShadow: '0 0 24px 12px hsla(210, 100%, 25%, 0.2)',
    backgroundImage: `url(${process.env.TEMPLATE_IMAGE_URL || 'https://mui.com'}/static/screenshots/material-ui/getting-started/templates/dashboard-dark.jpg)`,
    outlineColor: 'hsla(220, 20%, 42%, 0.1)',
    borderColor: (theme.vars || theme).palette.grey[700],
  }),
}));*/

export default function Hero() {
  const theme = useTheme();
  const brandColor = theme.palette.primary.main;
  
  return (
    <>
      {/* Delivery Address Section */}
      <Box
        sx={{
          width: '100%',
          backgroundColor: 'white',
          mt: { xs: '48px', sm: '56px' }, // Updated to match new AppBar height
          borderBottom: '1px solid',
          borderColor: 'rgba(0,0,0,0.05)',
          position: 'relative',
          zIndex: 1,
        }}
      >
        <Container
          sx={{
            py: 1.5,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <LocationOnIcon sx={{ color: '#68B96A', mr: 1, fontSize: '20px' }} />
            <Box>
              <Typography 
                variant="caption" 
                sx={{ 
                  color: 'text.secondary',
                  display: 'block',
                  fontSize: '0.7rem',
                  lineHeight: 1.2,
                }}
              >
                Teslimat Adresi
              </Typography>
              <Typography 
                variant="body2" 
                sx={{ 
                  fontWeight: 500,
                  color: 'text.primary',
                  fontSize: '0.875rem',
                  lineHeight: 1.2,
                }}
              >
                Union Square, Ellis St, San Francisco
              </Typography>
            </Box>
          </Box>
          <KeyboardArrowDownIcon sx={{ color: '#68B96A', fontSize: '20px' }} />
        </Container>
      </Box>
      
      <Box
        id="hero"
        sx={{
          width: '100%',
          backgroundColor: '#9ED0A0', // Updated to match the mobile app color
          borderRadius: '0 0 16px 16px',
          mb: 3,
          position: 'relative',
          zIndex: 1,
        }}
      >
        <Container
          sx={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'flex-start',
            pt: { xs: 4, sm: 5 },
            pb: { xs: 4, sm: 5 },
          }}
        >
          <Typography 
            variant="h3" 
            sx={{ 
              color: 'primary.dark',
              fontWeight: 'bold',
              mb: 0.5,
              fontSize: { xs: '1.75rem', sm: '2.25rem' },
            }}
          >
            Hoş Geldiniz!
          </Typography>
          <Typography
            variant="body1"
            sx={{
              color: 'primary.dark',
              width: { sm: '100%', md: '80%' },
              mb: 2.5,
              fontSize: { xs: '0.875rem', sm: '1rem' },
            }}
          >
            En uygun fiyatlı ürünleri keşfedin
          </Typography>
          
          <Box sx={{ width: '100%', mb: 2 }}>
            <TextField
              placeholder="Ürün, marka veya kategori ara"
              variant="outlined"
              fullWidth
              sx={{
                backgroundColor: 'white',
                borderRadius: 8,
                '& .MuiOutlinedInput-root': {
                  borderRadius: 8,
                  height: 42,
                  '& fieldset': {
                    borderColor: 'rgba(0,0,0,0.08)',
                    borderWidth: '1px',
                  },
                  '&:hover fieldset': {
                    borderColor: 'rgba(0,0,0,0.12)',
                  },
                  '&.Mui-focused fieldset': {
                    borderColor: '#68B96A',
                    borderWidth: '1px',
                  },
                  boxShadow: '0 2px 4px rgba(0,0,0,0.05)',
                },
                '& .MuiInputBase-input': {
                  '&::placeholder': {
                    color: 'rgba(0, 0, 0, 0.45)',
                    opacity: 1,
                  },
                  fontSize: '0.875rem',
                  padding: '10px 14px',
                },
              }}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <SearchIcon sx={{ color: 'rgba(0, 0, 0, 0.45)' }} />
                  </InputAdornment>
                ),
              }}
            />
          </Box>
          
          <Button
            variant="contained"
            color="primary"
            size="medium"
            sx={{ 
              minWidth: 'fit-content',
              color: 'white',
              borderRadius: 8,
              textTransform: 'none',
              fontWeight: 600,
              px: 3,
              py: 1,
              boxShadow: 'none',
              mb: 2,
              backgroundColor: '#68B96A',
              '&:hover': {
                backgroundColor: '#5AA45C',
              }
            }}
          >
            Yakınımdaki Marketleri Gör
          </Button>
        </Container>
      </Box>
    
      {/* Category Cards Section */}
      <Container sx={{ mb: 5 }}>
        <Grid container spacing={1.5} justifyContent="center">
          <Grid item xs={6} sm={3}>
            <Card 
              sx={{ 
                height: '100%', 
                display: 'flex', 
                flexDirection: 'column', 
                alignItems: 'center', 
                justifyContent: 'center',
                py: 1.5,
                bgcolor: '#FFF8EA',
                border: 'none',
                boxShadow: 'none',
                borderRadius: 3,
              }}
            >
              <Box 
                sx={{ 
                  bgcolor: '#FDE9C1', 
                  borderRadius: '50%', 
                  p: 1, 
                  display: 'flex',
                  mb: 0.5,
                }}
              >
                <LocalOfferIcon sx={{ color: '#F8A93E', fontSize: '1.25rem' }} />
              </Box>
              <Typography variant="subtitle2" fontWeight={600} textAlign="center">
                İndirimli Ürünler
              </Typography>
            </Card>
          </Grid>
          
          <Grid item xs={6} sm={3}>
            <Card 
              sx={{ 
                height: '100%', 
                display: 'flex', 
                flexDirection: 'column', 
                alignItems: 'center', 
                justifyContent: 'center',
                py: 1.5,
                bgcolor: '#EEF6FB',
                border: 'none',
                boxShadow: 'none',
                borderRadius: 3,
              }}
            >
              <Box 
                sx={{ 
                  bgcolor: '#D5E8F7', 
                  borderRadius: '50%', 
                  p: 1, 
                  display: 'flex',
                  mb: 0.5,
                }}
              >
                <TrendingUpIcon sx={{ color: '#4A96DE', fontSize: '1.25rem' }} />
              </Box>
              <Typography variant="subtitle2" fontWeight={600} textAlign="center">
                Popüler Ürünler
              </Typography>
            </Card>
          </Grid>
          
          <Grid item xs={6} sm={3}>
            <Card 
              sx={{ 
                height: '100%', 
                display: 'flex', 
                flexDirection: 'column', 
                alignItems: 'center', 
                justifyContent: 'center',
                py: 1.5,
                bgcolor: '#F1F8F1',
                border: 'none',
                boxShadow: 'none',
                borderRadius: 3,
              }}
            >
              <Box 
                sx={{ 
                  bgcolor: '#DCF0DD', 
                  borderRadius: '50%', 
                  p: 1, 
                  display: 'flex',
                  mb: 0.5,
                }}
              >
                <ShoppingCartIcon sx={{ color: '#67B96A', fontSize: '1.25rem' }} />
              </Box>
              <Typography variant="subtitle2" fontWeight={600} textAlign="center">
                Alışveriş Listem
              </Typography>
            </Card>
          </Grid>
          
          <Grid item xs={6} sm={3}>
            <Card 
              sx={{ 
                height: '100%', 
                display: 'flex', 
                flexDirection: 'column', 
                alignItems: 'center', 
                justifyContent: 'center',
                py: 1.5,
                bgcolor: '#FEF1F0',
                border: 'none',
                boxShadow: 'none',
                borderRadius: 3,
              }}
            >
              <Box 
                sx={{ 
                  bgcolor: '#FADBD8', 
                  borderRadius: '50%', 
                  p: 1, 
                  display: 'flex',
                  mb: 0.5,
                }}
              >
                <FavoriteIcon sx={{ color: '#E74C3C', fontSize: '1.25rem' }} />
              </Box>
              <Typography variant="subtitle2" fontWeight={600} textAlign="center">
                Favoriler
              </Typography>
            </Card>
          </Grid>
        </Grid>
      </Container>
    </>
  );
}

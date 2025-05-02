'use client';
import * as React from 'react';
import { styled, alpha, useTheme } from '@mui/material/styles';
import Box from '@mui/material/Box';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import Container from '@mui/material/Container';
import MenuItem from '@mui/material/MenuItem';
import Drawer from '@mui/material/Drawer';
import MenuIcon from '@mui/icons-material/Menu';
import CloseRoundedIcon from '@mui/icons-material/CloseRounded';
import Popover from '@mui/material/Popover';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import Badge from '@mui/material/Badge';
import ShoppingBasketIcon from '@mui/icons-material/ShoppingBasket';
import Typography from '@mui/material/Typography';
import ColorModeIconDropdown from '../shared-theme/ColorModeIconDropdown';
import { useBasket } from '../context/BasketContext';
import FavoriteBorderIcon from '@mui/icons-material/FavoriteBorder';
import { useFavorites } from '../context/FavoritesContext';
import { useNavigate } from 'react-router-dom';
import { Tooltip } from '@mui/material';
import LocalGroceryStoreIcon from '@mui/icons-material/LocalGroceryStore';

const StyledToolbar = styled(Toolbar)(({ theme }) => ({
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'space-between',
  flexShrink: 0,
  borderRadius: 0,
  backdropFilter: 'none',
  border: 'none',
  borderBottom: '1px solid',
  borderColor: alpha(theme.palette.divider, 0.08),
  backgroundColor: 'white',
  boxShadow: 'none',
  padding: '0 8px',
  height: { xs: '48px', sm: '56px' },
  minHeight: { xs: '48px', sm: '56px' },
  [theme.breakpoints.up('sm')]: {
    minHeight: '56px',
    height: '56px',
  },
}));

export default function AppAppBar() {
  const [open, setOpen] = React.useState(false);
  const [anchorEl, setAnchorEl] = React.useState(null);
  const navigate = useNavigate();
  const { getBasketCount } = useBasket();
  const { favorites } = useFavorites();
  const theme = useTheme();

  const toggleDrawer = (newOpen) => () => {
    setOpen(newOpen);
  };

  const handlePopoverOpen = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handlePopoverClose = () => {
    setAnchorEl(null);
  };

  const isPopoverOpen = Boolean(anchorEl);
  const basketCount = getBasketCount();

  const handleFavoritesClick = () => {
    navigate('/favorites');
  };

  return (
    <AppBar
      position="fixed"
      enableColorOnDark
      sx={{
        boxShadow: '0 1px 2px rgba(0,0,0,0.05)',
        bgcolor: 'white',
        backgroundImage: 'none',
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        zIndex: 1200,
        height: { xs: '48px', sm: '56px' },
      }}
    >
      <Container maxWidth="lg">
        <StyledToolbar variant="dense" disableGutters>
          <Box sx={{ flexGrow: 1, display: 'flex', alignItems: 'center', px: 0 }}>
            <Typography
              variant="h5"
              component="a"
              href="/"
              sx={{
                mr: 2,
                fontWeight: 900,
                fontSize: '20px',
                color: 'primary.dark',
                textDecoration: 'none',
                letterSpacing: '-0.5px',
                display: 'flex', 
                alignItems: 'center',
                '&:hover': {
                  color: 'primary.main',
                  textDecoration: 'none',
                },
              }}
            >
              <LocalGroceryStoreIcon 
                sx={{ 
                  mr: 0.5, 
                  color: 'primary.main',
                  fontSize: '24px'
                }} 
              />
              PriceLess
            </Typography>
            <Box sx={{ display: { xs: 'none', md: 'flex' } }}>
              {/* Kategoriler Button with Popover */}
              <Button
                variant="text"
                color="primary"
                size="small"
                onClick={handlePopoverOpen}
                sx={{ 
                  fontWeight: 600,
                  color: 'primary.dark',
                  px: 1,
                  py: 0.5,
                  minWidth: 'auto',
                  '&:hover': { color: 'primary.main' }
                }}
              >
                Kategoriler
              </Button>
              <Popover
                open={isPopoverOpen}
                anchorEl={anchorEl}
                onClose={handlePopoverClose}
                anchorOrigin={{
                  vertical: 'bottom',
                  horizontal: 'left',
                }}
                transformOrigin={{
                  vertical: 'top',
                  horizontal: 'left',
                }}
                PaperProps={{
                  sx: {
                    padding: 1,
                    boxShadow: 3,
                    borderRadius: 1,
                  },
                }}
              >
                <List>
                  <ListItem button onClick={() => navigate('/category/meyve-sebze')}>
                    <ListItemText primary="Meyve ve Sebze" />
                  </ListItem>
                  <ListItem button onClick={() => navigate('/category/et-balik-tavuk')}>
                    <ListItemText primary="Et, Balık, Tavuk" />
                  </ListItem>
                  <ListItem button onClick={() => navigate('/category/sut-kahvaltilik')}>
                    <ListItemText primary="Süt Ürünleri" />
                  </ListItem>
                </List>
              </Popover>

              <Button 
                variant="text" 
                href="#indirimli-urunler" 
                color="primary" 
                size="small"
                sx={{ 
                  fontWeight: 600,
                  color: 'primary.dark',
                  px: 1,
                  py: 0.5,
                  minWidth: 'auto',
                  '&:hover': { color: 'primary.main' }
                }}
              >
                İndirimli Ürünler
              </Button>
              <Button 
                variant="text" 
                href="#popular-products" 
                color="primary" 
                size="small"
                sx={{ 
                  fontWeight: 600,
                  color: 'primary.dark',
                  px: 1,
                  py: 0.5,
                  minWidth: 'auto',
                  '&:hover': { color: 'primary.main' }
                }}
              >
                Popüler Ürünler
              </Button>
              <Button 
                variant="text" 
                href="#markets" 
                color="primary" 
                size="small"
                sx={{ 
                  fontWeight: 600,
                  color: 'primary.dark',
                  px: 1,
                  py: 0.5,
                  minWidth: 'auto',
                  '&:hover': { color: 'primary.main' }
                }}
              >
                Marketler
              </Button>
              <Button 
                variant="text" 
                href="#faq" 
                color="primary" 
                size="small" 
                sx={{ 
                  minWidth: 'auto',
                  px: 1,
                  py: 0.5,
                  fontWeight: 600,
                  color: 'primary.dark',
                  '&:hover': { color: 'primary.main' }
                }}
              >
                SSS
              </Button>
            </Box>
          </Box>
          <Box
            sx={{
              display: { xs: 'none', md: 'flex' },
              gap: 0.5,
              alignItems: 'center',
            }}
          >
            <Button
              color="primary"
              variant="text"
              size="small"
              onClick={() => navigate('/sign-in')}
              sx={{ fontWeight: 600, py: 0.5, px: 1 }}
            >
              Giriş
            </Button>
            <Button
              color="primary"
              variant="contained"
              size="small"
              onClick={() => navigate('/sign-up')}
              sx={{ py: 0.5, px: 1.5 }}
            >
              Kayıt Ol
            </Button>
            <Tooltip title="Favoriler">
              <IconButton 
                onClick={handleFavoritesClick}
                color="inherit"
                aria-label="favorites"
                sx={{ ml: 0.5, p: 0.5 }}
                size="small"
              >
                <Badge badgeContent={favorites?.length || 0} color="error">
                  <FavoriteBorderIcon fontSize="small" />
                </Badge>
              </IconButton>
            </Tooltip>
            <Button
              color="primary"
              variant="text"
              size="small"
              onClick={() => navigate('/my-basket')}
              sx={{ fontWeight: 600, px: 1, py: 0.5 }}
              startIcon={
                <Badge 
                  badgeContent={basketCount} 
                  color="error"
                  sx={{
                    '& .MuiBadge-badge': {
                      animation: basketCount > 0 ? 'pulse 1.5s infinite' : 'none',
                      '@keyframes pulse': {
                        '0%': { transform: 'scale(1)' },
                        '50%': { transform: 'scale(1.2)' },
                        '100%': { transform: 'scale(1)' },
                      },
                    },
                  }}
                >
                  <ShoppingBasketIcon fontSize="small" />
                </Badge>
              }
            >
                Sepetim
            </Button>
            <ColorModeIconDropdown />
          </Box>
          <Box sx={{ display: { xs: 'flex', md: 'none' }, gap: 0.5 }}>
            <Badge 
              badgeContent={basketCount} 
              color="error"
              sx={{ mr: 0.5 }}
              onClick={() => navigate('/my-basket')}
            >
              <IconButton color="inherit" size="small" sx={{ p: 0.5 }}>
                <ShoppingBasketIcon fontSize="small" />
              </IconButton>
            </Badge>
            <IconButton aria-label="Menu button" onClick={toggleDrawer(true)} size="small" sx={{ p: 0.5 }}>
              <MenuIcon fontSize="small" />
            </IconButton>
            <Drawer
              anchor="top"
              open={open}
              onClose={toggleDrawer(false)}
              PaperProps={{
                sx: {
                  top: 'var(--template-frame-height, 0px)',
                },
              }}
            >
              <Box sx={{ p: 2, backgroundColor: 'background.default' }}>
                <Box
                  sx={{
                    display: 'flex',
                    justifyContent: 'flex-end',
                  }}
                >
                  <IconButton onClick={toggleDrawer(false)}>
                    <CloseRoundedIcon />
                  </IconButton>
                </Box>

                <MenuItem>Kategoriler</MenuItem>
                <MenuItem>İndirimli Ürünler</MenuItem>
                <MenuItem>Popüler Ürünler</MenuItem>
                <MenuItem>Marketler</MenuItem>
                <MenuItem>Sıkça Sorulan Sorular</MenuItem>
                <MenuItem onClick={() => navigate('/my-basket')}>
                  Sepetim ({basketCount})
                </MenuItem>

                <Button
                  color="primary"
                  variant="contained"
                  fullWidth
                  onClick={() => navigate('/sign-up')}
                >
                  Kayıt Ol
                </Button>
                <Button
                  color="primary"
                  variant="outlined"
                  fullWidth
                  onClick={() => navigate('/sign-in')}
                >
                  Giriş Yap
                </Button>
              </Box>
            </Drawer>
          </Box>
        </StyledToolbar>
      </Container>
    </AppBar>
  );
}

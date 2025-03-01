'use client';
import * as React from 'react';
import { useNavigate } from 'react-router-dom';
import { styled, alpha } from '@mui/material/styles';
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
import Sitemark from './SitemarkIcon';
import ColorModeIconDropdown from '../shared-theme/ColorModeIconDropdown';

const StyledToolbar = styled(Toolbar)(({ theme }) => ({
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'space-between',
  flexShrink: 0,
  borderRadius: `calc(${theme.shape.borderRadius}px + 8px)`,
  backdropFilter: 'blur(24px)',
  border: '1px solid',
  borderColor: (theme.vars || theme).palette.divider,
  backgroundColor: theme.vars
    ? `rgba(${theme.vars.palette.background.defaultChannel} / 0.4)`
    : alpha(theme.palette.background.default, 0.4),
  boxShadow: (theme.vars || theme).shadows[1],
  padding: '8px 12px',
}));

export default function AppAppBar() {
  const [open, setOpen] = React.useState(false);
  const [anchorEl, setAnchorEl] = React.useState(null);
  const navigate = useNavigate(); // Hook for navigation

  // Function to toggle drawer
  const toggleDrawer = (newOpen) => () => {
    setOpen(newOpen);
  };

  // Open Popover for "Kategoriler"
  const handlePopoverOpen = (event) => {
    setAnchorEl(event.currentTarget);
  };

  // Close Popover
  const handlePopoverClose = () => {
    setAnchorEl(null);
  };

  const isPopoverOpen = Boolean(anchorEl);

  return (
    <AppBar
      position="fixed"
      enableColorOnDark
      sx={{
        boxShadow: 0,
        bgcolor: 'transparent',
        backgroundImage: 'none',
        mt: 'calc(var(--template-frame-height, 0px) + 28px)',
      }}
    >
      <Container maxWidth="lg">
        <StyledToolbar variant="dense" disableGutters>
          <Box sx={{ flexGrow: 1, display: 'flex', alignItems: 'center', px: 0 }}>
            <Sitemark />
            <Box sx={{ display: { xs: 'none', md: 'flex' } }}>
              {/* Kategoriler Button with Popover */}
              <Button
                variant="text"
                color="info"
                size="small"
                onClick={handlePopoverOpen}
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

              <Button variant="text" href="#indirimli-urunler" color="info" size="small">
                İndirimli Ürünler
              </Button>
              <Button variant="text" href="#popular-products" color="info" size="small">
                Popüler Ürünler
              </Button>
              <Button variant="text" href="#markets" color="info" size="small">
                Marketler
              </Button>
              <Button variant="text" href="#faq" color="info" size="small" sx={{ minWidth: 0 }}>
                Sıkça Sorulan Sorular
              </Button>
            </Box>
          </Box>
          <Box
            sx={{
              display: { xs: 'none', md: 'flex' },
              gap: 1,
              alignItems: 'center',
            }}
          >
            <Button
              color="primary"
              variant="text"
              size="small"
              onClick={() => navigate('/sign-in')}
            >
              Sign in
            </Button>
            <Button
              color="primary"
              variant="contained"
              size="small"
              onClick={() => navigate('/sign-up')}
            >
              Sign up
            </Button>
            <ColorModeIconDropdown />
          </Box>
          <Box sx={{ display: { xs: 'flex', md: 'none' }, gap: 1 }}>
            <ColorModeIconDropdown size="medium" />
            <IconButton aria-label="Menu button" onClick={toggleDrawer(true)}>
              <MenuIcon />
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

                <Button
                  color="primary"
                  variant="contained"
                  fullWidth
                  onClick={() => navigate('/sign-up')}
                >
                  Sign up
                </Button>
                <Button
                  color="primary"
                  variant="outlined"
                  fullWidth
                  onClick={() => navigate('../sign-in')}
                >
                  Sign in
                </Button>
              </Box>
            </Drawer>
          </Box>
        </StyledToolbar>
      </Container>
    </AppBar>
  );
}

import * as React from 'react';
import PropTypes from 'prop-types';
import { ThemeProvider, createTheme } from '@mui/material/styles';

import { inputsCustomizations } from './customizations/inputs';
import { dataDisplayCustomizations } from './customizations/dataDisplay';
import { feedbackCustomizations } from './customizations/feedback';
import { navigationCustomizations } from './customizations/navigation';
import { surfacesCustomizations } from './customizations/surfaces';
import { colorSchemes, typography, shadows, shape, brand } from './themePrimitives';

function AppTheme({ children, disableCustomTheme, themeComponents }) {
  const theme = React.useMemo(() => {
    return disableCustomTheme
      ? {}
      : createTheme({
          // For more details about CSS variables configuration, see https://mui.com/material-ui/customization/css-theme-variables/configuration/
          cssVariables: {
            colorSchemeSelector: 'data-mui-color-scheme',
            cssVarPrefix: 'template',
          },
          colorSchemes, // Recently added in v6 for building light & dark mode app, see https://mui.com/material-ui/customization/palette/#color-schemes
          typography,
          shadows,
          shape,
          components: {
            ...inputsCustomizations,
            ...dataDisplayCustomizations,
            ...feedbackCustomizations,
            ...navigationCustomizations,
            ...surfacesCustomizations,
            ...themeComponents,
            MuiAppBar: {
              styleOverrides: {
                root: {
                  boxShadow: 'none',
                },
              },
            },
            MuiButton: {
              styleOverrides: {
                root: {
                  textTransform: 'none',
                  fontWeight: 600,
                  borderRadius: 12,
                  padding: '12px 24px',
                  letterSpacing: 0.5,
                },
                contained: {
                  boxShadow: 'none',
                  backgroundColor: '#68B96A',
                  '&:hover': {
                    backgroundColor: '#5AA45C',
                    boxShadow: '0 4px 8px rgba(0, 0, 0, 0.1)',
                  },
                },
                outlined: {
                  borderWidth: '1.5px',
                  borderColor: '#68B96A',
                  color: '#5AA45C',
                  '&:hover': {
                    borderWidth: '1.5px',
                    borderColor: '#5AA45C',
                    backgroundColor: 'rgba(104, 185, 106, 0.08)',
                  },
                },
                textInfo: {
                  color: '#5AA45C',
                  fontWeight: 600,
                  '&:hover': {
                    backgroundColor: 'transparent',
                    color: '#68B96A',
                  },
                },
                textPrimary: {
                  color: '#5AA45C',
                  '&:hover': {
                    backgroundColor: 'rgba(104, 185, 106, 0.08)',
                  },
                },
              },
            },
            MuiCard: {
              styleOverrides: {
                root: {
                  borderRadius: 12,
                  boxShadow: '0 4px 16px rgba(0, 0, 0, 0.08)',
                  overflow: 'hidden',
                },
              },
            },
            MuiTextField: {
              styleOverrides: {
                root: {
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 12,
                    '&.Mui-focused fieldset': {
                      borderColor: '#68B96A',
                    },
                  },
                },
              },
            },
            MuiChip: {
              styleOverrides: {
                root: {
                  borderRadius: 8,
                  fontWeight: 500,
                },
                colorPrimary: {
                  backgroundColor: '#68B96A',
                  color: 'white',
                },
              },
            },
            MuiBadge: {
              styleOverrides: {
                colorError: {
                  backgroundColor: '#FF5B3D',
                },
              },
            },
          },
        });
  }, [disableCustomTheme, themeComponents]);
  if (disableCustomTheme) {
    return <React.Fragment>{children}</React.Fragment>;
  }
  return (
    <ThemeProvider theme={theme} disableTransitionOnChange>
      {children}
    </ThemeProvider>
  );
}

AppTheme.propTypes = {
  children: PropTypes.node,
  /**
   * This is for the docs site. You can ignore it or remove it.
   */
  disableCustomTheme: PropTypes.bool,
  themeComponents: PropTypes.object,
};

export default AppTheme;

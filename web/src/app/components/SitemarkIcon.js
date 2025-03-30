import * as React from 'react';
import SvgIcon from '@mui/material/SvgIcon';
import { useTheme } from '@mui/material/styles';

export default function SitemarkIcon() {
  const theme = useTheme();
  const brandColor = theme.palette.primary.dark;

  return (
    <SvgIcon sx={{ height: 28, width: 130, mr: 2 }}>
      <svg
        width={130}
        height={28}
        viewBox="0 0 130 28"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <text
          x="0"
          y="20"
          fontSize="20"
          fontWeight="900"
          fill={brandColor}
          fontFamily="Arial, sans-serif"
        >
          PriceLess
        </text>
      </svg>
    </SvgIcon>
  );
}

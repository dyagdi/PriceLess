import * as React from 'react';
import SvgIcon from '@mui/material/SvgIcon';

export default function SitemarkIcon() {
  return (
    <SvgIcon sx={{ height: 21, width: 100, mr: 2 }}>
      <svg
        width={120}
        height={24}
        viewBox="0 0 120 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <text
          x="0"
          y="16"
          fontSize="16"
          fontWeight="bold"
          fill="#4876EE"
          fontFamily="Arial, sans-serif"
        >
          PriceLess
        </text>
      </svg>
    </SvgIcon>
  );
}

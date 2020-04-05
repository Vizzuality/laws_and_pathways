import React from 'react';
import Responsive, { useMediaQuery } from 'react-responsive';

export const breakpoints = {
  desktop: 1024
};

export const MobileOnly = props => (
  <Responsive {...props} maxWidth={breakpoints.desktop - 1} />
);
export const DesktopUp = props => (
  <Responsive {...props} minWidth={breakpoints.desktop} />
);

export const useDeviceInfo = () => {
  const isMobile = useMediaQuery({ maxWidth: breakpoints.desktop - 1 });
  const isDesktop = useMediaQuery({ minWidth: breakpoints.desktop });
  // add more if you need

  return {
    isMobile,
    isDesktop
  };
};

export const withDeviceInfo = Component => props => {
  const deviceInfo = useDeviceInfo();

  return (
    <Component {...props} deviceInfo={deviceInfo} />
  );
};

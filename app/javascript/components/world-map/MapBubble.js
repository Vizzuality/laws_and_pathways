import React from 'react';
import { Marker } from 'react-simple-maps';

function MapBubble(props) {
  const { weight, color, opacity, ...markerProps } = props;
  return (
    <Marker {...markerProps} onMouseDown={() => {}}>
      <circle
        r={weight}
        fill={color}
        fillOpacity={opacity}
        className="world-map__map-bubble"
      />
    </Marker>
  );
}

export default MapBubble;

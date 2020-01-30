import React from 'react';
import { Marker } from 'react-simple-maps';

function MapBubble(props) {
  const { weight, color, onMouseDown, currentZoom, clicked, iso, ...markerProps } = props;

  const newScale = 1 / currentZoom;

  return (
    <Marker {...markerProps} onMouseDown={onMouseDown}>
      <circle
        r={weight}
        fill={color}
        strokeWidth={clicked ? '2' : '0.5'}
        stroke="#2E3152"
        className="world-map__map-bubble"
        transform={`scale(${newScale})`}
      />
    </Marker>
  );
}

export default MapBubble;

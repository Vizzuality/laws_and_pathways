import React from 'react';
import PropTypes from 'prop-types';
import { Marker } from 'react-simple-maps';

function MapBubble({ weight, color, onMouseDown, currentZoom, clicked, ...markerProps }) {
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

MapBubble.propTypes = {
  weight: PropTypes.number.isRequired,
  color: PropTypes.string.isRequired,
  currentZoom: PropTypes.number.isRequired,
  clicked: PropTypes.bool.isRequired,
  onMouseDown: PropTypes.func.isRequired
};

export default MapBubble;

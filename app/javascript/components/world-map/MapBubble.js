import React, { useState, useRef, useEffect } from 'react';
import { Marker } from 'react-simple-maps';

function MapBubble(props) {
  const { weight, color, onMouseDown, currentZoom, ...markerProps } = props;
  const [clicked, setClicked] = useState(false);

  const bubble = useRef(null);

  const handleClickOutside = (event) => {
    if (bubble.current && !bubble.current.contains(event.target)) {
      setClicked(false);
    }
  };

  const handleMouseDown = () => {
    setClicked(!clicked);
    onMouseDown();
  };

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const newScale = 1 / currentZoom;

  return (
    <Marker {...markerProps} onMouseDown={handleMouseDown}>
      <circle
        ref={bubble}
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

import React, { useState, useRef, useEffect } from 'react';
import { Marker } from 'react-simple-maps';

function MapBubble(props) {
  const { weight, color, opacity, ...markerProps } = props;
  const [clicked, setClicked] = useState(false);

  const bubble = useRef(null);

  const handleClickOutside = (event) => {
    if (bubble.current && !bubble.current.contains(event.target)) {
      setClicked(false);
    }
  };

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  return (
    <Marker {...markerProps} onMouseDown={() => setClicked(!clicked)}>
      <circle
        ref={bubble}
        r={weight}
        fill={color}
        fillOpacity={opacity}
        strokeWidth={clicked ? '2' : '0'}
        stroke="#2E3152"
        className="world-map__map-bubble"
      />
    </Marker>
  );
}

export default MapBubble;

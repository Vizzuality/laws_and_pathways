import React, { useReducer, useState } from 'react';
import PropTypes from 'prop-types';
import ReactTooltip from 'react-tooltip';
import {
  ComposableMap,
  ZoomableGroup,
  Geography,
  Geographies
} from 'react-simple-maps';
import Select from 'react-select';
import { geoCylindricalEqualArea } from 'd3-geo-projection';
import reducer, { initialState } from './world-map.reducer';
import { useMarkers } from './world-map.hooks';
import MapBubble from './MapBubble';
import MinusIcon from 'images/cclow/icons/minus.svg';
import PlusIcon from 'images/cclow/icons/plus.svg';

const geoUrl = 'https://raw.githubusercontent.com/zcreativelabs/react-simple-maps/master/topojson-maps/world-110m.json';
const PetersGall = geoCylindricalEqualArea().parallel(45);

function WorldMap(props) {
  const { layers } = props;

  const getTooltip = (tooltipContent) => {
    const { country, climateLawsPolicies, emissions, link } = tooltipContent;
    return (
      <div className="world-map__tooltip-container">
        <p className="world-map__tooltip-title">{country}</p>
        <div className="world-map__tooltip-row">
          <p className="world-map__tooltip-text">Number of climate laws and policies</p>
          <p className="world-map__tooltip-number">{climateLawsPolicies}</p>
        </div>
        <div className="world-map__tooltip-row">
          <p className="world-map__tooltip-text">Greenhouse gas emissions (% of global emissions)</p>
          <p className="world-map__tooltip-number">{emissions}</p>
        </div>
        <a href="https://todo-link-to-that-country" className="world-map__tooltip-link">{link}</a>
      </div>
    );
  };

  const [content, setTooltipContent] = useState('');

  const [state, dispatch] = useReducer(reducer, initialState);
  const markers = useMarkers(layers, state.activeLayerId);
  const zoomIn = () => dispatch({ type: 'zoomIn' });
  const zoomOut = () => dispatch({ type: 'zoomOut' });
  const setActiveLayerId = selectedOption => dispatch({ type: 'setActiveLayerId', payload: selectedOption.value });
  const onZoomEnd = (e, position) => dispatch({ type: 'zoomEnd', payload: position });
  const layerOptions = layers.map(l => ({ value: l.id, label: l.name }));
  const selectedOption = layerOptions.find(l => l.value === state.activeLayerId);

  return (
    <div className="world-map__container">
      <div className="world-map__controls">
        <button type="button" onClick={zoomIn} className="button world-map__controls-zoom-in">
          <img src={PlusIcon} alt="zoom-in" />
        </button>
        <button type="button" onClick={zoomOut} className="button world-map__controls-zoom-out">
          <img src={MinusIcon} alt="zoom-out" />
        </button>
      </div>
      <div className="world-map__selectors">
        <div className="world-map__selector">
          <label>Content</label>
          <Select
            options={layerOptions}
            value={selectedOption}
            onChange={setActiveLayerId}
            isSearchable={false}
            width="300px"
          />
        </div>
      </div>
      <ComposableMap
        projection={PetersGall}
        style={{ width: '100%', height: 642 }}
      >
        <ZoomableGroup
          zoom={state.zoom}
          onZoomEnd={onZoomEnd}
          className="world-map__zoomable-group"
        >
          <Geographies geography={geoUrl} className="world-map__geographies">
            {({ geographies }) => geographies.map(geo => (
              <Geography
                key={geo.rsmKey}
                geography={geo}
                className="world-map__geography"
              />
            ))
            }
          </Geographies>
          {markers.map(marker => (
            <MapBubble
              {...marker}
              key={marker.iso}
              data-tip=""
              data-event="click"
              onMouseEnter={() => {
                setTooltipContent({
                  country: 'Country',
                  climateLawsPolicies: 'todo',
                  emissions: 'todo',
                  link: 'TODO link'
                });
              }}
            />
          ))}
        </ZoomableGroup>
      </ComposableMap>
      <ReactTooltip globalEventOff="click" clickable class="world-map__tooltip">
        {content ? getTooltip(content) : ''}
      </ReactTooltip>
    </div>
  );
}

const mockLayers = [
  {
    id: 1,
    name: 'The greatest fake layer ever',
    ramp: 'risk',
    features: [
      { iso: 'BR', contentValue: 69, contextValue: 52818 },
      { iso: 'CI', contentValue: 873, contextValue: 98157 },
      { iso: 'IN', contentValue: 5633, contextValue: 69818 },
      { iso: 'CL', contentValue: 2337, contextValue: 38161 },
      { iso: 'CM', contentValue: 243333, contextValue: 19297 },
      { iso: 'CN', contentValue: 1133, contextValue: 59331 },
      { iso: 'US', contentValue: 7550, contextValue: 95673 },
      { iso: 'CR', contentValue: 52877, contextValue: 18661 },
      { iso: 'CH', contentValue: 6166, contextValue: 44869 },
      { iso: 'CV', contentValue: 4455, contextValue: 27867 },
      { iso: 'CW', contentValue: 743665, contextValue: 85575 },
      { iso: 'CY', contentValue: 2755, contextValue: 54487 },
      { iso: 'FR', contentValue: 3545, contextValue: 83737 },
      { iso: 'MX', contentValue: 67455, contextValue: 98802 },
      { iso: 'LC', contentValue: 64441, contextValue: 89025 },
      { iso: 'MC', contentValue: 855, contextValue: 91249 },
      { iso: 'RU', contentValue: 3744521, contextValue: 28038 },
      { iso: 'SC', contentValue: 80116, contextValue: 18634 },
      { iso: 'TC', contentValue: 383920, contextValue: 34675 },
      { iso: 'VC', contentValue: 172344, contextValue: 22113 }
    ]
  },
  {
    id: 2,
    name: 'The lamest fake layer ever',
    ramp: 'emissions',
    features: [
      { iso: 'BR', contextValue: 69, contentValue: 541 },
      { iso: 'CI', contextValue: 887773, contentValue: 9052818 },
      { iso: 'IN', contextValue: 5633, contentValue: 82307 },
      { iso: 'CL', contextValue: 233777, contentValue: 2774996 },
      { iso: 'CM', contextValue: 23333, contentValue: 223995 },
      { iso: 'CN', contextValue: 119553, contentValue: 14498 },
      { iso: 'US', contextValue: 757150, contentValue: 2895256 },
      { iso: 'CR', contextValue: 52877, contentValue: 29605 },
      { iso: 'CH', contextValue: 614466, contentValue: 8579 },
      { iso: 'CV', contextValue: 445577, contentValue: 3813488 },
      { iso: 'CW', contextValue: 73665, contentValue: 3044599 },
      { iso: 'CY', contextValue: 275547, contentValue: 5854943 },
      { iso: 'FR', contextValue: 3545, contentValue: 73870 },
      { iso: 'MX', contextValue: 674553, contentValue: 5203 },
      { iso: 'LC', contextValue: 644471, contentValue: 2148868 },
      { iso: 'MC', contextValue: 85, contentValue: 2882723 },
      { iso: 'RU', contextValue: 374451, contentValue: 1745012 },
      { iso: 'SC', contextValue: 80116, contentValue: 3620632 },
      { iso: 'TC', contextValue: 3920, contentValue: 1223 },
      { iso: 'VC', contextValue: 172344, contentValue: 12121 }
    ]
  }
];

WorldMap.defaultProps = {
  layers: mockLayers
};

WorldMap.propTypes = {
  layers: PropTypes.array
};

export default WorldMap;

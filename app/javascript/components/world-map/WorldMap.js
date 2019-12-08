import React, { useReducer, useEffect, useState } from 'react';
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

function combineLayers(selectedContext, selectedContent) {
  if (!selectedContext || !selectedContent) return null;

  const features = selectedContext.values.map(cx => {
    const contentValue = selectedContent.values.find(cxv => cxv.geography_iso === cx.geography_iso);

    if (!contentValue) return null;

    return {
      iso: cx.geography_iso,
      contentValue: contentValue.value,
      contextValue: cx.value
    };
  }).filter(x => x);

  return {
    ramp: 'emissions',
    features
  };
}

function WorldMap() {
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

  const [tooltipContent, setTooltipContent] = useState('');

  const [state, dispatch] = useReducer(reducer, initialState);
  const { data } = state;

  const zoomIn = () => dispatch({ type: 'zoomIn' });
  const zoomOut = () => dispatch({ type: 'zoomOut' });
  const onZoomEnd = (e, position) => dispatch({ type: 'zoomEnd', payload: position });

  const setData = (d) => dispatch({ type: 'setData', payload: d });

  const context = (data || {}).context || [];
  const content = (data || {}).content || [];

  // react-select
  const setContentId = selectedOption => dispatch({ type: 'setContentId', payload: selectedOption.value });
  const setContextId = selectedOption => dispatch({ type: 'setContextId', payload: selectedOption.value });

  const contextOptions = context.map(c => ({ value: c.id, label: c.name }));
  const contentOptions = content.map(c => ({ value: c.id, label: c.name }));

  const selectedContextOption = contextOptions.find(o => o.value === state.selectedContextId);
  const selectedContentOption = contentOptions.find(o => o.value === state.selectedContentId);

  const markers = useMarkers(
    combineLayers(
      context.find(c => c.id === state.selectedContextId),
      content.find(c => c.id === state.selectedContentId)
    )
  );

  useEffect(() => {
    fetch('/cclow/api/map_indicators')
      .then((response) => response.json())
      .then((json) => {
        setData(json);
      });
  }, []);

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
            options={contentOptions}
            value={selectedContentOption}
            onChange={setContentId}
            isSearchable={false}
            width="300px"
          />
        </div>
        <div className="world-map__selector">
          <label>Context</label>
          <Select
            options={contextOptions}
            value={selectedContextOption}
            onChange={setContextId}
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
            ))}
          </Geographies>
          {(markers || []).map(marker => (

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
        {tooltipContent ? getTooltip(tooltipContent) : ''}
      </ReactTooltip>
    </div>
  );
}

export default WorldMap;

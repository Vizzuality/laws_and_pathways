import React, { useReducer, useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import ReactTooltip from 'react-tooltip';
import cx from 'classnames';
import {
  ComposableMap,
  ZoomableGroup,
  Geography,
  Geographies
} from 'react-simple-maps';
import Select from 'react-select';
import { geoPath } from 'd3-geo';
import { geoCylindricalEqualArea } from 'd3-geo-projection';
import { feature } from 'topojson-client';
import reducer, { initialState } from './world-map.reducer';
import { useMarkers, useScale, useCombinedLayer } from './world-map.hooks';

import MapBubble from './MapBubble';
import MapLegend from './MapLegend';
import MapTooltip from './MapTooltip';

import MinusIcon from 'images/cclow/icons/minus.svg';
import PlusIcon from 'images/cclow/icons/plus.svg';

const geoUrl = 'https://raw.githubusercontent.com/zcreativelabs/react-simple-maps/master/topojson-maps/world-110m.json';
const PetersGall = geoCylindricalEqualArea().parallel(45);

function WorldMap({ zoomToGeographyIso }) {
  const [state, dispatch] = useReducer(reducer, initialState);
  const {
    data,
    center,
    geos,
    selectedContentId,
    selectedContextId,
    tooltipGeography,
    zoom
  } = state;

  const mapContainer = useRef(null);

  const zoomIn = () => dispatch({ type: 'zoomIn' });
  const zoomOut = () => dispatch({ type: 'zoomOut' });
  const onZoomEnd = (e, position) => dispatch({ type: 'zoomEnd', payload: position });

  const setData = (d) => dispatch({ type: 'setData', payload: d });
  const setGeos = (newGeos) => dispatch({ type: 'setGeos', payload: newGeos });

  const context = (data || {}).context || [];
  const content = (data || {}).content || [];
  const geographiesDB = (data || {}).geographies || [];

  const setCenter = newCenter => dispatch({ type: 'setCenter', payload: newCenter });

  // tooltip
  const setTooltipGeography = iso => dispatch({ type: 'setTooltipGeography', payload: geographiesDB.find(g => g.iso === iso) });

  // react-select
  const setContentId = selectedOption => dispatch({ type: 'setContentId', payload: selectedOption.value });
  const setContextId = selectedOption => dispatch({ type: 'setContextId', payload: selectedOption.value });

  const contextOptions = context.map(c => ({ value: c.id, label: c.name }));
  const contentOptions = content.map(c => ({ value: c.id, label: c.name }));

  const selectedContextOption = contextOptions.find(o => o.value === selectedContextId);
  const selectedContentOption = contentOptions.find(o => o.value === selectedContentId);

  const selectedContent = content.find(c => c.id === selectedContentId);
  const selectedContext = context.find(c => c.id === selectedContextId);

  const activeLayer = useCombinedLayer(
    selectedContext,
    selectedContent
  );
  const scales = useScale(activeLayer);
  const markers = useMarkers(activeLayer, scales);

  useEffect(() => {
    fetch('/cclow/api/map_indicators')
      .then((response) => response.json())
      .then((json) => {
        setData(json);
      });
  }, []);

  useEffect(() => {
    fetch(geoUrl)
      .then((response) => response.json())
      .then((json) => {
        setGeos(json);

        if (zoomToGeographyIso) {
          const feats = feature(
            json,
            json.objects[Object.keys(json.objects)[0]]
          ).features;

          const geoFeature = feats.find(g => g.properties.ISO_A3 === zoomToGeographyIso);
          if (geoFeature) zoomToGeography(geoFeature);
        }
      });
  }, []);

  const zoomToGeography = (geo) => {
    const path = geoPath().projection(PetersGall);
    const newCenter = PetersGall.invert(path.centroid(geo));

    // calculate zoom level
    const bounds = path.bounds(geo);
    const dx = bounds[1][0] - bounds[0][0];
    const dy = bounds[1][1] - bounds[0][1];
    const newZoom = 0.9 / Math.max(dx / mapContainer.current.clientWidth, dy / 642);

    setCenter(newCenter);
    onZoomEnd(null, { zoom: newZoom });
  };

  return (
    <React.Fragment>
      <div ref={mapContainer} className="world-map__container">
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
            zoom={zoom}
            center={center}
            onZoomEnd={onZoomEnd}
            className="world-map__zoomable-group"
          >
            <Geographies geography={geos} className="world-map__geographies">
              {({ geographies }) => geographies.map(geo => (
                <Geography
                  key={geo.rsmKey}
                  geography={geo}
                  className={cx(
                    'world-map__geography', { 'world-map__geography--active': geo.properties.ISO_A3 === zoomToGeographyIso }
                  )}
                />
              ))}
            </Geographies>
            {(markers || []).map(marker => (
              <MapBubble
                {...marker}
                key={marker.iso}
                data-tip=""
                data-event="click"
                currentZoom={zoom}
                onMouseDown={() => {
                  setTooltipGeography(marker.iso);
                }}
              />
            ))}
          </ZoomableGroup>
        </ComposableMap>

        {tooltipGeography && (
          <ReactTooltip globalEventOff="click" clickable class="world-map__tooltip">
            <MapTooltip
              content={selectedContent}
              context={selectedContext}
              geography={tooltipGeography}
            />
          </ReactTooltip>
        )}
      </div>
      {scales && (
        <MapLegend content={selectedContent} context={selectedContext} scales={scales} />
      )}
    </React.Fragment>
  );
}

WorldMap.defaultProps = {
  zoomToGeographyIso: ''
};

WorldMap.propTypes = {
  zoomToGeographyIso: PropTypes.string
};

export default WorldMap;

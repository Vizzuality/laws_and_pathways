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
import Select, { components } from 'react-select';
import { geoPath, geoEqualEarth } from 'd3-geo';
import orderBy from 'lodash/orderBy';
import { feature } from 'topojson-client';
import reducer, { initialState } from './world-map.reducer';
import { useMarkers, useScale, useCombinedLayer } from './world-map.hooks';
import chevronIconBlack from '../../../assets/images/icon_chevron_dark/chevron_down_black-1.svg';

import MapBubble from './MapBubble';
import MapLegend from './MapLegend';
import MapTooltip from './MapTooltip';

import MinusIcon from 'images/cclow/icons/minus.svg';
import PlusIcon from 'images/cclow/icons/plus.svg';

const geoUrl = 'https://raw.githubusercontent.com/zcreativelabs/react-simple-maps/master/topojson-maps/world-110m.json';
const projection = geoEqualEarth();

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
  const customStyles = {
    control: (provided) => ({
      ...provided,
      border: '1px solid',
      boxShadow: '1px solid #2E3152',
      borderRadius: 0
    }),
    indicatorSeparator: () => ({
      display: 'none'
    }),
    menu: (provided) => ({
      ...provided,
      margin: 0,
      borderRadius: 0
    })
  };

  const selectThemeColor = '#2E3152';

  const customTheme = theme => ({
    ...theme,
    borderRadius: 0,
    colors: {
      ...theme.colors,
      primary: selectThemeColor,
      primary25: 'white',
      primary50: 'white',
      primary75: selectThemeColor
    }
  });

  const DropdownIndicator = (props) => (
    <components.DropdownIndicator {...props}>
      <img src={chevronIconBlack} />
    </components.DropdownIndicator>
  );

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
  const markers = orderBy(useMarkers(activeLayer, scales), 'weight');

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
    const path = geoPath().projection(projection);
    const newCenter = projection.invert(path.centroid(geo));

    // calculate zoom level
    const bounds = path.bounds(geo);
    const dx = bounds[1][0] - bounds[0][0];
    const dy = bounds[1][1] - bounds[0][1];
    const newZoom = 0.9 / Math.max(dx / mapContainer.current.clientWidth, dy / 642);

    setCenter(newCenter);
    onZoomEnd(null, { zoom: newZoom });
  };

  const mapAndSortActiveGeography = (geographies) => {
    if (!zoomToGeographyIso) return geographies;

    return geographies
      .map(geo => ({
        active: geo.properties.ISO_A3 === zoomToGeographyIso,
        ...geo
      })).sort((a, b) => a.active - b.active);
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
              styles={customStyles}
              components={{ DropdownIndicator }}
              theme={customTheme}
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
              styles={customStyles}
              components={{ DropdownIndicator }}
              theme={customTheme}
              width="300px"
            />
          </div>
        </div>
        <ComposableMap
          projection={projection}
          className="world-map__composable-map"
        >
          <ZoomableGroup
            zoom={zoom}
            center={center}
            onZoomEnd={onZoomEnd}
            className="world-map__zoomable-group"
          >
            <Geographies geography={geos} className="world-map__geographies">
              {({ geographies }) => mapAndSortActiveGeography(geographies).map(geo => (
                <Geography
                  key={geo.rsmKey}
                  geography={geo}
                  className={cx(
                    'world-map__geography', { 'world-map__geography--active': geo.active }
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

/* eslint-disable react/no-danger */

import React from 'react';
import PropTypes from 'prop-types';

import { COLOR_RAMPS, BUBBLE_LEGEND_RADIUSES } from './constants';
import { formatNumber } from './helpers';

function MapLegend({ content, context, scales }) {
  if (!content) return null;
  if (!context) return null;

  const colors = COLOR_RAMPS[context.ramp];
  const displayContextValue = (color, index) => {
    const value = Math.round(scales.colorScale.invertExtent(color)[index]);

    if (context.id === 'cumulative_direct_economic_loss_disaters_absolute') {
      return new Intl.NumberFormat(
        'en-US', { style: 'currency', currency: 'USD', notation: 'compact', compactDisplay: 'short' }
      ).format(value);
    }

    return formatNumber(value);
  };
  const renderDataSource = (creator) => (
    <a href={creator.url} className="link" target="_blank" rel="noopener noreferrer">{creator.name}</a>
  );

  return (
    <div className="world-map__legend">
      <div className="columns">
        <div className="column is-half world-map__legend-scale">
          <div className="name">{content.name}</div>
          <div className="world-map__legend-scale-buckets world-map__legend-scale-buckets--content">
            {BUBBLE_LEGEND_RADIUSES.map((radius) => (
              <div>
                <div className="circle" style={{width: radius * 2, height: radius * 2}} />
                {Math.round(scales.sizeScale.invert(radius))}
              </div>
            ))}
          </div>
          <div>
            <span dangerouslySetInnerHTML={{__html: content.legend_description}} />
            {renderDataSource(content.creator)}
          </div>
        </div>
        <div className="column is-half world-map__legend-scale">
          <div className="name">{context.name}</div>
          <div className="world-map__legend-scale-buckets world-map__legend-scale-buckets--context">
            {colors.map((color, i) => (
              <div>
                <div className="rectangle" style={{backgroundColor: color}} />&nbsp;

              {(i === 0) && `<${displayContextValue(color, 1)}`}
              {(i === colors.length - 1) && `>${displayContextValue(color, 0)}`}
              </div>
            ))}
          </div>
          <div>
            <span dangerouslySetInnerHTML={{__html: context.legend_description}} />
            {renderDataSource(context.creator)}
          </div>
        </div>
      </div>
    </div>
  );
}

MapLegend.propTypes = {
  scales: PropTypes.any.isRequired,
  content: PropTypes.object.isRequired,
  context: PropTypes.object.isRequired
};

export default MapLegend;

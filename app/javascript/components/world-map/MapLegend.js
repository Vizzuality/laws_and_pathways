import React from 'react';
import PropTypes from 'prop-types';

import { COLOR_RAMPS } from './world-map.hooks';

function MapLegend({ scales }) {
  const colors = COLOR_RAMPS.emissions;

  return (
    <div className="world-map__legend">
      <div className="columns">
        <div className="column is-half">
          <div className="name">Number of renewable energy laws and policies</div>
          <div className="img-describe">
            <div><div className="circle" />1</div>
          </div>
          <div>
            The <b>size</b> of the circle represents the data from selected Context.
          </div>
        </div>
        <div className="column is-half">
          <div className="name">Renewable energy consumption (% of total final energy consumption)</div>
          <div className="img-describe">
            {colors.map((color) => (
              <div>
                <div className="rectangle" style={{backgroundColor: color}} />
                &nbsp;
                {colors[0] === color && `<${Math.round(scales.colorScale.invertExtent(color)[1])}`}
                {colors.slice(-1)[0] === color && `>${Math.round(scales.colorScale.invertExtent(color)[0])}`}
              </div>
            ))}
          </div>
          <div>
            The <b>colour</b> of the circle represents a country’s renewable energy consumption. The darker the circle, the higher the percentage of renewable energy consumption.
          </div>
        </div>
      </div>
    </div>
  );
}

MapLegend.propTypes = {
  scales: PropTypes.any.isRequired
};

export default MapLegend;

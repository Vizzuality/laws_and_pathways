import React from 'react';
import { scaleLinear } from 'd3-scale';
import PropTypes from 'prop-types';

import hoverIcon from 'images/icons/hover-cursor.svg';
import Bar from './Bar';

function MqSectorBar({ data, sector }) {
  const maxValue = Math.max(
    ...Object.values(data).map((companies) => companies.length)
  );
  const heightScale = scaleLinear().range([50, 370]).domain([0, maxValue]);

  return (
    <div>
      <div className="mq-sector-pie-chart-title">
        <img src={hoverIcon} alt="Hover icon" />
        <p>
          <span>
            Click on the bars to see the detailed list of companies for each
            level.
          </span>
        </p>
      </div>
      <div className="sector-level-overview is-hidden-touch columns">
        {Object.entries(data).map(([level, companies]) => (
          <Bar key={level} level={level} companies={companies} height={heightScale(companies.length)} sector={sector} />
        ))}
      </div>
    </div>
  );
}

MqSectorBar.propTypes = {
  data: PropTypes.array.isRequired,
  sector: PropTypes.string.isRequired
};

export default MqSectorBar;

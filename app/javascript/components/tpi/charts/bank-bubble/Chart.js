import React, {useEffect} from 'react';
import PropTypes from 'prop-types';
import uniq from 'lodash/uniq';
import legendImage from 'images/bubble-chart-legend.svg';
import SingleCell from './SingleCell';
import BaseTooltip from 'components/tpi/BaseTooltip';

const SCALE = 5;

// radius of bubbles
const COMPANIES_MARKET_CAP_GROUPS = {
  large: 17 * SCALE,
  medium: 9 * SCALE,
  small: 5 * SCALE
};

const SINGLE_CELL_SVG_WIDTH = 120 * SCALE;
const SINGLE_CELL_SVG_HEIGHT = 80 * SCALE;

const SCORE_RANGES = [{
  min: 0,
  max: 5,
  color: '#86A9F9'
}, {
  min: 5,
  max: 15,
  color: '#5587F7'
}, {
  min: 15,
  max: 25,
  color: '#2465F5'
}, {
  min: 25,
  max: 50,
  color: '#0A4BDC'
}, {
  min: 50,
  max: 75,
  color: '#083AAB'
}, {
  min: 75,
  max: 100,
  color: '#042b82'
}];

const tooltipDisclaimer = 'Define information box content';
let tooltip = null;

const BubbleChart = ({ results }) => {
  const tooltipEl = '<div id="bubble-chart-tooltip" class="bubble-tip bubble-tip--black" hidden style="position:absolute;"></div>';
  useEffect(() => {
    document.body.insertAdjacentHTML('beforeend', tooltipEl);
    tooltip = document.getElementById('bubble-chart-tooltip');
  }, []);
  const areas = uniq(results.map(r => r.area));
  const ranges = SCORE_RANGES.map((range) => `${range.min}-${range.max}%`);

  const parsedData = {};
  results.forEach((result) => {
    if (parsedData[result.area] === undefined) {
      parsedData[result.area] = Array.from({ length: ranges.length }, () => []);
    }
    const rangeIndex = SCORE_RANGES.findIndex((range) => result.percentage >= range.min && result.percentage <= range.max);
    if (rangeIndex >= 0) {
      parsedData[result.area][rangeIndex].push({
        ...result,
        color: SCORE_RANGES[rangeIndex].color
      });
    } else {
      console.error('WRONG INDEX', result);
    }
  });

  /** Parsed data has this format -
   * {
       area1: [[{}, {}, {}], [], [], [], [], []],
       area2: [[], [], [], [], [], []],
     ...
     }
   */

  return (
    <div
      className="bubble-chart__container bubble-chart__container--banks is-hidden-touch"
      style={{ gridTemplateColumns: `repeat(${areas.length + 1}, 1fr)` }}
    >
      <div className="bubble-chart__legend-container">
        <div className="bubble-chart__title-container">
          <span className="bubble-chart__title">Market cap</span>
          <BaseTooltip
            content={<span>{tooltipDisclaimer}</span>}
          />
        </div>
        <div className="bubble-chart__header">
          Score Range
        </div>
        <div className="bubble-chart__legend">
          <img className="bubble-chart__legend-image" src={legendImage} alt="Bubble size description" />
          <div className="bubble-chart__legend-titles-container">
            {Object.keys(COMPANIES_MARKET_CAP_GROUPS).map((companySize, i) => (
              <span
                key={`${companySize}-${i}`}
                className="bubble-chart__legend-title"
              >
                {companySize}
              </span>
            ))}
          </div>
        </div>
      </div>
      {ranges.map((range) => (
        <div className="bubble-chart__level" key={range}>
          <div className="bubble-chart__level-container">
            <div className="bubble-chart__level-title">
              {range}
            </div>
          </div>
        </div>
      ))}
      {Object.keys(parsedData).map((area, index) => createRow(parsedData[area], area, index + 1))}
    </div>
  );
};

const ForceLayoutBubbleChart = (companiesBubbles, uniqueKey) => {
  const handleBubbleClick = (company) => window.open(company.path, '_blank');

  return (
    <SingleCell
      width={SINGLE_CELL_SVG_WIDTH}
      height={SINGLE_CELL_SVG_HEIGHT}
      uniqueKey={uniqueKey}
      handleNodeClick={handleBubbleClick}
      showTooltip={showTooltip}
      hideTooltip={hideTooltip}
      data={companiesBubbles.length && companiesBubbles}
    />
  );
};

const getTooltipText = ({ tooltipContent }) => {
  if (tooltipContent) {
    return `
     <div class="bubble-tip-header">${tooltipContent.header}</div>
     <div class="bubble-tip-text">${parseFloat(Number(tooltipContent.percentage).toFixed(1))}%</div>
    `;
  }
  return '';
};

const showTooltip = (node, u) => {
  const bubble = u._groups[0][node.index];

  tooltip.innerHTML = getTooltipText(node);
  tooltip.removeAttribute('hidden');
  const bubbleBoundingRect = bubble.getBoundingClientRect();
  const topOffset = bubbleBoundingRect.top - tooltip.offsetHeight + window.pageYOffset;
  const leftOffset = bubbleBoundingRect.left + (bubbleBoundingRect.width - tooltip.offsetWidth) / 2 + window.pageXOffset;

  tooltip.style.left = `${leftOffset}px`;
  tooltip.style.top = `${topOffset}px`;
};

const hideTooltip = () => {
  tooltip.setAttribute('hidden', true);
};

const createRow = (dataRow, area, index) => (
  <React.Fragment key={Math.random()}>
    <div className="bubble-chart__row-link">
      {index}.&nbsp;{area}
    </div>
    {dataRow.map((el, i) => {
      const companiesBubbles = el.map(result => ({
        value: COMPANIES_MARKET_CAP_GROUPS[result.market_cap_group],
        tooltipContent: {
          header: result.bank_name,
          percentage: result.percentage
        },
        path: result.bank_path,
        color: result.color
      }));

      const uniqueKey = `${area}-${el.length}-${i}`;

      return (
        <div className="bubble-chart__cell" key={uniqueKey}>
          {ForceLayoutBubbleChart(companiesBubbles, uniqueKey)}
        </div>
      );
    })}
  </React.Fragment>
);

BubbleChart.propTypes = {
  results: PropTypes.arrayOf(PropTypes.shape({
    area: PropTypes.string.isRequired,
    market_cap_group: PropTypes.string.isRequired,
    percentage: PropTypes.number.isRequired,
    bank_id: PropTypes.string.isRequired,
    bank_name: PropTypes.string.isRequired,
    bank_path: PropTypes.string.isRequired
  })).isRequired
};
export default BubbleChart;

import React, {useEffect} from 'react';
import PropTypes from 'prop-types';
import legendImage from 'images/bubble-chart-legend.svg';
import SingleCell from './SingleCell';
import BaseTooltip from 'components/tpi/BaseTooltip';

const SCALE = 5;

// radius of bubbles
const COMPANIES_MARKET_CAP_GROUPS = {
  large: 10 * SCALE,
  medium: 5 * SCALE,
  small: 3 * SCALE
};

const SINGLE_CELL_SVG_WIDTH = 120 * SCALE;
const SINGLE_CELL_SVG_HEIGHT = 80 * SCALE;

const LEVELS_COLORS = [
  '#86A9F9',
  '#5587F7',
  '#2465F5',
  '#0A4BDC',
  '#083AAB',
  '#9747FF'
];

const LEVELS_SUBTITLES = {
  0: 'Unaware',
  1: 'Awareness',
  2: 'Building capacity',
  3: 'Integrating into operational decision making',
  4: 'Strategic assessment',
  5: 'Transition planning and implementation'
};

const tooltipDisclaimer = 'Companies have to answer “yes” to all questions on a level to move to the next one';
let tooltip = null;

const BubbleChart = ({ levels, sectors }) => {
  const tooltipEl = '<div id="bubble-chart-tooltip" class="bubble-tip" hidden style="position:absolute;"></div>';
  useEffect(() => {
    document.body.insertAdjacentHTML('beforeend', tooltipEl);
    tooltip = document.getElementById('bubble-chart-tooltip');
  }, []);
  const parsedData = Object.keys(levels).map(sectorName => ({
    sector: sectorName,
    data: Object.values(levels[sectorName])
  }));

  /** Parsed data has this format -
   * [
   *   { sector: 'Sector1', data: [ [ {}, {}, {} ], [], [], [], [], [] ] },
   *   { sector: 'Sector2', data: [ [], [], [], [], [], [] ] },
   *   { sector: 'Sector3', data: [ [], [], [], [], [], [] ] },
   *   { sector: 'Sector4', data: [ [], [], [], [], [], [] ] },
   *   { sector: 'Sector5', data: [ [], [], [], [], [], [] ] },
   *   { sector: 'Sector6', data: [ [], [], [], [], [], [] ] },
   *   { sector: 'Sector7', data: [ [], [], [], [], [], [] ] },
   *   { sector: 'Sector8', data: [ [], [], [], [], [], [] ] }
   * ]
   */

  const levelsSignature = levels && Object.keys(levels[Object.keys(levels)[0]]);

  return (
    <div
      className="bubble-chart__container bubble-chart__container--sectors is-hidden-touch"
      style={{ gridTemplateColumns: `repeat(${levelsSignature.length + 1}, 1fr)` }}
    >
      <div className="bubble-chart__legend-container">
        <div className="bubble-chart__title-container">
          <span className="bubble-chart__title">Market cap</span>
          <BaseTooltip
            content={<span>{tooltipDisclaimer}</span>}
          />
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
      {levelsSignature.map((el, i) => (
        <div className={`bubble-chart__level ${i === levelsSignature.length - 1 ? 'last' : ''}`} key={`${el}-${i}-${Math.random()}`}>
          <div className="bubble-chart__level-container">
            <div className="bubble-chart__level-title">{`Level ${el === '5' ? '5 [BETA]' : el}`}</div>
            <div className="bubble-chart__level-subtitle">{LEVELS_SUBTITLES[el]}</div>
          </div>
        </div>
      ))}
      {parsedData.map(dataRow => createRow(dataRow.data, dataRow.sector, sectors))}
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
     <div class="bubble-tip-text">${tooltipContent.value}</div>
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

const createRow = (dataRow, title, sectors) => {
  const sector = sectors.find(s => s.name === title);

  return (
    <React.Fragment key={Math.random()}>
      <div className="bubble-chart__row-link">
        <a href={sector.path}>{title}</a>
      </div>
      {dataRow.map((el, i) => {
        const companiesBubbles = el.map(company => ({
          value: COMPANIES_MARKET_CAP_GROUPS[company.market_cap_group],
          tooltipContent: {
            header: company.name,
            value: `Level ${company.level}`
          },
          path: company.path,
          color: LEVELS_COLORS[i]
        }));

        // Remove special characters from the key to be able to use d3-select as it uses querySelector
        const cleanKey = title.replace(/[^a-zA-Z0-9\-_:.]/g, '');
        const uniqueKey = `${cleanKey}-${el.length}-${i}`;

        return (
          <div className={`bubble-chart__cell ${i === dataRow.length - 1 ? 'last' : ''}`} key={uniqueKey}>
            {ForceLayoutBubbleChart(companiesBubbles, uniqueKey)}
          </div>
        );
      })}
    </React.Fragment>
  );
};

BubbleChart.propTypes = {
  levels: PropTypes.object.isRequired,
  sectors: PropTypes.array.isRequired
};
export default BubbleChart;

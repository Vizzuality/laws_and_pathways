import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import SingleCell from './SingleCell';

import { SCORE_RANGES } from './constants';

const SINGLE_CELL_SVG_WIDTH = 120;
const SINGLE_CELL_SVG_HEIGHT = 100;

let tooltip = null;

const BubbleChart = ({ results, disabled_bubbles_areas }) => {
  const tooltipEl = '<div id="bubble-chart-tooltip" class="bubble-tip" hidden style="position:absolute;"></div>';
  useEffect(() => {
    document.body.insertAdjacentHTML('beforeend', tooltipEl);
    tooltip = document.getElementById('bubble-chart-tooltip');
  }, []);
  const ranges = SCORE_RANGES.map((range) => range.value);

  const parsedData = {};
  const pillars = {};

  results.forEach((result) => {
    if (parsedData[result.area] === undefined) {
      parsedData[result.area] = Array.from({ length: ranges.length }, () => []);
    }
    const rangeIndex = SCORE_RANGES.findIndex(
      (range) => result.result === range.value
    );
    if (rangeIndex >= 0) {
      parsedData[result.area][rangeIndex].push({
        ...result,
        color: SCORE_RANGES[rangeIndex].color
      });
    } else {
      console.error('WRONG INDEX', result);
    }
    if (pillars[result.pillar] === undefined) {
      pillars[result.pillar] = [result.area];
    } else {
      pillars[result.pillar] = pillars[result.pillar].includes(result.area)
        ? pillars[result.pillar]
        : [...pillars[result.pillar], result.area];
    }
  });

  return (
    <div
      className="bubble-chart__container bubble-chart__container is-hidden-touch"
      style={{ gridTemplateColumns: '0.5fr 0.5fr 1.5fr 1fr 1fr 1fr' }}
    >
      <div className="bubble-chart__level-title-country">Pillar</div>
      <div className="bubble-chart__level-title-country">Area</div>
      <div />
      {ranges.map((range) => (
        <div className="bubble-chart__level-country" key={range}>
          <div className="bubble-chart__level-title-country">{range}</div>
        </div>
      ))}
      {Object.keys(parsedData).map((area) => createRow(parsedData[area], area, pillars, disabled_bubbles_areas))}
    </div>
  );
};

const ForceLayoutBubbleChart = (countriesBubbles, uniqueKey) => {
  const handleBubbleClick = (country) => window.open(country.path, '_blank');

  return (
    <SingleCell
      width={SINGLE_CELL_SVG_WIDTH}
      height={SINGLE_CELL_SVG_HEIGHT}
      uniqueKey={uniqueKey}
      handleNodeClick={handleBubbleClick}
      showTooltip={showTooltip}
      hideTooltip={hideTooltip}
      data={countriesBubbles.length && countriesBubbles}
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
  const topOffset = bubbleBoundingRect.top - tooltip.offsetHeight + window.scrollY;
  const leftOffset = bubbleBoundingRect.left
    + (bubbleBoundingRect.width - tooltip.offsetWidth) / 2
    + window.scrollX;

  tooltip.style.left = `${leftOffset}px`;
  tooltip.style.top = `${topOffset}px`;
};

const hideTooltip = () => {
  tooltip.setAttribute('hidden', true);
};

const createRow = (dataRow, area, pillars, disabled_bubbles_areas) => {
  const pillarEntries = Object.entries(pillars);

  const pillarIndex = pillarEntries.findIndex(([, value]) => value.includes(area));
  const pillar = pillarEntries[pillarIndex];

  const pillarSpan = pillar && pillar[1].length;
  const pillarName = pillar[0];
  const pillarAcronym = pillarName
    .split(' ')
    .map((word) => word[0])
    .join('');

  const areaIndex = pillar && pillar[1].findIndex((el) => el === area);

  return (
    <React.Fragment key={Math.random()}>
      <div
        className="bubble-chart__level-area-country"
        style={{
          gridRow: `span ${pillarSpan}`,
          display: areaIndex === 0 ? 'block' : 'none'
        }}
      >
        {pillarIndex + 1}.&nbsp;{pillarName}
      </div>
      {areaIndex === 0 && (
        <div
          style={{
            gridRow: `span ${pillarSpan}`,
            height: '100%',
            padding: '46px 0 46px'
          }}
        >
          <div
            style={{
              border: pillarSpan > 1 && '8px solid #E8E8E8',
              borderRight: 'none',
              height: '100%'
            }}
          />
        </div>
      )}
      <div className="bubble-chart__level-area-country">
        {pillarAcronym} {areaIndex + 1}. {area}
      </div>
      {dataRow.map((el, i) => {
        const countriesBubbles = disabled_bubbles_areas.includes(area)
          ? []
          : el.map((result) => ({
            value: 10,
            tooltipContent: {
              header: result.country_name,
              value: result.result
            },
            path: result.country_path,
            color: result.color,
            result: result.result
          }));

        // Remove special characters from the key to be able to use d3-select as it uses querySelector
        const cleanKey = area.replace(/[^a-zA-Z\-_:.]/g, '');
        const uniqueKey = `${cleanKey}-${el.length}-${i}`;

        return (
          <div className="bubble-chart__cell-country" key={uniqueKey}>
            {ForceLayoutBubbleChart(countriesBubbles, uniqueKey)}
          </div>
        );
      })}
    </React.Fragment>
  );
};
BubbleChart.defaultProps = {
  disabled_bubbles_areas: []
};

BubbleChart.propTypes = {
  results: PropTypes.arrayOf(
    PropTypes.shape({
      area: PropTypes.string.isRequired,
      market_cap_group: PropTypes.string.isRequired,
      country_id: PropTypes.number.isRequired,
      country_path: PropTypes.string.isRequired,
      country_name: PropTypes.string.isRequired,
      result: PropTypes.string.isRequired,
      pillar: PropTypes.string.isRequired
    })
  ).isRequired,
  disabled_bubbles_areas: PropTypes.arrayOf(PropTypes.string)
};
export default BubbleChart;

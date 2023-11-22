import React, { useEffect, useMemo } from 'react';
import PropTypes from 'prop-types';
import SingleCell from './SingleCell';

import { SCORE_RANGES, VALUES } from './constants';
import { groupBy, keys, pickBy, values } from 'lodash';

import ChartMobile from './chart-mobile';

const DESKTOP_MIN_WIDTH = 992;

const SCALE = 1;

// radius of bubbles
const COMPANIES_MARKET_CAP_GROUPS = {
  1: 6 * SCALE,
  2: 9 * SCALE,
  3: 12 * SCALE,
  4: 15 * SCALE
};

const COMPANIES_MARKET_CAP_GROUPS_KEYS = [
  '1st Quartile',
  '2nd Quartile',
  '3rd Quartile',
  '4th Quartile'
];

const SINGLE_CELL_SVG_WIDTH = 120;
const SINGLE_CELL_SVG_HEIGHT = 100;

let tooltip = null;

const AREA_TO_REPLACE = 'Renewable Opportunities';
const AREA_TO_REPLACE_VALUE = 'No area-level results';

const BubbleChart = ({ results }) => {
  const tooltipEl = '<div id="bubble-chart-tooltip" class="bubble-tip" hidden style="position:absolute;"></div>';
  useEffect(() => {
    document.body.insertAdjacentHTML('beforeend', tooltipEl);
    tooltip = document.getElementById('bubble-chart-tooltip');
  }, []);
  const ranges = keys(SCORE_RANGES);

  const parsedData = useMemo(
    () => values(values(groupBy(results, 'pillar'))).map((value) => ({
      pillar: value[0].pillar,
      values: values(groupBy(value, 'area')).map((areaValues) => {
        const vValues = pickBy(
          groupBy(areaValues, 'result'),
          (_value, key) => key in VALUES
        );
        const v = {
          ...VALUES,
          ...vValues
        };
        return {
          area: areaValues[0].area,
          values: values(v)
        };
      })
    })),
    [results]
  );

  const [isMobile, setIsMobile] = React.useState(true);

  const handleResize = () => {
    if (window.innerWidth < DESKTOP_MIN_WIDTH) {
      setIsMobile(true);
    } else {
      setIsMobile(false);
    }
  };

  useEffect(() => {
    if (typeof window !== 'undefined') {
      handleResize();
      window.addEventListener('resize', handleResize);
    }
    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  return (
    <div>
      <div className="bubble-chart__container bubble-chart__container__grid">
        <div className="bubble-chart__level-title-country">Pillar</div>
        <div />
        <div className="bubble-chart__level-title-country">Area</div>
        {ranges.map((range) => (
          <div className="bubble-chart__level-country" key={range}>
            <div className="bubble-chart__level-title-country">{range}</div>
          </div>
        ))}
      </div>
      {isMobile ? (
        <div className="bubble-chart__container bubble-chart__container__mobile">
          <ChartMobile data={parsedData} />
        </div>
      ) : (
        <div className="bubble-chart__container bubble-chart__container__grid">
          <ChartRows data={parsedData} isMobile={isMobile} />
        </div>
      )}
      <div>
        <div className="bubble-chart__legend">
          <p>Per capita emission intensity</p>
          {Object.entries(COMPANIES_MARKET_CAP_GROUPS).map(
            ([key, value], index) => (
              <div className="bubble-chart__legend__item" key={key}>
                <div
                  className="bubble-chart__legend__item__circle"
                  style={{
                    width: `${value * 2 * SCALE}px`,
                    height: `${value * 2 * SCALE}px`
                  }}
                />
                <span>{COMPANIES_MARKET_CAP_GROUPS_KEYS[index]}</span>
              </div>
            )
          )}
        </div>
      </div>
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
     <div>
        <p class="bubble-tip-header">${tooltipContent.header}</p>
        <p class="bubble-tip-text">${tooltipContent.emission_size}</p>
     </div>
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

const ChartRows = ({ data }) => data?.map((pillar, pillarIndex) => {
  const pillarName = pillar.pillar;
  const pillarSpan = pillar.values.length;
  const pillarAcronym = pillarName
    .split(' ')
    .map((word) => word[0])
    .join('');

  return (
    <>
      <div
        className="bubble-chart__level-area-country"
        style={{
          gridRow: `span ${pillarSpan}`
        }}
        key={pillarName}
      >
        <span style={{ flex: 1 }}>
          {pillarIndex + 1}.&nbsp;{pillarName}
        </span>
        <div className="bubble-chart__level-area-country__line" />
      </div>

      {pillar.values.map(({ area, values: areaValues }, areaIndex) => (
        <>
          <div key={area} className="bubble-chart__level-area-country__area">
            {pillarAcronym} {areaIndex + 1}. {area}
          </div>
          {areaValues.map((areaValuesResult, i) => {
            const countriesBubbles = areaValuesResult.map((result) => {
              const emission_size = COMPANIES_MARKET_CAP_GROUPS_KEYS[result.market_cap_group - 1];
              return {
                value: COMPANIES_MARKET_CAP_GROUPS[result.market_cap_group],
                tooltipContent: {
                  header: result.country_name,
                  emission_size
                },
                path: result.country_path,
                color: result.color,
                result: result.result
              };
            });

            // Remove special characters from the key to be able to use d3-select as it uses querySelector

            const cleanKey = area.replace(/[^a-zA-Z\-_:.]/g, '');
            const uniqueKey = `${cleanKey}-${areaIndex}-${i}`;
            return (
              <div className="bubble-chart__cell-country" key={uniqueKey}>
                {area === AREA_TO_REPLACE ? (
                  <span className="--replaced">{AREA_TO_REPLACE_VALUE}</span>
                ) : (
                  ForceLayoutBubbleChart(countriesBubbles, uniqueKey)
                )}
              </div>
            );
          })}
        </>
      ))}
    </>
  );
});

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
  ).isRequired
};
export default BubbleChart;

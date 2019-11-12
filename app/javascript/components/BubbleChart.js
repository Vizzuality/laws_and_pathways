import React from "react";
import PropTypes from "prop-types";
import legendImage from '../../assets/images/bubble-chart-legend.svg';
import SingleBubbleChart from './SingleBubbleChart';
import BaseTooltip from './BaseTooltip.js';

const COMPANIES_SIZES = {
  large: 45,
  medium: 33,
  small: 18
};

const LEVELS_COLORS = [
  '#86A9F9',
  '#5587F7',
  '#2465F5',
  '#0A4BDC',
  '#083AAB',
  '#042b82'
];

const LEVELS_SUBTITLES = {
  0: 'Unaware',
  1: 'Awareness',
  2: 'Building capacity',
  3: 'Integrating into operational decision making',
  4: 'Strategic assessment'
};

const tooltipDisclaimer = `Companies have to answer “yes” to all questions on a level to move to the next one`;

const BubbleChart = (data) => {
  const dataLevels = data.levels;
  const sectors = data.sectors;

  const parsedData = Object.keys(dataLevels).map(sectorName => ({
    sector: sectorName,
    data: Object.values(dataLevels[sectorName])
  }))

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

  const levelsSignature = dataLevels && Object.keys(dataLevels[Object.keys(dataLevels)[0]]);

  return (
    <div className="bubble-chart__container" style={{ 'gridTemplateColumns': `repeat(${levelsSignature.length + 1}, 1fr)` }}>
      <div className="bubble-chart__legend-container">
        <div className="bubble-chart__title-container">
          <span className="bubble-chart__title">Market cap</span>
          <BaseTooltip 
            tooltipTrigger={<button className="bubble-chart__info">?</button>}
            tooltipContent={<span>{tooltipDisclaimer}</span>}
          />
        </div>
        <div className="bubble-chart__legend">
          <img className="bubble-chart__legend-image" src={legendImage} />
          <div className="bubble-chart__legend-titles-container">
            {Object.keys(COMPANIES_SIZES).map(companySize => (
              <span className="bubble-chart__legend-title">{companySize}</span>
            ))}
          </div>
        </div>
      </div>
      {levelsSignature.map((el, i) => (
        <div className="bubble-chart__level" key={`${el}-${i}-${Math.random()}`}>
          <div className="bubble-chart__level-container">
            <div class="bubble-chart__level-title">{`Level ${el}`}</div>
            <div class="bubble-chart__level-subtitle">{LEVELS_SUBTITLES[el]}</div>
          </div>
        </div>
      ))}
      {parsedData.map(dataRow => createRow(dataRow.data, dataRow.sector, sectors))}
    </div>
  );
}

const ForceLayoutBubbleChart = (companiesBubbles, uniqueKey) => {
  const width = 80;
  const height = 38;

  const handleBubbleClick = (company) => window.open(`/tpi/companies/${company.slug}`, '_blank');

  return (
    <SingleBubbleChart 
      width={width}
      height={height}
      uniqueKey={uniqueKey}
      handleNodeClick={handleBubbleClick}
      data={companiesBubbles.length && companiesBubbles}
    />
  )
}

const createRow = (dataRow, title, sectors) => { 
  const sectorSlug = sectors.find(s => s.name === title).slug;
  return (
    <React.Fragment key={Math.random()}>
      <div className="bubble-chart__sector-link">
        <a href={`/tpi/sectors/${sectorSlug}`}>{title}</a>
      </div>
      {dataRow.map((el, i) => {
        const companiesBubbles = el.map(company => ({
          value: COMPANIES_SIZES[company.size],
          tooltipContent: [company.name, `Level ${company.level}`],
          slug: company.slug,
          color: LEVELS_COLORS[i]
        }))

        const uniqueKey = `${title}-${el.length}-${i}`;

        return (
          <div className="bubble-chart__cell" key={uniqueKey}>
            {ForceLayoutBubbleChart(companiesBubbles, uniqueKey)}
          </div>
        )
      })}
    </React.Fragment>
  )
}

BubbleChart.propTypes = {
  data: PropTypes.object
};
export default BubbleChart;

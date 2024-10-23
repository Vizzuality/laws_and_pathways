import React from 'react';
import PropTypes from 'prop-types';
import legendImage from 'images/tpi/sectors-bubble-chart-legend.svg';
import SingleCell from './SingleCell';
import hoverIcon from 'images/icons/hover-cursor.svg';

const SCALE = 1;

// radius of bubbles
const COMPANIES_MARKET_CAP_GROUPS = {
  '50-70': 10 * SCALE,
  '11-50': 5 * SCALE,
  '1-10': 3 * SCALE
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

const Row = ({ dataRow, title, sectors }) => {
  const sector = sectors.find((s) => s.name === title);

  return (
    <React.Fragment key={Math.random()}>
      <div className="bubble-chart__row-link">
        <a href={sector.path}>{title}</a>
      </div>
      {dataRow.map((el, i) => {
        const companies = el.map((company) => ({
          name: company.name,
          url: company.path
        }));

        const companiesBubble = {
          value: el.length,
          color: LEVELS_COLORS[i],
          tooltipContent: {
            level: `Level ${i} - ${LEVELS_SUBTITLES[i]}`,
            title,
            companies
          }
        };
        // Remove special characters from the key to be able to use d3-select as it uses querySelector
        const cleanKey = title.replace(/[^a-zA-Z0-9\-_:.]/g, '');
        const uniqueKey = `${cleanKey}-${el.length}-${i}`;

        return (
          <div
            className={`bubble-chart__cell ${
              i === dataRow.length - 1 ? 'last' : ''
            }`}
            key={uniqueKey}
          >
            <SingleCell
              width={SINGLE_CELL_SVG_WIDTH}
              height={SINGLE_CELL_SVG_HEIGHT}
              uniqueKey={uniqueKey}
              data={companiesBubble}
            />
          </div>
        );
      })}
    </React.Fragment>
  );
};

Row.propTypes = {
  dataRow: PropTypes.array.isRequired,
  title: PropTypes.string.isRequired,
  sectors: PropTypes.array.isRequired
};

const BubbleChart = ({ levels, sectors }) => {
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
  const parsedData = Object.entries(levels).map(
    ([sectorName, sectorValue]) => ({
      sector: sectorName,
      data: Object.values(sectorValue)
    })
  );

  const levelsSignature = levels && Object.keys(levels[Object.keys(levels)[0]]);

  return (
    <div className="is-hidden-touch">
      <div className="mq-sector-pie-chart-title">
        <img src={hoverIcon} alt="Hover icon" />
        <p>
          <span>Click on the bubbles to see the detailed list of companies for each sector.</span>
        </p>
      </div>

      <div
        className="bubble-chart__container bubble-chart__container--sectors"
        style={{
          gridTemplateColumns: `repeat(${levelsSignature.length + 1}, 1fr)`
        }}
      >
        <div className="bubble-chart__legend-container">
          <div className="bubble-chart__title-container">
            <span className="bubble-chart__title">No. of companies</span>
          </div>
          <div className="bubble-chart__legend">
            <img
              className="bubble-chart__legend-image"
              src={legendImage}
              alt="Bubble size description"
            />
            <div className="bubble-chart__legend-titles-container">
              {Object.keys(COMPANIES_MARKET_CAP_GROUPS).map(
                (companySize, i) => (
                  <span
                    key={`${companySize}-${i}`}
                    className="bubble-chart__legend-title"
                  >
                    {companySize}
                  </span>
                )
              )}
            </div>
          </div>
        </div>
        {levelsSignature.map((el, i) => (
          <div
            className={`bubble-chart__level ${
              i === levelsSignature.length - 1 ? 'last' : ''
            }`}
            key={`${el}-${i}-${Math.random()}`}
          >
            <div className="bubble-chart__level-container">
              <div className="bubble-chart__level-title">{`Level ${el}`}
              </div>
              <div className="bubble-chart__level-subtitle">
                {LEVELS_SUBTITLES[el]}
              </div>
            </div>
          </div>
        ))}
        {parsedData.map((dataRow) => (
          <Row
            dataRow={dataRow.data}
            title={dataRow.sector}
            sectors={sectors}
            key={dataRow.sector}
          />
        ))}
      </div>
    </div>
  );
};

BubbleChart.propTypes = {
  levels: PropTypes.object.isRequired,
  sectors: PropTypes.array.isRequired
};
export default BubbleChart;

/* eslint-disable function-paren-newline */
/* eslint-disable implicit-arrow-linebreak */
import React from 'react';
import PropTypes from 'prop-types';
import Table from 'rc-table';
import ReactTooltip from 'react-tooltip';
import cx from 'classnames';
import chevronIcon from 'images/icon_chevron_dark/chevron_down_black-1.svg';

const COLORS = {
  'Not assessable using TPI’s methodology': { color: '#CACBCE' },
  'No or unsuitable disclosure': { color: 'white', border: true },
  'Not aligned': { color: '#ED3D4A' },
  'National Pledges': { color: '#F6C242' },
  'Below 2 Degrees': { color: '#F9DF65' },
  '1.5 Degrees': { color: '#57BE77' }
};

function ColorDot({ value }) {
  if (!value) return null;

  return (
    <div className="color-dot-container">
      <span
        className={cx('color-dot', { withBorder: COLORS[value]?.border })}
        style={{ backgroundColor: COLORS[value]?.color }}
      />
    </div>
  );
}

ColorDot.propTypes = {
  value: PropTypes.string.isRequired
};

function CPMatrixTable({ data, meta }) {
  if (!data) return <div>no data</div>;
  const href = window.location.pathname;
  const { portfolios } = meta || {};
  const columns = [
    {
      title: 'Bussiness Segment',
      children: [
        {
          title: 'Activities',
          dataIndex: 'activities',
          key: 'activities',
          width: 200,
          ellipsis: true,
          render: (content) => {
            const assumptions = data[content]?.assumptions;
            const hasEmissionsChart = data[content]?.has_emissions;
            return (
              <span className="activities-text">
                {hasEmissionsChart && (
                  <a href={`${href}#${content}`} className="chart-link">
                    <img src={chevronIcon} alt="chevron" />
                  </a>
                )}
                {content}
                {assumptions && (
                  <span className="assumptions-ellipsis" data-tip={assumptions}>
                    ...
                  </span>
                )}
              </span>
            );
          }
        }
      ]
    }
  ].concat(
    Object.entries(portfolios).map(([portfolio, sectors]) => ({
      title: portfolio,
      children: sectors.map((sector) => ({
        title: sector,
        dataIndex: sector,
        key: sector,
        width: 200,
        ellipsis: true,
        render: (content) => <ColorDot value={content} />
      }))
    }))
  );

  const parsedData = Object.entries(data).map(([activity, values]) => ({
    key: activity,
    activities: activity,
    ...values.portfolio_values
  }));

  return (
    <div className="cp-matrix-table">
      <Table
        columns={columns}
        data={parsedData}
        className="bordered"
        scroll={{ y: false, x: 200 }}
        ellipsis
      />
      <div className="cp-matrix-legend">
        {Object.keys(COLORS).map((key) => (
          <div className="legend-item" key={`legend-item-${key}`}>
            <ColorDot value={key} />
            <span className="legend-text">{key}</span>
          </div>
        ))}
      </div>
      <ReactTooltip class="cp-tooltip" />
    </div>
  );
}

CPMatrixTable.defaultProps = {
  data: null,
  meta: null
};

CPMatrixTable.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      assumptions: PropTypes.string.isRequired,
      portfolio_values: PropTypes.object.isRequired,
      has_emissions: PropTypes.bool
    })
  ),
  meta: PropTypes.shape({
    portfolios: PropTypes.shape({}),
    sectors: PropTypes.shape({})
  })
};

export default CPMatrixTable;

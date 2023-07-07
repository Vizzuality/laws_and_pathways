/* eslint-disable operator-linebreak */
/* eslint-disable function-paren-newline */
/* eslint-disable implicit-arrow-linebreak */
import React from 'react';
import PropTypes from 'prop-types';
import Table from 'rc-table';
import ReactTooltip from 'react-tooltip';
import cx from 'classnames';
import chevronIcon from 'images/icon-go-to-arrow.svg';
import { useScrollClasses } from './cp-matrix-table-hooks';

const COLORS = {
  'Not assessable using TPI’s methodology': { color: '#CACBCE' },
  'No or unsuitable disclosure': { color: 'white', border: true },
  'Not Aligned': { color: '#ED3D4A' },
  'National Pledges': { color: '#F99602' },
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

ColorDot.defaultProps = {
  value: null
};

ColorDot.propTypes = {
  value: PropTypes.string
};

function CPMatrixTable({ data, meta }) {
  useScrollClasses();

  if (!data) return <div>no data</div>;

  const shortenTitle = (title) => {
    const truncateString = (str, maxLength) => {
      if (str.length <= maxLength) {
        return str;
      }
      const words = str.slice(0, maxLength).split(' ');
      return `${words.slice(0, words.length - 1).join(' ')}...`;
    };

    if (title.length > 28) {
      return <div title={title}>{truncateString(title, 32)}</div>;
    }
    return title;
  };

  const href = window.location.pathname;
  const { portfolios } = meta || {};

  const columns = [
    {
      title: 'Bussiness Segment',
      className: 'vertical-align-center',
      children: [
        {
          title: 'Activities',
          dataIndex: 'activities',
          key: 'activities',
          className: 'activities-column',
          width: 200,
          fixed: true,
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
      className: 'vertical-align-center',
      children: sectors.map((sector, i) => ({
        title: shortenTitle(sector),
        dataIndex: sector,
        key: sector,
        width: 120,
        className:
          // eslint-disable-next-line no-nested-ternary
          sectors.length > 1
            ? i !== sectors.length - 1
              ? 'sector-column-dashed-left'
              : 'sector-column-dashed-right'
            : '',
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
        className="cp-matrix-table bordered"
        scroll={{ y: false, x: 800 }}
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
  data: PropTypes.objectOf(
    PropTypes.shape({
      assumptions: PropTypes.string,
      portfolio_values: PropTypes.object,
      has_emissions: PropTypes.bool
    })
  ),
  meta: PropTypes.shape({
    portfolios: PropTypes.shape({}),
    sectors: PropTypes.array
  })
};

export default CPMatrixTable;

/* eslint-disable react/no-this-in-sfc */

import React from 'react';
import PropTypes from 'prop-types';
import { useParsedChartData } from './chart-utils';
import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';
import cx from 'classnames';
import hexToRgba from 'hex-to-rgba';

import { getMultipleOptions, getMultipleMobileOptions } from './options';

import { useChartData } from '../hooks';
import { useDeviceInfo } from 'components/Responsive';

import Legend from './Legend';

const EmissionsLegend = ({ data }) => {
  // General legend items are already shown and shouldn't be included. We also don't want to show the legend item for the target years.
  const generalLegendItemsName = data.filter(d => d.type !== 'area' && d.name !== 'Target Years').map(d => d.name);
  const filteredData = data.filter(d => !generalLegendItemsName.concat('Target Years').includes(d.name));
  return (
    <div className="emissions-legend">
      {filteredData.map((d) => (
        <div className="emissions-legend__item" key={d.name}>
          <div
            className={cx('emissions-legend__circle', { line: d.type !== 'area' })}
            style={{ backgroundColor: d.type === 'area' ? hexToRgba(d.color, 0.3) : d.color }}
          />
          <div className="emissions-legend__text">{d.name}</div>
        </div>
      ))}
    </div>);
};

EmissionsLegend.propTypes = {
  data: PropTypes.arrayOf(PropTypes.shape({
    color: PropTypes.string,
    name: PropTypes.string
  })).isRequired
};

const Chart = ({ isMobile, sector }) => {
  const { dataUrl, name, unit } = sector;
  const { data, error, loading } = useChartData(dataUrl);
  const chartData = useParsedChartData(data);
  const options = isMobile ? getMultipleMobileOptions({ chartData, unit }) : getMultipleOptions({ chartData, unit });
  if (error) return <p>{error}</p>;
  if (loading) return <p>Loading...</p>;
  const { series } = options;

  return (
    <div className="individual-chart" id={name}>
      <div className="chart-container">
        <div>
          <h5 className="individual-chart-title">{name}</h5>
          <HighchartsReact
            highcharts={Highcharts}
            options={options}
          />
        </div>
        <EmissionsLegend data={series} />
      </div>
    </div>
  );
};

Chart.propTypes = {
  isMobile: PropTypes.bool.isRequired,
  sector: PropTypes.shape({
    dataUrl: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    unit: PropTypes.string
  }).isRequired
};

function MultipleChart({ sectors }) {
  const { dataUrl } = sectors?.[0] || {};

  const { isMobile } = useDeviceInfo();

  const { data } = useChartData(dataUrl);
  const chartData = useParsedChartData(data);
  if (!sectors) return null;

  return (
    <div className="chart chart--cp-performance multiple-chart">
      <Legend
        chartData={chartData}
        companySelector={false}
      />
      <div className="charts-container">
        {sectors.map(sector => <Chart key={sector.dataUrl} isMobile={isMobile} sector={sector} />)}
      </div>
    </div>
  );
}

MultipleChart.propTypes = {
  sectors: PropTypes.arrayOf(PropTypes.shape({
    dataUrl: PropTypes.string.isRequired,
    unit: PropTypes.string
  })).isRequired
};

export default MultipleChart;

import PropTypes from 'prop-types';

import React from 'react';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { options } from './options';

const EmissionsChart = ({ chartData }) => {
  const { data, metadata } = chartData;

  return (
    <div className="emissions__chart">
      <HighchartsReact
        highcharts={Highcharts}
        options={{
          ...options,
          yAxis: {
            ...options.yAxis,
            title: { ...options.yAxis.title, text: metadata.unit }
          },
          series: data,
          title: { text: '' }
        }}
      />
    </div>
  );
};

export default EmissionsChart;

EmissionsChart.propTypes = {
  chartData: PropTypes.shape({
    data: PropTypes.arrayOf(
      PropTypes.shape({
        name: PropTypes.string.isRequired,
        data: PropTypes.arrayOf(PropTypes.object).isRequired,
        zoneAxis: PropTypes.string,
        zones: PropTypes.arrayOf(PropTypes.object)
      })
    ),
    metadata: PropTypes.shape({
      unit: PropTypes.string.isRequired
    })
  })
};

EmissionsChart.defaultProps = {
  chartData: {
    data: [],
    metadata: {
      unit: ''
    }
  }
};

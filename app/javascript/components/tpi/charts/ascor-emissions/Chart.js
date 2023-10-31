import PropTypes from 'prop-types';

import React, { useMemo } from 'react';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { options } from './options';

const EmissionsChart = ({ chartData }) => {
  const { data, metadata } = chartData;

  const hasNegative = useMemo(
    () => data.every((series) => series.data?.every((point) => point?.y < 0)),
    [data]
  );

  return (
    <div className="emissions__chart">
      <HighchartsReact
        highcharts={Highcharts}
        options={{
          ...options,
          yAxis: {
            ...options.yAxis,
            min: hasNegative ? null : 0,
            max: hasNegative ? 0 : null,
            title: { ...options.yAxis.title, text: metadata.unit }
          },
          series: data
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

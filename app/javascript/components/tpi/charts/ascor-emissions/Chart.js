import PropTypes from 'prop-types';

import React, { useMemo } from 'react';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { options } from './options';

const EmissionsChart = ({ chartData }) => {
  const { data, metadata } = chartData;

  const hasNegative = useMemo(
    () => data.some((series) => series.data?.some((point) => point?.y < 0)),
    [data]
  );

  const minTickInterval = useMemo(() => data?.[0]?.data?.[0]?.x, [data]);

  return (
    <div className="emissions__chart">
      <HighchartsReact
        highcharts={Highcharts}
        options={{
          ...options,
          yAxis: {
            ...options.yAxis,
            min: hasNegative ? null : 0,
            title: { ...options.yAxis.title, text: metadata.unit }
          },
          xAxis: {
            ...options.xAxis,
            min: minTickInterval
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

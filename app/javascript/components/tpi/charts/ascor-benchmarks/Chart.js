import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';
import { options } from './options';

const Chart = ({ data: { data, metadata }, assessmentYear }) => {
  const chartData = useMemo(
    () => [
      {
        name: 'Country emissions pathway',
        custom: { unit: metadata.unit },
        data: Object.entries(data.emissions).map(([year, value]) => ({
          x: Number(year),
          y: value
        })),
        zoneAxis: 'x',
        zones: [
          {
            value: data.last_historical_year
          },
          {
            dashStyle: 'dash'
          }
        ]
      },
      ...data?.benchmarks.map((d) => ({
        custom: { unit: metadata.unit },
        name: d.benchmark_type,
        data: Object.entries(d.emissions).map(([year, value]) => ({
          x: Number(year),
          y: value
        }))
      }))
    ],
    [data, metadata.unit]
  );

  return (
    <div className="ascor-benchmarks">
      <div className="ascor-benchmarks__legend">
        <span>
          <span className="ascor-benchmarks__legend__line" />
          Trend
        </span>
        <span>
          <span className="ascor-benchmarks__legend__line --targeted-pathway" />
          Targeted pathway
        </span>
      </div>
      <HighchartsReact
        highcharts={Highcharts}
        options={{
          ...options,
          xAxis: {
            ...options.xAxis,
            max: assessmentYear && assessmentYear >= 2025 ? 2035 : 2030
          },
          yAxis: {
            ...options.yAxis,
            min: 0,
            title: { ...options.yAxis.title, text: metadata.unit }
          },
          series: chartData
        }}
      />
    </div>
  );
};

Chart.propTypes = {
  data: PropTypes.shape({
    data: PropTypes.shape({
      benchmarks: PropTypes.arrayOf(
        PropTypes.shape({
          benchmark_type: PropTypes.string,
          emissions: PropTypes.objectOf(PropTypes.number)
        })
      ),
      emissions: PropTypes.objectOf(PropTypes.number),
      last_historical_year: PropTypes.number
    }),
    metadata: PropTypes.shape({
      unit: PropTypes.string
    })
  }).isRequired,
  assessmentYear: PropTypes.number
};

Chart.defaultProps = {
  assessmentYear: null
};

export default Chart;

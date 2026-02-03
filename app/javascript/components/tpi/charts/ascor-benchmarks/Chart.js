import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';
import { options } from './options';

const HIGHLIGHT_YEARS = [2030, 2035];

const Chart = ({ data: { data, metadata }, assessmentYear }) => {
  const chartData = useMemo(
    () => [
      {
        name: 'Country emissions pathway',
        custom: { unit: metadata.unit },
        marker: {
          enabled: false,
          states: {
            hover: {
              enabled: true
            }
          }
        },
        data: Object.entries(data.emissions).map(([year, value]) => {
          const yearNum = Number(year);
          const isProjected = yearNum > data.last_historical_year;
          const isHighlight = isProjected && HIGHLIGHT_YEARS.includes(yearNum);
          return {
            x: yearNum,
            y: value,
            marker: isHighlight
              ? {
                enabled: true,
                radius: 5,
                symbol: 'circle',
                fillColor: '#5454C4',
                lineWidth: 2,
                lineColor: '#5454C4'
              }
              : { enabled: false }
          };
        }),
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
        marker: {
          enabled: false,
          states: {
            hover: {
              enabled: true
            }
          }
        },
        data: Object.entries(d.emissions).map(([year, value]) => {
          const yearNum = Number(year);
          const isHighlight = HIGHLIGHT_YEARS.includes(yearNum);
          return {
            x: yearNum,
            y: value,
            marker: isHighlight
              ? {
                enabled: true,
                radius: 5,
                symbol: 'circle'
              }
              : { enabled: false }
          };
        })
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

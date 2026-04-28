import React from 'react';
import PropTypes from 'prop-types';
import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { useChartData } from '../hooks';

const SCENARIO_COLORS = {
  '1.5 Degrees': '#00C170',
  'Below 2 Degrees': '#FFDD49',
  '2 Degrees': '#FFDD49',
  'Paris Pledges': '#FF9600',
  'National Pledges': '#FF9600',
  'Not Aligned': '#ED3D4A',
  'No or unsuitable disclosure': '#595B5D',
  'No disclosure': '#595B5D'
};

const DEFAULT_COLOR = '#86A9F9';

function getColor(scenario) {
  return SCENARIO_COLORS[scenario] || DEFAULT_COLOR;
}

function buildOptions(alignmentData) {
  const timeframes = Object.keys(alignmentData);
  if (!timeframes.length) return null;

  const allScenarios = [
    ...new Set(timeframes.flatMap(tf => Object.keys(alignmentData[tf])))
  ];

  const series = allScenarios.map(scenario => ({
    name: scenario,
    color: getColor(scenario),
    data: timeframes.map(tf => alignmentData[tf][scenario] || 0)
  }));

  return {
    chart: { type: 'column' },
    title: { text: null },
    xAxis: {
      categories: timeframes,
      crosshair: true
    },
    yAxis: {
      min: 0,
      title: { text: 'Number of companies' },
      allowDecimals: false
    },
    tooltip: {
      headerFormat: '<b>{point.key}</b><br/>',
      pointFormat: '{series.name}: {point.y}<br/>'
    },
    plotOptions: {
      column: {
        borderWidth: 0,
        groupPadding: 0.15,
        pointPadding: 0.05
      }
    },
    legend: {
      align: 'center',
      verticalAlign: 'bottom',
      layout: 'horizontal'
    },
    credits: { enabled: false },
    series
  };
}

function ChemicalsBarChart({ dataUrl }) {
  const { data, error, loading } = useChartData(dataUrl);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>{error}</p>;

  const options = buildOptions(data);

  if (!options) return <p>No alignment data available.</p>;

  return (
    <div className="chart chart--cp-chemicals-bar">
      <HighchartsReact highcharts={Highcharts} options={options} />
    </div>
  );
}

ChemicalsBarChart.propTypes = {
  dataUrl: PropTypes.string.isRequired
};

export default ChemicalsBarChart;

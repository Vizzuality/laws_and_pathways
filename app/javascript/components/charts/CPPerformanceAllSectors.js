/* eslint-disable react/no-this-in-sfc */

import React from 'react';
import PropTypes from 'prop-types';

import { ColumnChart } from 'react-chartkick';

function CPPerformanceAllSectors({ dataUrl }) {
  const options = {
    // I couldn't make highcharts to use color directly from the chart data so sorting chart data
    // by cp alignment name and then we will use below colors in the right order
    colors: [
      '#00C170', '#FFDD49', '#FF9600', '#ED3D4A', '#595B5D'
    ],
    legend: {
      align: 'left',
      verticalAlign: 'top',
      margin: 50
    },
    plotOptions: {
      column: {
        stacking: 'percent',
        dataLabels: {
          enabled: true,
          formatter() {
            return this.y > 0 ? this.y : null;
          }
        }
      }
    },
    yAxis: {
      labels: {
        format: '{value}%' // # does not work!
      }
    }
  };

  return (
    <ColumnChart id="cp-performance-all-sectors-chart" data={dataUrl} height="600px" library={options} stacked />
  );
}

CPPerformanceAllSectors.propTypes = {
  dataUrl: PropTypes.string.isRequired
};

export default CPPerformanceAllSectors;

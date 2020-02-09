import React from 'react';
import PropTypes from 'prop-types';

import { LineChart } from 'react-chartkick';

function CPPerformanceAllSectors({ dataUrl, unit }) {
  const options = {
    colors: [
      '#00C170', '#ED3D4A', '#FFDD49', '#440388', '#FF9600', '#B75038', '#00A8FF', '#F78FB3', '#191919', '#F602B4'
    ],
    legend: {
      verticalAlign: 'top',
      margin: 50
    },
    plotOptions: {
      area: {
        marker: {
          enabled: false
        }
      },
      line: {
        marker: {
          enabled: false
        }
      },
      column: {
        stacking: 'normal'
      },
      series: {
        lineWidth: 4
      }
    },
    yAxis: {
      title: {
        text: unit,
        reserveSpace: false,
        textAlign: 'left',
        align: 'high',
        rotation: 0,
        x: 0,
        y: -20
      }
    }
  };

  return (
    <div className="chart chart--cp-emissions">
      <div className="legend">
        <span className="legend-item legend-item--reported">Reported</span>
        <span className="legend-item legend-item--targeted">Targeted</span>
      </div>
      <LineChart id="cp-performance-chart" data={dataUrl} height="800px" curve={false} library={options} />
    </div>
  );
}

CPPerformanceAllSectors.propTypes = {
  dataUrl: PropTypes.string.isRequired,
  unit: PropTypes.string.isRequired
};

export default CPPerformanceAllSectors;

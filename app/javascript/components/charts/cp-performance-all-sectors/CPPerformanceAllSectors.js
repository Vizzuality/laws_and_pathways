/* eslint-disable react/no-this-in-sfc */

import React from 'react';
import PropTypes from 'prop-types';
import sortBy from 'lodash/sortBy';

import { ColumnChart } from 'react-chartkick';

import {
  createSVGLineBelowElements,
  createSVGTextBetweenElements
} from './helpers';

function CPPerformanceAllSectors({ dataUrl, sectors }) {
  const options = {
    // I couldn't make highcharts to use color directly from the chart data so sorting chart data
    // by cp alignment name and then we will use below colors in the right order
    chart: {
      marginBottom: 80,
      events: {
        render() {
          const g = document.querySelector('#cp-performance-all-sectors-chart g.highcharts-xaxis-labels');

          [...g.querySelectorAll('.generated')].forEach((el) => el.remove());

          const barWidth = this.series[0] && this.series[0].barW; // workaround for having

          const textLabels = [...g.querySelectorAll('text')];
          const chartSectors = this.xAxis[0].categories;
          const usedSectors = sectors.filter(s => chartSectors.includes(s.name));
          const clusters = [...usedSectors.map(s => s.cluster).filter(x => x)];

          clusters.forEach((cluster) => {
            const cSectors = sortBy(usedSectors.filter(s => s.cluster === cluster), 'name');

            if (!cSectors.length) return;

            const firstSector = cSectors[0].name;
            const lastSector = cSectors[cSectors.length - 1].name;

            const firstLabel = textLabels[chartSectors.indexOf(firstSector)];
            const lastLabel = textLabels[chartSectors.indexOf(lastSector)];

            if (!firstLabel || !lastLabel) return;

            const line = createSVGLineBelowElements(firstLabel, lastLabel, barWidth, 20.5); // .5 offset to have 1px stroke-width
            const clusterElement = createSVGTextBetweenElements(firstLabel, lastLabel, cluster, 40);

            g.appendChild(line);
            g.appendChild(clusterElement);
          });
        }
      }
    },
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
        borderWidth: 0,
        dataLabels: {
          enabled: true,
          formatter() {
            return this.y > 0 ? this.y : null;
          },
          style: {
            color: '#000000',
            textOutline: '0px'
          }
        }
      }
    },
    xAxis: {
      labels: {
        style: {
          color: '#0A4BDC'
        },
        formatter() {
          const sector = sectors.find(s => s.name === this.value);

          if (!sector) return this.value;

          return sector.link;
        }
      }
    },
    yAxis: {
      labels: {
        formatter() {
          return `${this.value}%`;
        }
      }
    }
  };

  return (
    <ColumnChart id="cp-performance-all-sectors-chart" data={dataUrl} height="600px" library={options} stacked />
  );
}

CPPerformanceAllSectors.propTypes = {
  dataUrl: PropTypes.string.isRequired,
  sectors: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.string.isRequired,
      link: PropTypes.string.isRequired,
      cluster: PropTypes.string
    }).isRequired
  ).isRequired
};

export default CPPerformanceAllSectors;
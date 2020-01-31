/* eslint-disable react/no-this-in-sfc */

import React from 'react';
import PropTypes from 'prop-types';
import sortBy from 'lodash/sortBy';

import { ColumnChart } from 'react-chartkick';

function createSVGLine(x1, y1, x2, y2) {
  const line = createSVGElement('line');
  line.setAttribute('x1', x1);
  line.setAttribute('y1', y1);
  line.setAttribute('x2', x2);
  line.setAttribute('y2', y2);
  line.setAttribute('stroke', '#666666');
  line.setAttribute('stroke-width', 1);
  line.setAttribute('class', 'generated');
  return line;
}

function createSVGText(x, y, innerText) {
  const text = createSVGElement('text');
  text.setAttribute('x', x);
  text.setAttribute('y', y);
  text.setAttribute('opacity', 1);
  text.setAttribute('style', 'fill:#666666;color:#666666;font-size:12px;');
  text.setAttribute('text-anchor', 'middle');
  text.setAttribute('class', 'generated');
  text.innerHTML = innerText;
  return text;
}

function createSVGElement(element) {
  return document.createElementNS('http://www.w3.org/2000/svg', element);
}

function createSVGLineBelowElements(element1, element2, offset) {
  const y = parseFloat(element1.getAttribute('y'), 10) + offset;
  return createSVGLine(
    element1.getAttribute('x'),
    y,
    element2.getAttribute('x'),
    y
  );
}

function createSVGTextBetweenElements(element1, element2, text, offset) {
  const y = parseFloat(element1.getAttribute('y'), 10) + offset;
  const x1 = parseFloat(element1.getAttribute('x'), 10);
  const x2 = parseFloat(element2.getAttribute('x'), 10);
  const dx = x2 - x1;

  return createSVGText(x1 + dx / 2, y, text);
}

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

          const textLabels = [...g.querySelectorAll('text')];
          const chartSectors = this.xAxis[0].categories;
          const usedSectors = sectors.filter(s => chartSectors.includes(s.name));
          const clusters = [...usedSectors.map(s => s.cluster)];

          clusters.forEach((cluster) => {
            const cSectors = sortBy(usedSectors.filter(s => s.cluster === cluster), 'name');

            if (!cSectors.length) return;

            const firstSector = cSectors[0].name;
            const lastSector = cSectors[cSectors.length - 1].name;

            const firstLabel = textLabels[chartSectors.indexOf(firstSector)];
            const lastLabel = textLabels[chartSectors.indexOf(lastSector)];

            if (!firstLabel || !lastLabel) return;

            const line = createSVGLineBelowElements(firstLabel, lastLabel, 20.5); // .5 offset to have 1px stroke-width
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

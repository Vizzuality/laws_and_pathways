import sortBy from 'lodash/sortBy';
import merge from 'lodash/merge';

import defaultOptions from '../default-options';

import {
  createSVGLineBelowElements,
  createSVGTextBetweenElements
} from './helpers';

export function getOptions(data, sectors) {
  return merge({}, defaultOptions, {
    // I couldn't make highcharts to use color directly from the chart data so sorting chart data
    // by cp alignment name and then we will use below colors in the right order
    chart: {
      marginBottom: 80,
      marginTop: 280,
      height: 800,
      type: 'column',
      events: {
        render() {
          const g = document.querySelector('#cp-performance-all-sectors-chart g.highcharts-xaxis-labels');

          if (!g) return;

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
    credits: {
      enabled: false
    },
    legend: {
      align: 'left',
      verticalAlign: 'top',
      layout: 'vertical',
      itemMarginTop: 10,
      margin: 50,
      floating: true,
      maxHeight: 250
    },
    plotOptions: {
      column: {
        stacking: 'percent',
        borderWidth: 0,
        dataLabels: {
          enabled: true,
          useHTML: true,
          formatter() {
            if (this.y <= 0) return null;
            if (this.series.name !== 'No or unsuitable disclosure') return this.y;

            return `
              <span style="color: white;">
                ${this.y}
              </span>
            `;
          },
          style: {
            color: '#000000',
            textOutline: '0px'
          }
        }
      }
    },
    title: {
      text: ''
    },
    tooltip: {
      useHTML: true,
      formatter() {
        const xValue = this.x;
        const nrOfCompanies = this.y;
        const nrOfCompaniesPercentage = Math.round(this.percentage);
        const alignment = this.series;

        return `
          <div class="tooltip">
            <div class="x-value">${xValue}</div>
            <div class="alignment">
              <span class="circle" style="background: ${alignment.color}"></span>
              ${alignment.name}
            </div>
            <div class="companies">
              ${nrOfCompanies} ${nrOfCompanies === 1 ? 'company' : 'companies'}<br/>
              ${nrOfCompaniesPercentage}%
            </div>
          </div>
        `;
      }
    },
    xAxis: {
      labels: {
        style: {
          color: '#5587F7'
        },
        formatter() {
          const sector = sectors.find(s => s.name === this.value);

          if (!sector) return this.value;

          return sector.link;
        }
      },
      categories: data && data.length && data[0].data.map(x => x[0])
    },
    yAxis: {
      title: {
        enabled: false
      },
      labels: {
        formatter() {
          return `${this.value}%`;
        }
      }
    },
    series: data.map(d => ({
      ...d,
      type: 'column',
      data: d.data.map(x => x[1])
    }))
  });
}

export function getMobileOptions(data, sectors) {
  const descktopOptions = getOptions(data, sectors);
  return merge({}, descktopOptions, {
    chart: {
      height: 700,
      events: {render() {}}
    },
    legend: {
      margin: 35,
      marginLeft: 0,
      padding: 0,
      itemStyle: {fontSize: '14px', fontWeight: 'normal'},
      itemMarginTop: 10
    },
    labels: {
      style: {fontSize: '10px'}
    },
    xAxis: {
      labels: {
        style: {fontSize: '14px'}
      }
    },
    yAxis: {
      labels: {
        x: -3
      }
    }
  });
}

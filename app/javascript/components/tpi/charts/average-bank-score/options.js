import merge from 'lodash/merge';

import defaultOptions from '../default-options';

export function getOptions(data) {
  return merge({}, defaultOptions, {
    chart: {
      type: 'bar'
    },
    legend: {
      enabled: false
    },
    title: {
      text: ''
    },
    xAxis: {
      lineColor: '#595B5D',
      labels: {
        style: {
          color: '#0A4BDC'
        }
      },
      categories: data && data.length && data[0].data.map(x => x[0])
    },
    yAxis: {
      gridLineWidth: 0,
      lineColor: '#595B5D',
      lineWidth: 1,
      tickWidth: 1,
      tickColor: '#595B5D',
      tickLength: 10,
      title: {
        enabled: false
      },
      labels: {
        overflow: 'justify',
        formatter() {
          return `${this.value}%`;
        }
      }
    },
    plotOptions: {
      bar: {
        dataLabels: {
          enabled: true,
          formatter() {
            return `${this.y}%`;
          }
        }
      }
    },
    series: [{
      name: 'Bank average scores',
      color: '#5587F6',
      data: data && data.length && data[0].data.map(x => x[1])
    }]
  });
}

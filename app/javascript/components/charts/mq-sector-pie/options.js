import merge from 'lodash/merge';

import defaultOptions from '../default-options';

export function getOptions({ chartData }) {
  return merge({}, defaultOptions, {
    chart: {
      height: '400px',
      styledMode: true,
      type: 'pie'
    },
    colors: ['#86A9F9', '#5587F7', '#2465F5', '#0A4BDC', '#083AAB'],
    tooltip: {
      enabled: false
    },
    plotOptions: {
      pie: {
        innerSize: '50%', // donut
        dataLabels: {
          enabled: true,
          format: '<strong>Level {point.name}</strong> <br> {point.y} companies <br> {point.percentage:.2f}%',
          alignTo: 'connectors',
          connectorShape: 'crookedLine',
          crookDistance: '100%'
        }
      }
    },
    series: [{
      type: 'pie',
      data: chartData
    }]
  });
}

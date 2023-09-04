import merge from 'lodash/merge';

import defaultOptions from '../default-options';
import { format } from 'd3-format';

export function getOptions({ chartData }) {
  return merge({}, defaultOptions, {
    chart: {
      height: '400px',
      styledMode: true,
      type: 'pie'
    },
    colors: ['#86A9F9', '#5587F7', '#2465F5', '#0A4BDC', '#083AAB', '#9747FF'],
    tooltip: {
      enabled: false
    },
    plotOptions: {
      pie: {
        innerSize: '50%', // donut
        dataLabels: {
          enabled: true,
          // eslint-disable-next-line max-len
          formatter() { return `<strong>Level ${this.point.name === '5' ? '5 [BETA]' : this.point.name}</strong> <br> ${this.point.y} companies <br> ${format('.2f')(this.point.percentage)}%`; },
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

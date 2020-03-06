import merge from 'lodash/merge';

import defaultOptions from '../default-options';

export function getOptions({ chartData }) {
  return merge({}, defaultOptions, {
    chart: {
      marginTop: 50
    },
    colors: ['#00C170'],
    legend: {
      enabled: false
    },
    tooltip: {
      dateTimeLabelFormats: {
        day: '%B %Y',
        hour: '%B %Y',
        minute: '%B %Y',
        month: '%B %Y',
        second: '%B %Y',
        year: '%Y'
      }
    },
    xAxis: {
      minPadding: 0.1,
      maxPadding: 0.1,
      type: 'datetime',
      dateTimeLabelFormats: {
        month: '%m/%Y',
        year: '%Y'
      }
    },
    yAxis: {
      tickInterval: 1,
      title: {
        text: 'Level',
        textAlign: 'right',
        align: 'high',
        rotation: 0,
        x: 20,
        y: -20
      }
    },
    series: chartData.map(d => ({
      ...d,
      data: d.data.map(x => [Date.parse(x[0]), x[1]])
    }))
  });
}

import merge from 'lodash/merge';

import defaultOptions from '../default-options';

export function getOptions(data, isMobile) {
  return merge({}, defaultOptions, {
    chart: {
      type: 'bar'
    },
    legend: {
      enabled: false
    },
    tooltip: {
      enabled: false
    },
    title: {
      text: ''
    },
    xAxis: {
      lineColor: '#595B5D',
      labels: {
        style: {
          color: '#0A4BDC',
          fontSize: isMobile ? '12px' : '16px'
        }
      },
      title: {
        text: 'Areas',
        align: 'high',
        rotation: 0,
        offset: 15,
        y: 5,
        style: {
          color: '#0A4BDC',
          fontSize: '14px',
          fontWeight: 'bold'
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
      max: 100,
      labels: {
        overflow: 'justify',
        formatter() {
          return `${Number(this.value).toFixed(0)}%`;
        }
      }
    },
    plotOptions: {
      bar: {
        dataLabels: {
          enabled: true,
          formatter() {
            return `${parseFloat(Number(this.y).toFixed(1))}%`;
          }
        },
        states: {
          hover: {
            enabled: false
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

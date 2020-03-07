import merge from 'lodash/merge';
import { parse, format } from 'date-fns';
import hexToRgba from 'hex-to-rgba';

import defaultOptions from '../default-options';

export function getOptions({ chartData }) {
  return merge({}, defaultOptions, {
    chart: {
      marginTop: 50,
      height: '300px'
    },
    colors: ['#00C170'],
    legend: {
      enabled: false
    },
    tooltip: {
      useHTML: true,
      formatter() {
        const date = this.x;
        const value = this.y;

        const formattedDate = format(date, 'MM-yyyy');

        return `
          <div class="tooltip">
            ${formattedDate}<br/>
            ${this.series.name}: <strong>${value}</strong>
          </div>
        `;
      }
    },
    xAxis: {
      minPadding: 0.1,
      maxPadding: 0.1,
      type: 'datetime',
      dateTimeLabelFormats: {
        day: '%m/%Y',
        hour: '%m/%Y',
        minute: '%m/%Y',
        month: '%m/%Y',
        year: '%Y'
      }
    },
    yAxis: {
      min: 0,
      max: 4,
      tickInterval: 1,
      labels: {
        style: {
          fontSize: '12px'
        }
      },
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
      clip: false,
      lineWidth: 5,
      states: {
        inactive: {
          opacity: 1
        }
      },
      marker: {
        states: {
          hover: {
            enabled: false
          }
        },
        fillColor: d.name === 'Current Level' ? hexToRgba('#00C170', 0.2) : '#00C170',
        radius: d.name === 'Current Level' ? 24 : 6,
        symbol: 'circle'
      },
      data: d.data.map(x => [Date.parse(parse(x[0], 'dd/MM/yyyy', new Date())), x[1]])
    }))
  });
}

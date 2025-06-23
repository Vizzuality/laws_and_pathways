export const colors = [
  '#17B091',
  '#F26E6E',
  '#5454C4',
  '#B75038',
  '#FFDD49',
  '#00A8FF',
  '#F602B4',
  '#191919',
  '#9747FF',
  '#595B5D'
];

const tooltipLegendLine = (
  opts,
  x,
  color
) => `<svg xmlns="http://www.w3.org/2000/svg" width="25" height="4" viewBox="0 0 25 4" fill="none">
  ${
  opts.zone.dashStyle === 'dash' && x !== opts.series.userOptions.custom.lastHistoricalYear
    ? `<line x1="0" y1="4" x2="25" y2="4" stroke-width="4" stroke="${color}" stroke-dasharray="0 1 8 4" />`
    : `<line x1="0" y1="4" x2="25" y2="4" stroke-width="4" stroke="${color}" />`
}
</svg>`;

export const options = {
  title: { text: '' },
  colors,
  yAxis: {
    lineColor: '#595B5D',
    lineWidth: 1,
    visible: true,
    tickColor: '#595B5D',
    labels: {
      align: 'right',
      style: {
        color: '#595B5D',
        fontSize: '12px'
      },
      format: '{value}'
    },
    title: {
      useHTML: true,
      align: 'high'
    },
    plotLines: [
      {
        value: 0,
        color: 'black',
        width: 1,
        zIndex: 5
      }
    ]
  },
  credits: {
    enabled: false
  },
  xAxis: {
    lineColor: '#595B5D',
    lineWidth: 1,
    tickColor: '#595B5D',
    tickInterval: 5,
    min: 2005,
    max: 2030,
    labels: {
      style: {
        fontSize: '14px'
      },
      overflow: 'allow'
    }
  },
  legend: {
    layout: 'horizontal',
    align: 'left',
    verticalAlign: 'bottom',
    padding: 50,
    itemDistance: 12,
    symbolHeight: 0,
    symbolWidth: 0,
    useHTML: true,
    itemMarginBottom: 10,
    labelFormatter() {
      return `<div class="emissions__chart__legend__label"><span style="background-color:${this.color}"></span>${this.name}</div>`;
    },
    className: 'emissions__chart__legend'
  },
  tooltip: {
    shared: true,
    headerFormat: `<div class='emissions__chart__tooltip__header'>
        <span>{point.key}</span> <span>{series.userOptions.custom.unit} / country</span>
      </div>`,
    pointFormatter() {
      return `<div class='emissions__chart__tooltip__item'>
          <div>
            ${tooltipLegendLine(this, this.x, this.color)}
            ${this.series.name} ${
  this.zone.dashStyle === 'dash' && this.x !== this.series.userOptions.custom.lastHistoricalYear
    ? ' <span class="--target">(target)</span>'
    : ''
}
          </div>
          <span>${Number(this.y).toFixed(2)}</span>
        </div>`;
    },
    style: {
      color: '#191919',
      fontSize: '14px'
    },
    borderWidth: 0,
    crosshairs: true,
    padding: 0,
    shadow: false,
    className: 'emissions__chart__tooltip',
    useHTML: true
  },
  chart: {
    height: 550,
    showAxes: true
  },
  plotOptions: {
    series: {
      marker: {
        enabled: false,
        states: {
          hover: {
            enabled: false
          }
        }
      }
    }
  },
  series: [],
  responsive: {
    rules: [
      {
        condition: {
          maxWidth: 992
        },
        chartOptions: {
          legend: {
            align: 'left',
            padding: 0,
            itemDistance: 10,
            alignColumns: false,
            margin: 0,
            itemMarginTop: 0
          },
          yAxis: {
            labels: {
              align: 'center',
              distance: 5,
              padding: 0,
              style: {
                fontSize: '10px'
              }
            },
            title: {
              reserveSpace: false,
              rotation: 0,
              style: {
                fontSize: '10px'
              }
            }
          },
          xAxis: {
            labels: {
              style: {
                fontSize: '10px'
              }
            }
          },
          chart: {
            height: 350
          }
        }
      }
    ]
  }
};

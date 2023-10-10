export const colors = [
  '#17B091',
  '#F26E6E',
  '#5454C4',
  '#B75038',
  '#FFDD49',
  '#00A8FF',
  '#F602B4',
  '#191919'
];

const tooltipLegendLine = (
  dashStyle,
  color
) => `<svg xmlns="http://www.w3.org/2000/svg" width="25" height="4" viewBox="0 0 25 4" fill="none">
${
  dashStyle === 'dash'
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
    tickAmount: 8,
    labels: {
      padding: 10,
      style: {
        color: '#595B5D',
        fontSize: '12px'
      }
    }
  },
  credits: {
    enabled: false
  },
  xAxis: {
    accessibility: {
      rangeDescription: 'Range: 2005 to 2030'
    },
    lineColor: '#595B5D',
    lineWidth: 1,
    tickColor: '#595B5D',
    tickInterval: 5,
    labels: {
      style: {
        color: '#0A4BDC',
        fontSize: '14px'
      }
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
    // enabled: false,
  },
  tooltip: {
    shared: true,
    headerFormat:
      "<div class='emissions__chart__tooltip__header'><span>{point.key}</span> <span>gCO2 / country</span></div>",
    pointFormatter() {
      return `<div class='emissions__chart__tooltip__item'>
          <div>
            ${tooltipLegendLine(this.zone.dashStyle, this.color)}
            ${this.series.name}${
  this.zone.dashStyle === 'dash'
    ? ' <span class="--target">(target)</span>'
    : ''
}
          </div>
          <span>${this.y}</span>
        </div>`;
    },
    style: {
      color: '#191919',
      fontSize: '14px'
    },
    borderWidth: 1,
    borderColor: '#595B5D',
    backgroundColor: '#ffffff',
    crosshairs: true,
    padding: 24,
    className: 'country-emissions-tooltip',
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
          maxWidth: 500
        },
        chartOptions: {
          legend: {
            layout: 'horizontal',
            align: 'center',
            verticalAlign: 'bottom'
          }
        }
      }
    ]
  }
};

export const colors = ['#5454C4', '#A3A3A3', '#17B091'];

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
      align: 'high',
      rotation: 0,
      offset: -50
    }
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
      }
    }
  },
  legend: {
    layout: 'horizontal',
    align: 'left',
    verticalAlign: 'bottom',
    padding: 22,
    itemDistance: 28,
    symbolWidth: 37,
    useHTML: true,
    itemMarginBottom: 10
  },
  tooltip: {
    shared: true,
    headerFormat: `<div class='emissions__chart__tooltip__header'>
          <span>{point.key}</span> <span>{series.userOptions.custom.unit}</span>
        </div>`,
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
    height: 450,
    showAxes: true,
    backgroundColor: 'transparent'
  },
  plotOptions: {
    lineWidth: 4,
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
          yAxis: {
            labels: {
              distance: 5,
              padding: 0,
              style: {
                fontSize: '10px'
              }
            },
            title: {
              style: {
                fontSize: '10px'
              }
            }
          }
        }
      }
    ]
  }
};

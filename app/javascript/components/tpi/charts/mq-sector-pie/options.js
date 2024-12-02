import merge from 'lodash/merge';

import defaultOptions from '../default-options';

const getDefaultText = (total) => `<span class="companies-size">${total}</span><br /><span class="companies-name">companies`;
const getSelectedText = (name, y, percentage) => `<span class="companies-size --selected">
  Level ${name}</span><br /><span class="companies-name --selected">${y} companies <br /> ${percentage?.toFixed(1)}%</span>`;

function centerText(chart) {
  const textX = chart.plotLeft + (chart.series[0].center[0]);

  chart.centerText.attr({
    x: textX - chart.centerText.getBBox().width / 2
  });
}

export function getOptions({ chartData }) {
  return merge({}, defaultOptions, {
    chart: {
      height: 320,
      width: 320,
      styledMode: true,
      type: 'pie',
      events: {
        render() {
          const chart = this;
          const textX = chart.plotLeft + (chart.series[0].center[0]);
          const textY = chart.plotTop + (chart.series[0].center[1]);

          if (chart.centerText) chart.centerText.destroy();

          chart.centerText = chart.renderer.text(getDefaultText(this.series[0]?.total), textX, textY, true)
            .attr({
              class: 'chart--mq-sector-pie-chart-title'
            })
            .add();

          centerText(chart);
        }
      }
    },
    colors: ['#86A9F9', '#5587F7', '#2465F5', '#0A4BDC', '#083AAB', '#9747FF'],
    title: {
      enabled: false
    },
    plotOptions: {
      pie: {
        width: 320,
        innerSize: '65%', // donut
        dataLabels: {
          enabled: false
        },
        stickyTracking: false,
        showInLegend: true,
        states: {
          hover: {
            halo: {
              size: 0
            }
          }
        },
        events: {
          mouseOut(e) {
            e.target.chart?.centerText?.attr({
              text: getDefaultText(e.target.chart.series[0]?.total),
              class: 'chart--mq-sector-pie-chart-title'
            });
            centerText(e.target.chart);
          }
        }
      }
    },
    series: [{
      type: 'pie',
      data: chartData
    }],
    legend: {
      enabled: false
    },
    tooltip: {
      formatter(e) {
        e.chart?.centerText?.attr({
          text: getSelectedText(this.point?.name, this.y, this.percentage),
          class: 'chart--mq-sector-pie-chart-title --selected'
        });
        centerText(e.chart);
      }
    }
  });
}

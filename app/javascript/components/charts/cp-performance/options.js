import React from 'react';

import { groupAllAreaSeries, renderBenchmarksLabels } from './helpers';
import { renderToString } from 'react-dom/server';
import Tooltip from './Tooltip';

export const COLORS = ['#00C170', '#ED3D4A', '#FFDD49', '#440388', '#FF9600', '#B75038', '#00A8FF', '#F78FB3', '#191919', '#F602B4'];

export function getOptions({ chartData, unit }) {
  return {
    chart: {
      height: '500px',
      marginTop: 30,
      events: {
        render() {
          groupAllAreaSeries();
          renderBenchmarksLabels(this);
        }
      }
    },
    credits: {
      enabled: false
    },
    colors: COLORS,
    legend: {
      enabled: false
    },
    plotOptions: {
      area: {
        marker: {
          enabled: false
        },
        label: {
          area: false
        }
      },
      line: {
        marker: {
          enabled: false
        }
      },
      column: {
        stacking: 'normal'
      },
      series: {
        lineWidth: 4,
        marker: {
          states: {
            hover: {
              enabled: false
            }
          }
        }
      }
    },
    yAxis: {
      title: {
        text: unit,
        reserveSpace: false,
        textAlign: 'left',
        align: 'high',
        rotation: 0,
        x: 0,
        y: -20
      }
    },
    xAxis: {
      crosshair: {
        width: 2,
        color: '#191919'
      },
      maxPadding: 0.15
    },
    title: {
      text: ''
    },
    tooltip: {
      crosshairs: true,
      shared: true,
      useHTML: true,
      formatter() {
        const xValue = this.x;
        const yValues = this.points.map(p => ({
          value: p.y,
          color: p.color,
          title: p.series.name,
          dashStyle: p.point.zone.dashStyle,
          isTargeted: p.point.zone.dashStyle === 'dot',
          isBenchmark: p.series.type === 'area'
        }));

        return renderToString(
          <Tooltip xValue={xValue} yValues={yValues} unit={unit} />
        );
      }
    },
    series: chartData
  };
}

import React from 'react';

import { groupAllAreaSeries, renderBenchmarksLabels } from './helpers';
import { renderToString } from 'react-dom/server';
import merge from 'lodash/merge';
import Tooltip from './Tooltip';

export const COLORS = ['#595B5D', '#ED3D4A', '#FFDD49', '#440388', '#FF9600', '#B75038', '#86A9F9', '#F78FB3', '#191919', '#F602B4'];

export function getOptions({ chartData, unit }) {
  return {
    chart: {
      height: '500px',
      marginTop: 30,
      events: {
        render() {
          // Group area series and add a classname only to allow grouped opacity change to 0.3
          groupAllAreaSeries();
          renderBenchmarksLabels(this);
        }
      }
    },
    credits: {
      enabled: false
    },
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
        lineWidth: 4,
        marker: {
          enabled: false
        }
      },
      column: {
        stacking: 'normal'
      },
      series: {
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
      outside: true,
      distance: 50,
      formatter() {
        const xValue = this.x;
        const yValues = this.points.filter(p => p.series.name !== 'Target Years').map(p => ({
          value: p.y,
          color: p.series.color,
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

export function getMobileOptions({ chartData, unit }) {
  const desktopOptions = getOptions({ chartData, unit });
  return merge({}, desktopOptions, {
    chart: {
      height: 400,
      events: {
        render() {
          groupAllAreaSeries();
          renderBenchmarksLabels(this, true);
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
        x: 45,
        y: 0,
        useHTML: true,
        style: {color: '#191919', backgroundColor: '#fff'}
      }
    },
    xAxis: {
      maxPadding: 0.03,
      labels: {
        style: {fontSize: '10px', color: '#0A4BDC'}
      }
    }
  });
}

export function getMultipleOptions({ chartData, unit }) {
  const options = getOptions({ chartData, unit });
  return {
    ...options,
    chart: { ...options.chart, height: 300, width: 400 },
    yAxis: {
      title: {
        text: unit,
        reserveSpace: false,
        textAlign: 'left',
        align: 'low',
        rotation: -90,
        x: -20,
        y: 10
      }
    }
  };
}

export function getMultipleMobileOptions({ chartData, unit }) {
  const options = getMobileOptions({ chartData, unit });
  return {
    ...options,
    chart: { ...options.chart, height: 300, width: 400 },
    yAxis: {
      title: {
        text: unit,
        reserveSpace: false,
        textAlign: 'left',
        align: 'low',
        rotation: -90,
        x: 0,
        y: 10
      }
    }
  };
}

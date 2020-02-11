/* eslint-disable react/no-this-in-sfc */

import React, { useEffect, useMemo, useState } from 'react';
import { renderToString } from 'react-dom/server';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { createSVGGroup } from './helpers';
import LegendItem from './LegendItem';
import Tooltip from './Tooltip';

function CPPerformanceAllSectors({ dataUrl, unit }) {
  const [data, setData] = useState([]);
  const [legendItems, setLegendItems] = useState([]);

  useEffect(() => {
    fetch(dataUrl)
      .then((r) => r.json())
      .then((chartData) => {
        setData(chartData);
        const companiesData = chartData.filter(d => d.type !== 'area');
        setLegendItems(companiesData);
      });
  }, []);

  const handleLegendItemRemove = (item) => {
    setLegendItems(legendItems.filter(l => l.name !== item.name));
  };

  const chartData = useMemo(() => {
    const legendItemsNames = legendItems.map(l => l.name);

    return data.filter(d => d.type === 'area' || legendItemsNames.includes(d.name));
  }, [data, legendItems]);

  const options = {
    chart: {
      events: {
        render() {
          // this will group all area series under one element
          // it will be possible to set opacity for all areas at once to make it looks as on designs
          const seriesGroup = document.querySelector('.chart--cp-performance g.highcharts-series-group');
          const groupedAreas = seriesGroup.querySelector('.areas-group') || createSVGGroup('areas-group');
          const series = [...seriesGroup.querySelectorAll('g.highcharts-area-series')];

          seriesGroup.appendChild(groupedAreas);

          series.forEach(serie => {
            groupedAreas.appendChild(serie);
          });
        }
      }
    },
    credits: {
      enabled: false
    },
    colors: [
      '#00C170', '#ED3D4A', '#FFDD49', '#440388', '#FF9600', '#B75038', '#00A8FF', '#F78FB3', '#191919', '#F602B4'
    ],
    legend: {
      enabled: false
    },
    plotOptions: {
      area: {
        marker: {
          enabled: false
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
  const chartWrapperStyle = {
    width: '100%',
    height: '800px'
  };

  return (
    <div className="chart chart--cp-performance">
      <div className="legend">
        <div className="legend-row">
          {legendItems.map(i => <LegendItem name={i.name} onRemove={() => handleLegendItemRemove(i)} />)}
        </div>
        <div className="legend-row">
          <span className="legend-item">
            <span className="line line--solid" />
            Reported
          </span>
          <span className="legend-item">
            <span className="line line--dotted" />
            Targeted
          </span>
        </div>
      </div>

      <div style={chartWrapperStyle}>
        <HighchartsReact
          highcharts={Highcharts}
          options={options}
        />
      </div>
    </div>
  );
}

CPPerformanceAllSectors.propTypes = {
  dataUrl: PropTypes.string.isRequired,
  unit: PropTypes.string.isRequired
};

export default CPPerformanceAllSectors;

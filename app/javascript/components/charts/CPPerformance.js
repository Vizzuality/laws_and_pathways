import React, { useEffect, useMemo, useState } from 'react';
import { renderToString } from 'react-dom/server';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

function createSVGGroup(className) {
  const group = createSVGElement('g');
  group.setAttribute('class', className);
  group.setAttribute('opacity', 0.3);
  return group;
}

function createSVGElement(element) {
  return document.createElementNS('http://www.w3.org/2000/svg', element);
}

function Line({ dashStyle, color, width }) {
  const style = {
    borderBottomStyle: dashStyle === 'dot' ? 'dotted' : 'solid',
    borderBottomColor: color,
    width
  };

  return (
    <span className="line" style={style} />
  );
}

function LegendItem({ name, onRemove }) {
  return (
    <div className="legend-item">
      <span className="legend-item__color" />
      {name}
      <button className="legend-item__remove" type="button" onClick={onRemove}>
        x
      </button>
    </div>
  );
}

LegendItem.propTypes = {
  name: PropTypes.string.isRequired,
  onRemove: PropTypes.func.isRequired
};

function SharedTooltip({ xValue, yValues, unit }) {
  const companyValues = yValues.filter(v => !v.isBenchmark);
  const benchmarkValues = yValues.filter(v => v.isBenchmark);

  return (
    <div className="cp-tooltip">
      <div className="cp-tooltip__row cp-tooltip__row--bold">
        <span>{xValue}</span>
        <span>{unit}</span>
      </div>

      {companyValues.map(y => (
        <div className="cp-tooltip__row cp-tooltip__row--bold">
          <span className="cp-tooltip__value-title">
            <Line dashStyle={y.dashStyle} color={y.color} />
            {y.title}
            {y.isTargeted && (<small>(targeted)</small>)}
          </span>
          <span>{y.value}</span>
        </div>
      ))}

      <div className="cp-tooltip__targets">
        TARGETS
      </div>

      {benchmarkValues.map(y => (
        <div className="cp-tooltip__row">
          <span>{y.title}</span>
          <span>{y.value}</span>
        </div>
      ))}
    </div>
  );
}

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
          const seriesGroup = document.querySelector('.chart--cp-emissions g.highcharts-series-group');
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
          <SharedTooltip xValue={xValue} yValues={yValues} unit={unit} />
        );
      }
    },
    series: chartData
  };
  const chartStyle = {
    width: '100%',
    height: '800px'
  };

  return (
    <div className="chart chart--cp-emissions">
      <div className="legend">
        {legendItems.map(i => <LegendItem name={i.name} onRemove={() => handleLegendItemRemove(i)} />)}
      </div>

      <div className="line-legend">
        <span className="line-legend-item line-legend-item--reported">Reported</span>
        <span className="line-legend-item line-legend-item--targeted">Targeted</span>
      </div>
      <div style={chartStyle}>
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

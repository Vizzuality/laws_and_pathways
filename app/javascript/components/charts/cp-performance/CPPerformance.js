/* eslint-disable react/no-this-in-sfc */

import React, { useEffect, useRef, useMemo, useState } from 'react';
import { renderToString } from 'react-dom/server';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import PlusIcon from 'images/icons/plus.svg';

import { groupAllAreaSeries } from './helpers';
import CompanySelector from './CompanySelector';
import LegendItem from './LegendItem';
import Tooltip from './Tooltip';

// TODO: move to common hooks
const useCallbackOutsideClick = (element, action) => {
  if (typeof action !== 'function') throw new Error('useCallbackOutsideClick expects action to be function');

  const handleClickOutside = event => {
    if (!element.current.contains(event.target)) action();
  };

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);
};

function CPPerformanceAllSectors({ dataUrl, unit }) {
  const [data, setData] = useState([]);
  const [legendItems, setLegendItems] = useState([]);
  const [showCompanySelector, setCompanySelectorVisible] = useState(false);

  const companySelectorWrapper = useRef();

  // TODO: add error handling
  useEffect(() => {
    fetch(dataUrl)
      .then((r) => r.json())
      .then((chartData) => {
        setData(chartData);
        setLegendItems(
          chartData.filter(d => d.type !== 'area').slice(0, 9)
        );
      });
  }, []);
  useCallbackOutsideClick(companySelectorWrapper, () => setCompanySelectorVisible(false));

  const handleLegendItemRemove = (item) => {
    setLegendItems(legendItems.filter(l => l.name !== item.name));
  };

  const handleSelectedCompaniesChange = (selected) => {
    setLegendItems(data.filter((d) => selected.includes(d.name)));
  };

  const companies = useMemo(() => data.filter(d => d.type !== 'area').map(i => i.name), [data]);
  const selectedCompanies = useMemo(() => legendItems.map(i => i.name), [legendItems]);
  const chartData = useMemo(
    () => data.filter(d => d.type === 'area' || selectedCompanies.includes(d.name)),
    [data, selectedCompanies]
  );

  // TODO: move to separate file
  const options = {
    chart: {
      events: {
        render() {
          groupAllAreaSeries();
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
    xAxis: {
      crosshair: {
        width: 2,
        color: '#191919'
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

  const handleAddCompaniesClick = (e) => {
    if (e.currentTarget) e.currentTarget.blur();
    setCompanySelectorVisible(!showCompanySelector);
  };

  return (
    <div className="chart chart--cp-performance">
      <div className="legend">
        <div className="legend-row">
          {legendItems.map(i => <LegendItem key={i.name} name={i.name} onRemove={() => handleLegendItemRemove(i)} />)}
          <span className="separator" />

          <div className="chart-company-selector-wrapper" ref={companySelectorWrapper}>
            <button type="button" className="button is-primary with-icon" onClick={handleAddCompaniesClick}>
              <img src={PlusIcon} />
              Add companies to the chart
            </button>

            {showCompanySelector && (
              <CompanySelector companies={companies} selected={selectedCompanies} onChange={handleSelectedCompaniesChange} />
            )}
          </div>

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

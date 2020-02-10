import React, { useEffect, useMemo, useState } from 'react';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

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
        lineWidth: 4
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

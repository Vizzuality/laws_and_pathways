/* eslint-disable react/no-this-in-sfc, no-nested-ternary */

import React, {useCallback, useEffect, useState} from 'react';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { getOptions, getMobileOptions } from './options';
import { useChartData } from '../hooks';
import { useDeviceInfo } from 'components/Responsive';

function transformData(data) {
  const newData = {};
  data.forEach((d) => {
    if (d[1].length === 0) return;
    newData[d[0]] = d[1];
  });

  return newData;
}

function CPPerformanceAllSectors({ dataUrl, sectors }) {
  const { data, error, loading } = useChartData(dataUrl);
  const { isMobile } = useDeviceInfo();
  const noData = !loading && data && data.length === 0;

  const [alignmentKey, setAlignmentKey] = useState('cp_alignment_2050');

  const [allButtons, setAllButtons] = useState([]);

  const allData = transformData(data);
  const selectedData = alignmentKey in allData ? allData[alignmentKey] : [];

  const buttonLabels = {
    cp_alignment_2028: {label: 'Short 2028', order: 0},
    cp_alignment_2035: {label: 'Medium 2035', order: 1},
    cp_alignment_2050: {label: 'Long 2050', order: 2}
  };
  const highchartsButtonCallback = (chart) => {
    const buttons = Object.keys(allData)
      .sort((key1, key2) => buttonLabels[key1].order - buttonLabels[key2].order)
      .map((key) => ({key, label: buttonLabels[key].label}));
    buttons.forEach(({key, label}, index) => {
      const button = chart.renderer.button(label, 750 + index * 100, 230, (event) => {
        if (allButtons.length > 0) {
          allButtons[index].attr({fill: 'blue'});
        }
        setAlignmentKey(key);
      }, {
        fill: alignmentKey === key ? 'blue' : 'white',
        style: {
          width: 200,
          border: '1px solid black',
          color: alignmentKey === key ? 'white' : 'black'
        }
      }, null, null, null, null, true);
      button.add();
      setAllButtons(function (prevState) {
        return [...prevState, button];
      });
    });
  };

  const options = isMobile ? getMobileOptions(selectedData, sectors) : getOptions(selectedData, sectors);

  return (
    <div id="cp-performance-all-sectors-chart" className="chart chart--cp-all-sectors">
      {loading ? (
        <p>Loading...</p>
      ) : (
        <React.Fragment>
          {error ? (
            <p>{error}</p>
          ) : noData ? (
            <p>No data available.</p>
          ) : (
            <HighchartsReact
              highcharts={Highcharts}
              options={options}
              callback={highchartsButtonCallback}
            />
          )}
        </React.Fragment>
      )}
    </div>
  );
}

CPPerformanceAllSectors.propTypes = {
  dataUrl: PropTypes.string.isRequired,
  sectors: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.string.isRequired,
      link: PropTypes.string.isRequired,
      cluster: PropTypes.string
    }).isRequired
  ).isRequired
};

export default CPPerformanceAllSectors;

import React, { useEffect, useState } from 'react';
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

function setButtonsColor(buttons, alignmentKey) {
  buttons.forEach((button) => {
    const key = button.attr('data-alignment-key');
    if (key === alignmentKey) {
      button.setState(2);
      return;
    }
    button.setState(0);
  });
}

function CPPerformanceAllSectors({ dataUrl, sectors }) {
  const { data, error, loading } = useChartData(dataUrl);
  const { isMobile } = useDeviceInfo();
  const noData = !loading && data && data.length === 0;

  const [alignmentKey, setAlignmentKey] = useState('cp_alignment_2050');
  const [buttons, setButtons] = useState([]);

  const allData = transformData(data);
  const selectedData = alignmentKey in allData ? allData[alignmentKey] : [];

  const buttonLabels = {
    cp_alignment_2028: { label: 'Short 2028', order: 0 },
    cp_alignment_2035: { label: 'Medium 2035', order: 1 },
    cp_alignment_2050: { label: 'Long 2050', order: 2 }
  };

  useEffect(() => {
    setButtonsColor(buttons, alignmentKey);
  }, [alignmentKey, buttons]);

  const highchartsButtonCallback = (chart) => {
    const buttonDefinitions = Object.keys(allData)
      .sort((key1, key2) => buttonLabels[key1].order - buttonLabels[key2].order)
      .map((key) => ({ key, label: buttonLabels[key].label }));
    const newButtons = [];
    buttonDefinitions.forEach(({ key, label }, index) => {
      const baseStyle = {
        width: 200,
        border: '1px solid black'
      };
      const button = chart.renderer.button(label, 750 + index * 100, 230, () => {
        setAlignmentKey(key);
      }, {
        fill: 'white',
        style: {
          ...baseStyle,
          color: 'black'
        }
      }, {
        fill: 'red',
        style: {
          ...baseStyle,
          color: 'black'
        }
      }, {
        fill: 'blue',
        style: {
          ...baseStyle,
          color: 'white'
        }
      }, null, null, true);
      button.attr({ 'data-alignment-key': key });
      button.add();
      // eslint-disable-next-line dot-notation
      button['text'].element.addEventListener('click', () => setAlignmentKey(key));
      newButtons.push(button);
    });
    setButtons(newButtons);
  };

  const options = isMobile ? getMobileOptions(selectedData, sectors) : getOptions(selectedData, sectors);

  return (
    <div id="cp-performance-all-sectors-chart" className="chart chart--cp-all-sectors">
      {loading ? (
        <p>Loading...</p>
      ) : (
        <React.Fragment>
          {/* eslint-disable-next-line no-nested-ternary */}
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

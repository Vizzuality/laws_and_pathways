/* eslint-disable react/no-this-in-sfc, no-nested-ternary */

import React from 'react';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { getOptions } from './options';
import { useChartData } from '../hooks';
/* import { useDeviceInfo } from 'components/Responsive'; */

function AverageBankScore({ dataUrl }) {
  const { data, error, loading } = useChartData(dataUrl);
  /* const { isMobile } = useDeviceInfo(); */
  /* const options = isMobile ? getMobileOptions(data) : getOptions(data); */
  const options = getOptions(data);
  const noData = !loading && data && data.length === 0;

  return (
    <div id="average-bank-score-chart" className="chart chart--bank-average-score">
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
            />
          )}
        </React.Fragment>
      )}
    </div>
  );
}

AverageBankScore.propTypes = {
  dataUrl: PropTypes.string.isRequired
};

export default AverageBankScore;

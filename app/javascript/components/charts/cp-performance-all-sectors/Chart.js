/* eslint-disable react/no-this-in-sfc */

import React from 'react';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { getOptions } from './options';
import { useChartData } from '../hooks';

function CPPerformanceAllSectors({ dataUrl, sectors }) {
  const { data, error, loading } = useChartData(dataUrl);
  const options = getOptions(data, sectors);

  return (
    <div id="cp-performance-all-sectors-chart" className="chart chart--cp-all-sectors">
      {loading ? (
        <p>Loading...</p>
      ) : (
        <React.Fragment>
          {error ? (
            <p>{error}</p>
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

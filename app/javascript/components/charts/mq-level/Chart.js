import React from 'react';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';
import { useMediaQuery } from 'react-responsive';

import { getOptions, getMobileOptions } from './options';
import { useChartData } from '../hooks';

function MQLevelChart({ dataUrl }) {
  const { data, error, loading } = useChartData(dataUrl);
  const isMobile = useMediaQuery({ query: '(max-width: 1024px)' });
  const options = isMobile ? getMobileOptions({ chartData: data }) : getOptions({ chartData: data });

  return (
    <div className="chart chart--mq-level">
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

MQLevelChart.propTypes = {
  dataUrl: PropTypes.string.isRequired
};

export default MQLevelChart;

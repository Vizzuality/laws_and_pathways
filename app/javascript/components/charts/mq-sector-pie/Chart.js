import React from 'react';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { getOptions } from './options';
import { useChartData } from '../hooks';

function MQSectorChart({ dataUrl }) {
  const { data, loading, error } = useChartData(dataUrl);
  const options = getOptions({ chartData: data });
  const numberOfCompanies = data.reduce((acc, d) => acc + d[1], 0);

  return (
    <div className="chart chart--styled chart--mq-sector-pie-chart">
      {loading ? (
        <p>Loading...</p>
      ) : (
        <React.Fragment>
          {error ? (
            <p>{error}</p>
          ) : (
            <React.Fragment>
              <HighchartsReact
                highcharts={Highcharts}
                options={options}
              />

              <div className="chart-title">
                <p className="companies-size">{numberOfCompanies}</p>
                companies
              </div>
            </React.Fragment>
          )}
        </React.Fragment>
      )}
    </div>
  );
}

MQSectorChart.propTypes = {
  dataUrl: PropTypes.string.isRequired
};

export default MQSectorChart;

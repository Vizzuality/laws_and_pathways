import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { getOptions } from './options';

function MQSectorChart({ dataUrl }) {
  const [data, setData] = useState([]);
  const [error, setError] = useState('');

  const options = getOptions({ chartData: data });
  const numberOfCompanies = data.reduce((acc, d) => acc + d[1], 0);

  useEffect(() => {
    fetch(dataUrl)
      .then((r) => r.json())
      .then((chartData) => {
        setData(chartData);
      })
      .catch(() => setError('Error while loading the data'));
  }, [dataUrl]);

  return (
    <div className="chart chart--styled chart--mq-sector-pie-chart">
      {error && (
        <div>
          <p>{error}</p>
        </div>
      )}

      <HighchartsReact
        highcharts={Highcharts}
        options={options}
      />

      <div className="chart-title">
        <p className="companies-size">{numberOfCompanies}</p>
        companies
      </div>
    </div>
  );
}

MQSectorChart.propTypes = {
  dataUrl: PropTypes.string.isRequired
};

export default MQSectorChart;
